from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Lock, Thread
from urllib.parse import parse_qs, urlsplit

HOST = "127.0.0.1"
PORT = 8080
OUT = Path("stormworks_log.csv")
FILE_LOCK = Lock()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        u = urlsplit(self.path)

        if u.path != "/log":
            self.send_response(404)
            self.end_headers()
            return

        qs = parse_qs(u.query, keep_blank_values=True)
        rows = qs.get("d")

        if not rows:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"missing d\n")
            return

        row = rows[0]
        cols = row.split(",")

        if len(cols) != 65:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(f"bad column count: {len(cols)}\n".encode("ascii"))
            return

        try:
            tick = int(float(cols[0]))
        except ValueError:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"bad tick\n")
            return

        with FILE_LOCK:
            if tick == 1:
                OUT.write_text("", encoding="utf-8")

            with OUT.open("a", encoding="utf-8", newline="") as f:
                f.write(row + "\n")

        self.send_response(204)
        self.end_headers()

    def log_message(self, fmt, *args):
        return


def main():
    server = ThreadingHTTPServer((HOST, PORT), Handler)

    thread = Thread(target=server.serve_forever, daemon=True)
    thread.start()

    print(f"listening: http://{HOST}:{PORT}/log?d=...")
    print(f"output: {OUT.resolve()}")
    print("press Q then Enter to quit")

    try:
        while True:
            cmd = input("> ").strip().lower()
            if cmd == "q":
                break
    except KeyboardInterrupt:
        pass
    finally:
        print("shutting down...")
        server.shutdown()
        server.server_close()
        thread.join()
        print("done")


if __name__ == "__main__":
    main()
