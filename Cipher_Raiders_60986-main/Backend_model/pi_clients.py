
# pi_client.py
from picamera2 import Picamera2
import cv2
import requests
import numpy as np
import time
from spray_control import spray_infected, spray_healthy

SERVER_URL = "http://10.41.165.172:5000/detect"   # <-- change to your Kali IP
COOLDOWN = 1.0
FRAME_DELAY = 0.5

picam = Picamera2()
picam.configure(picam.create_preview_configuration({"size": (640,480)}))
picam.start()
time.sleep(1)

print("[INFO] Camera started")
last = 0
try:
    while True:
        frame = picam.capture_array()
        _, enc = cv2.imencode(".jpg", frame)
        try:
            r = requests.post(SERVER_URL, files={"image": enc.tobytes()}, timeout=2.0)
            j = r.json()
        except Exception as e:
            print("[ERROR] server:", e)
            time.sleep(1)
            continue

        infected = j.get("infected", False)
        count = j.get("count", 0)
        print("[DETECT]", infected, "count:", count, "inf_time:", j.get("inference_time"))

        now = time.time()
        if now - last > COOLDOWN:
            if infected:
                spray_infected()
            else:
                spray_healthy()
            last = now

        time.sleep(FRAME_DELAY)

except KeyboardInterrupt:
    print("Stopping")
finally:
    picam.stop()
