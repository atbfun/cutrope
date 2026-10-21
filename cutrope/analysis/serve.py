"""Threaded, local-only static host for the portable HTML5 build."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--port', type=int, default=8765)
args = parser.parse_args()
class GameServer(ThreadingHTTPServer):
    # Browsers open connections in bursts, especially across QA contexts.
    # Base TCPServer's queue of five can reset otherwise valid asset requests.
    request_queue_size = 128


root = Path(__file__).resolve().parents[1] / 'web'
server = GameServer(('127.0.0.1', args.port),
    partial(SimpleHTTPRequestHandler, directory=str(root)))
print(f'http://127.0.0.1:{server.server_port}', flush=True)
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
finally:
    server.server_close()
