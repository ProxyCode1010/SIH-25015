
# 📘 **Vrikshanova – Intelligent Pesticide Sprinkling System**

### **Team Name:** Cipher Raiders

### **Team ID:** 60968

### **Tech Stack:** Flutter (Frontend), Python (Backend + ML)

---

## 🌱 **Overview**

**Vrikshanova** is a smart agriculture application designed to assist farmers in detecting plant diseases, monitoring weather, and intelligently controlling a pesticide-sprinkling rover.
The system determines the **infection level of the plant** using machine learning and adjusts pesticide spraying accordingly.

---

## 🚀 **Key Features**

### 🔹 **1. Rover Control**

* Real-time WebSocket-based rover movement control
* Video preview using **flutter_vlc_player** & **video_player**
* Controls include: Forward, Backward, Left, Right, Stop
* Manual & automatic modes

---

### 🔹 **2. Plant Disease Prediction**

* Uses a TensorFlow Lite model (`tflite_flutter`)
* Detects multiple plant diseases from captured/selected images
* Provides predicted class + disease information
* Model runs **on-device**, no internet required

---

### 🔹 **3. Weather Information**

* Fetches real-time weather using HTTP API
* Helps farmers decide ideal pesticide spraying time

---

### 🔹 **4. Help & Support**

* FAQ page
* Step-by-step instructions on operating the rover
* Troubleshooting guide
* Contact/support section

---

### 🔹 **5. Demo Videos**

* App demonstration
* Disease detection demo
* Rover control usage guide

---

## 🧠 **Problem Statement**

**"Intelligent pesticide sprinkling system determined by infection level of plant."**

The system analyzes the health condition of plants through ML models and makes smart decisions for precise pesticide spraying—reducing chemical usage and improving yield.

---

## 📂 **Project Structure (Flutter)**

```
lib/
 ├── navigation/
 ├── rover_control/
 ├── prediction/
 ├── weather/
 ├── help_support/
 ├── widgets/
 └── main.dart

assets/
 ├── images/
 ├── videos/
 ├── languages/
 ├── model/
 └── labels.txt
```

---

## 🛠 **Tech Used**

### **Flutter Packages**

* `supabase_flutter` – Auth & backend
* `webview_flutter` – Rover video stream UI
* `flutter_vlc_player` – Streaming IP video
* `tflite_flutter` – ML prediction
* `camera` – Live camera usage
* `fl_chart` – Weather & disease analytics
* `http` – API communication
* `shared_preferences` – Local storage

### **Python**

* Model training
* ONNX/TFLite conversion
* Backend APIs (optional, if used)

---

## 📲 **How to Run the App**

### **1. Clone the project**

```bash
git clone <your-repo-link>
cd vrikshanova
```

### **2. Install dependencies**

```bash
flutter pub get
```

### **3. Run the app**

```bash
flutter run
```

---

## 🤖 **Machine Learning Model**

* Model file inside: `assets/model/`
* Supported formats: `.tflite`, `.labels.txt`
* Optimized for mobile
* Works for: leaf diseases, infection percentage, severity level

---

## 🎮 **Rover Controls – Usage Guide**

| Button     | Action               |
| ---------- | -------------------- |
| ⬆ Forward  | Moves rover ahead    |
| ⬇ Backward | Moves rover backward |
| ⬅ Left     | Turns left           |
| ➡ Right    | Turns right          |
| ■ Stop     | Immediate halt       |

Video streaming source is provided via a camera IP.

---

## 🌦 **Weather Module**

Displays:

* Temperature
* Humidity
* Rain probability
* Wind speed
* Ideal spraying suggestion

---

## 📞 **Help & Support**

Inside the app:

* Troubleshooting
* Contact details
* FAQ
* System usage guide

---

## 📹 **Demo Videos**

Contains:

* Full app walkthrough
* Rover control live test
* Model prediction test

Videos placed in:

```
assets/videos/
```

---

## 🔰 **Future Enhancements**

* AI-based autonomous navigation
* Multi-crop disease classification
* Soil nutrient analysis
* Farmer-to-doctor live support

