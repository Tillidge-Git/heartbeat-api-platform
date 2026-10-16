from flask import Flask, jsonify, request

def create_app():
    app = Flask(__name__)
    @app.get("/health")
    def health_check():
        return jsonify({"status": "healthy"}), 200

    return app