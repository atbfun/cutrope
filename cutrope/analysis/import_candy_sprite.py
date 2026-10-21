"""Import the original composed candy, after FFDec's sprite export.

java -Djava.awt.headless=true -jar ffdec.jar -selectid 823 -export sprite \
    /tmp/cutrope-sprites source/cutrope/cutrope.swf
python target/cutrope/analysis/import_candy_sprite.py /tmp/cutrope-sprites
"""
from pathlib import Path
import argparse
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument('ffdec_output', type=Path)
args = parser.parse_args()
source = next(args.ffdec_output.glob('DefineSprite_823*/1.png'))
out = Path(__file__).resolve().parents[1] / 'assets/images/candy.png'
with Image.open(source) as image:
    image.crop(image.getbbox()).save(out)
print(out)
