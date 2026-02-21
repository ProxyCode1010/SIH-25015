
# server.py  (Kali Linux)
from ultralytics import YOLO
from flask import Flask, request, jsonify
import numpy as np
import cv2
import io
import time

print("\n=== YOLO Detection Server (Kali Linux) ===\n")

model = YOLO("best.pt")
print("[INFO] Model loaded successfully.")

app = Flask(_name_)

@app.get("/")
def home():
    return "YOLO Server Alive"

@app.post("/detect")
def detect():
    try:
        # read image file in POST
        file = request.files.get("image")
        if file is None:
            return jsonify({"infected": False, "count": 0})

        data = file.read()
        arr = np.frombuffer(data, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)

        start = time.time()
        res = model(img)[0]
        infer_time = time.time() - start

        # classes detection logic: treat any class except 'Healthy' as infected
        # adjust according to your model label indexing
        boxes = []
        for b in res.boxes:
            cls_id = int(b.cls)
            score = float(b.conf) if hasattr(b, "conf") else 1.0
            boxes.append({"class": cls_id, "score": score})

        # Suppose class index for Healthy is 1 (adjust as per training)
        infected_boxes = [b for b in boxes if b["class"] != 1]

        response = {
            "infected": len(infected_boxes) > 0,
            "count": len(infected_boxes),
            "inference_time": infer_time
        }
        return jsonify(response)
    except Exception as e:
        print("Server error:", e)
        return jsonify({"infected": False, "count": 0})

if _name_ == "_main_":
    app.run(host="0.0.0.0", port=5000, debug=False)
