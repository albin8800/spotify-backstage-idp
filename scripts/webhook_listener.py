#!/usr/bin/env python3
"""
Enterprise Developer Portal - Post-Scaffold Webhook Listener
Receives notification payloads from Backstage Scaffolder executions.
"""

from http.server import BaseHTTPRequestHandler, HTTPServer
import json
from datetime import datetime

HOST = "0.0.0.0"
PORT = 8080


class ScaffolderWebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        post_data = self.rfile.read(content_length)

        try:
            payload = json.loads(post_data.decode("utf-8"))
        except Exception:
            payload = {"raw": post_data.decode("utf-8")}

        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        print("\n" + "=" * 60)
        print(f"🚀 [POST-SCAFFOLD EVENT RECEIVED] at {timestamp}")
        print("=" * 60)
        print(json.dumps(payload, indent=2))
        print("=" * 60)
        print("⚡ Triggering simulated post-provisioning tasks...")
        print(
            f"   [+] Registered {payload.get('service', 'unknown')} with Platform Catalog"
        )
        print(
            f"   [+] Slack alert dispatched for repository: {payload.get('repoUrl', 'N/A')}"
        )
        print("=" * 60 + "\n")

        # Send HTTP 200 OK back to Backstage
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        response = {"status": "success", "message": "Post-scaffold event processed"}
        self.wfile.write(json.dumps(response).encode("utf-8"))

    def log_message(self, format, *args):
        # Clean console output
        return


def run():
    server = HTTPServer((HOST, PORT), ScaffolderWebhookHandler)
    print(f"[*] Post-Scaffold Webhook Listener running on http://{HOST}:{PORT}")
    print("[*] Waiting for Backstage Scaffolder events...\n")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[!] Shutting down webhook server.")
        server.server_close()


if __name__ == "__main__":
    run()
