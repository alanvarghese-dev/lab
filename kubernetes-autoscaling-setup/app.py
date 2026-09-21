from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
            return

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Kubernetes Autoscaling App")

    def log_message(self, format, *args):
        return


server = HTTPServer(("0.0.0.0", 8000), Handler)
server.serve_forever()
