from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        response = "Hello from version 2"

        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(response)))
        self.end_headers()

        self.wfile.write(response.encode())

    def log_message(self, format, *args):
        pass


server = HTTPServer(("0.0.0.0", 8000), Handler)
print("Server running on port 8000")
server.serve_forever()
