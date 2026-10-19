from flask import Flask, jsonify, request
import json

import json
import logging
import sys
from datetime import datetime, timezone


class JsonFormatter(logging.Formatter):
    def format(self, record):
        line = {
            "time": datetime.fromtimestamp(record.created, timezone.utc).isoformat(),
            "level": record.levelname,
            "event": record.getMessage(),
        }
        line.update(getattr(record, "context", {}))
        return json.dumps(line)


handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())

logger = logging.getLogger("heartbeat")
logger.addHandler(handler)
logger.setLevel(logging.INFO)
logger.propagate = False


def log(level, event, reason=None, **context):
    if reason is not None:
        context["reason"] = reason
    logger.log(getattr(logging, level), event, extra={"context": context})

    
def create_app():
    app = Flask(__name__)
    @app.get("/health")
    def health_check():
        return jsonify({"status": "healthy"}), 200
    


    @app.post("/ping")
    def bot_ping():
        data = request.get_json(silent=True)
        if not isinstance(data, dict):
            log("WARNING", "ping_rejected", reason="Invalid JSON data")
            return jsonify({"ERROR": "Invalid JSON data"}), 400

        machine_id = data.get("machine_id")
        seq = data.get("seq")

        if not isinstance(machine_id, str) or not machine_id.strip():
            log("WARNING", "ping_rejected", reason="Missing or invalid 'machine_id' field")
            return jsonify({"ERROR": "Missing or invalid 'machine_id' field"}), 400
        
        if machine_id != machine_id.strip():
            log("WARNING", "ping_rejected", reason="Invalid 'machine_id' value")
            return jsonify({"ERROR": "Invalid 'machine_id' value"}), 400
        
        if not isinstance(seq, int):
            log("WARNING", "ping_rejected", reason="Missing or invalid 'seq' field")
            return jsonify({"ERROR": "Missing or invalid 'seq' field"}), 400
        
        log("INFO", "ping_accepted", machine_id=machine_id, seq=seq, )
        return jsonify({"status": "accepted", "machine_id": machine_id, "seq": seq}), 200

    return app