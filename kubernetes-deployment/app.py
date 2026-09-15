from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        message = "Hello from Kubernetes v2!"

        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(message.encode())

    def log_message(self, format, *args):
        pass


server = HTTPServer(("0.0.0.0", 8080), Handler)

print("Application v2 listening on port 8080")

server.serve_forever()
