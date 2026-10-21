"""Reproducible read-only FWS extraction. Run with Python + Pillow.

Extract original XML, JPEG3 alpha, lossless ARGB, MP3 and symbol identities.
No original game code is executed. FFDec is used separately for AS3.
"""
from pathlib import Path
import collections
import hashlib
import io
import json
import re
import struct
import zlib
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'source/cutrope/cutrope.swf'


def tags(data, offset):
    while offset + 2 <= len(data):
        head = struct.unpack_from('<H', data, offset)[0]
        offset += 2
        size = head & 63
        if size == 63:
            size = struct.unpack_from('<I', data, offset)[0]
            offset += 4
        if offset + size > len(data):
            raise ValueError('SWF tag exceeds input bounds')
        yield head >> 6, offset, data[offset:offset + size]
        offset += size


def extract():
    data = SOURCE.read_bytes()
    assert data[:3] == b'FWS'
    offset = 8 + (5 + 4 * (data[8] >> 3) + 7) // 8 + 4
    records = list(tags(data, offset))
    symbols = {}
    for tag, _, p in records:
        if tag == 76:
            pos = 2
            for _ in range(struct.unpack_from('<H', p)[0]):
                ident = struct.unpack_from('<H', p, pos)[0]
                end = p.index(0, pos + 2)
                symbols[ident] = p[pos + 2:end].decode()
                pos = end + 1
    manifest = {'source_sha256': hashlib.sha256(data).hexdigest(),
                'symbols': symbols, 'images': [], 'sounds': [], 'levels': [], 'sprites': []}
    levels = []
    for tag, at, p in records:
        if len(p) < 2:
            continue
        ident = struct.unpack_from('<H', p)[0]
        if tag == 39:
            manifest['sprites'].append({'id':ident, 'symbol':symbols.get(ident),
                'frames':struct.unpack_from('<H',p,2)[0], 'fps':60, 'tag_offset':at})
        if tag in (21, 35, 36):
            if tag == 21:
                img = Image.open(io.BytesIO(p[2:])).convert('RGBA')
            elif tag == 35:
                size = struct.unpack_from('<I', p, 2)[0]
                img = Image.open(io.BytesIO(p[6:6 + size])).convert('RGBA')
                alpha = zlib.decompress(p[6 + size:])
                img.putalpha(Image.frombytes('L', img.size, alpha))
            else:
                fmt, w, h = struct.unpack_from('<BHH', p, 2)
                if fmt not in (3, 5):
                    raise ValueError(f'Unsupported lossless format {fmt}')
                if fmt == 3:
                    count = p[7] + 1
                    packed = zlib.decompress(p[8:])
                    palette = packed[:count*4]
                    indices = packed[count*4:]
                    stride = (w+3)//4*4
                    raw = bytearray()
                    for y in range(h):
                        for x in range(w):
                            k = indices[y*stride+x]*4
                            r,g,b,a = palette[k:k+4]
                            raw.extend((a,r,g,b))
                else:
                    raw = zlib.decompress(p[7:])
                # Flash lossless ARGB is premultiplied.
                rgba = bytearray(w * h * 4)
                for i in range(w * h):
                    a, r, g, b = raw[4*i:4*i+4]
                    rgba[4*i:4*i+4] = bytes((min(255, r*255//a) if a else 0,
                        min(255, g*255//a) if a else 0,
                        min(255, b*255//a) if a else 0, a))
                img = Image.frombytes('RGBA', (w, h), bytes(rgba))
            name = f'{ident}.png'
            img.save(OUT / 'assets/images' / name)
            if ident in (415,417,445,475,479,483,503,188,239):
                img.crop(img.getbbox()).save(OUT / 'assets/images' / f'trim{ident}.png')
            manifest['images'].append({'id': ident, 'file': name,
                                      'width': img.width, 'height': img.height,
                                      'tag_offset': at})
        elif tag == 14:
            fmt = p[2] >> 4
            name = symbols.get(ident, str(ident)).split('SoundController_')[-1]
            if fmt != 2:
                raise ValueError(f'Expected MP3, found {fmt}')
            (OUT / 'assets/audio' / f'{name}.mp3').write_bytes(p[9:])
            manifest['sounds'].append({'id': ident, 'name': name,
                                      'file': f'{name}.mp3', 'tag_offset': at})
        elif tag == 87:
            text = p[6:].decode('utf-8')
            name = symbols.get(ident, str(ident)).split('.')[-1]
            (OUT / 'assets/levels' / f'{name}.xml').write_text(text)
            root = ET.fromstring(text)
            match = re.search(r'_L(\d+)_(\d+)$', name)
            if match:
                entry = {'box': int(match[1]), 'number': int(match[2]),
                         'source': name, 'settings': dict(root.find("layer/map").attrib),
                         'objects': [{'type': e.tag, **e.attrib}
                            for e in root.find("layer[@name='Objects']")]}
                levels.append(entry)
            manifest['levels'].append({'id': ident, 'symbol': name, 'tag_offset': at})
    levels.sort(key=lambda e: (e['box'], e['number']))
    (OUT / 'assets/levels.json').write_text(json.dumps(levels, ensure_ascii=False, indent=2))
    (OUT / 'assets/levels.js').write_text('globalThis.CutRopeLevels = ' + json.dumps(levels, ensure_ascii=False) + ';\n')
    (OUT / 'assets/manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2))
    sheet = Image.new('RGB', (1000, ((len(manifest['images']) + 9)//10) * 100), '#e9e4d9')
    draw = ImageDraw.Draw(sheet)
    for i, item in enumerate(manifest['images']):
        img = Image.open(OUT / 'assets/images' / item['file'])
        img.thumbnail((92, 76))
        x, y = i % 10 * 100, i // 10 * 100
        sheet.paste(img, (x + (100-img.width)//2, y), img)
        draw.text((x+4,y+78), f"{item['id']} {item['width']}x{item['height']}", fill='#272b25')
    sheet.save(OUT / 'analysis/contact_sheet.jpg')
    print(json.dumps({'images': len(manifest['images']), 'sounds': len(manifest['sounds']),
                      'levels': len(levels), 'types': dict(collections.Counter(
                          e['type'] for l in levels for e in l['objects']))}, indent=2))


if __name__ == '__main__':
    extract()
