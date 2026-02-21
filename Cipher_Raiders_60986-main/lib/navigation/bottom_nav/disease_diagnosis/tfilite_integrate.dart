import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteIntegrate {
  static final TFLiteIntegrate _instance = TFLiteIntegrate._internal();

  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  // Model path
  static const String MODEL_PATH = 'assets/model/plant_disease_model.tflite';

  // Model input/output configuration
  static const int INPUT_SIZE = 224;
  static const int NUM_CLASSES = 38; // Total classes in your model

  //  Disease class mapping - 38 classes from your model
  static const Map<int, Map<String, String>> diseaseInfo = {
    0: {
      'name': 'Apple - Apple Scab',
      'treatment': 'Remove infected leaves immediately. Apply fungicide sprays (Captan or Sulfur) weekly during growing season. Improve air circulation by pruning. Avoid overhead watering. Clean fallen leaves from ground.'
    },
    1: {
      'name': 'Apple - Black Rot',
      'treatment': 'Prune and remove infected branches below the canker by at least 12 inches. Apply copper fungicide or lime sulfur spray. Improve drainage around the tree. Remove mummified fruit. Sterilize pruning tools.'
    },
    2: {
      'name': 'Apple - Cedar Apple Rust',
      'treatment': 'Remove infected leaves and fruit. Apply sulfur or copper-based fungicide starting in spring. Remove nearby cedar/juniper trees if possible. Ensure good air circulation. Apply preventive sprays in early season.'
    },
    3: {
      'name': 'Apple - Healthy',
      'treatment': 'Plant is healthy! Continue regular maintenance. Water deeply and regularly. Prune dead branches. Monitor for pest activity. Apply preventive fungicide sprays as needed based on weather conditions.'
    },
    4: {
      'name': 'Blueberry - Healthy',
      'treatment': 'Plant is healthy! Maintain consistent watering (keep soil moist but not waterlogged). Mulch around base. Prune spent flowers and dead wood. Apply balanced fertilizer in spring.'
    },
    5: {
      'name': 'Cherry - Powdery Mildew',
      'treatment': 'Remove heavily affected leaves and branches. Apply sulfur powder or neem oil spray every 7-10 days. Improve air circulation by thinning branches. Avoid overhead watering. Apply in early morning or evening.'
    },
    6: {
      'name': 'Cherry - Healthy',
      'treatment': 'Plant is healthy! Water regularly during dry spells. Prune in late winter to maintain shape. Remove any pest-infested fruit. Monitor for birds and insects. Apply preventive fungicide if needed.'
    },
    7: {
      'name': 'Corn - Cercospora Leaf Spot / Gray Leaf Spot',
      'treatment': 'Remove infected leaves. Apply fungicide containing mancozeb or azoxystrobin. Improve drainage and air circulation. Rotate crops annually. Use disease-resistant varieties. Avoid working in wet fields.'
    },
    8: {
      'name': 'Corn - Common Rust',
      'treatment': 'Apply fungicide (Azoxystrobin or Propiconazole) when rust appears. Plant resistant varieties. Improve air circulation. Remove infected leaf debris. Monitor plants regularly. Apply sprays every 7-10 days if needed.'
    },
    9: {
      'name': 'Corn - Northern Leaf Blight',
      'treatment': 'Use disease-resistant corn varieties. Apply fungicide containing azoxystrobin or propiconazole. Remove infected leaves. Practice crop rotation (2-3 year cycle). Improve drainage. Avoid overhead irrigation.'
    },
    10: {
      'name': 'Corn - Healthy',
      'treatment': 'Plant is healthy! Maintain consistent watering (1-2 inches per week). Monitor for pests. Apply balanced fertilizer as recommended. Keep area weed-free. Watch for any disease symptoms.'
    },
    11: {
      'name': 'Grape - Black Rot',
      'treatment': 'Prune off infected berries and leaves immediately. Apply fungicide (Captan or Sulfur) every 10-14 days. Improve air circulation through canopy management. Remove mummified berries. Sterilize pruning equipment.'
    },
    12: {
      'name': 'Grape - Esca (Black Measles)',
      'treatment': 'Prune out infected wood several inches below visible symptoms. Apply wound dressing. Remove diseased vines if severely affected. Improve air circulation. Avoid wounding during pruning. No chemical cure available.'
    },
    13: {
      'name': 'Grape - Leaf Blight (Isariopsis Leaf Spot)',
      'treatment': 'Remove infected leaves. Apply fungicide containing copper or sulfur. Improve air circulation by pruning. Avoid overhead watering. Clean up fallen leaves. Apply preventive sprays during humid conditions.'
    },
    14: {
      'name': 'Grape - Healthy',
      'treatment': 'Plant is healthy! Water deeply and regularly. Prune in late winter for shape and air circulation. Apply balanced fertilizer in early spring. Monitor for pests and diseases. Provide trellis support.'
    },
    15: {
      'name': 'Orange - Huanglongbing (Citrus Greening)',
      'treatment': 'Remove and destroy infected trees completely to prevent spread. Control Asian citrus psyllids with insecticide. Quarantine infected areas. Use disease-free nursery stock. No cure available - prevention is key. Report to agricultural authorities.'
    },
    16: {
      'name': 'Peach - Bacterial Spot',
      'treatment': 'Prune out infected branches and twigs. Apply copper-based bactericide (Copper hydroxide or Copper sulfate) in early spring. Improve air circulation. Use disease-resistant varieties if possible. Avoid overhead watering.'
    },
    17: {
      'name': 'Peach - Healthy',
      'treatment': 'Plant is healthy! Water regularly, especially during fruit development. Prune in late winter to open the canopy. Thin fruit when small (4-6 inches apart). Apply dormant oil spray in winter if needed.'
    },
    18: {
      'name': 'Pepper - Bacterial Spot',
      'treatment': 'Remove infected leaves and fruits. Apply copper-based bactericide or streptomycin. Improve air circulation and reduce humidity. Avoid overhead watering. Practice crop rotation. Sterilize tools between plants.'
    },
    19: {
      'name': 'Pepper - Healthy',
      'treatment': 'Plant is healthy! Maintain consistent watering (avoid over-watering). Provide support stakes. Monitor for pests. Apply balanced fertilizer every 3-4 weeks. Mulch around base. Ensure good air circulation.'
    },
    20: {
      'name': 'Potato - Early Blight',
      'treatment': 'Remove infected leaves and plant debris. Apply fungicide (Chlorothalonil, Mancozeb, or Metalaxyl). Improve air circulation. Mulch to prevent soil splash. Water at soil level only. Rotate crops annually.'
    },
    21: {
      'name': 'Potato - Late Blight',
      'treatment': 'Remove infected plants immediately. Apply systemic fungicide (Metalaxyl, Mancozeb, or Azoxystrobin). Improve drainage and air circulation. Use resistant varieties. Destroy infected potato debris. Avoid working in wet fields.'
    },
    22: {
      'name': 'Potato - Healthy',
      'treatment': 'Plant is healthy! Water consistently (1-2 inches per week). Hill soil around stems when plants are 6 inches tall. Monitor for pests. Apply preventive fungicide if weather favors disease. Keep area weed-free.'
    },
    23: {
      'name': 'Raspberry - Healthy',
      'treatment': 'Plant is healthy! Prune out old canes after fruiting. Water regularly during dry periods. Mulch around base. Support with trellises. Monitor for pests. Apply balanced fertilizer in spring.'
    },
    24: {
      'name': 'Soybean - Healthy',
      'treatment': 'Plant is healthy! Maintain consistent watering. Monitor for insects (aphids, beetles). Keep area weed-free. Apply balanced fertilizer if recommended by soil test. Scout regularly for disease symptoms.'
    },
    25: {
      'name': 'Squash - Powdery Mildew',
      'treatment': 'Apply sulfur powder or neem oil spray every 7-10 days. Remove heavily infected leaves. Improve air circulation by pruning excess foliage. Water at soil level only. Apply fungicide in early morning or evening.'
    },
    26: {
      'name': 'Strawberry - Leaf Scorch',
      'treatment': 'Remove infected leaves immediately. Apply fungicide (Captan or Sulfur). Improve air circulation. Mulch to prevent soil splash. Avoid overhead watering. Space plants properly for good airflow. Remove runners if needed.'
    },
    27: {
      'name': 'Strawberry - Healthy',
      'treatment': 'Plant is healthy! Water consistently, preferably in morning. Mulch between plants. Remove runners to direct energy to fruit. Apply balanced fertilizer. Monitor for pests. Remove old flowers and fruit.'
    },
    28: {
      'name': 'Tomato - Bacterial Spot',
      'treatment': 'Remove infected leaves and fruits. Apply copper-based bactericide or streptomycin sulfate. Improve air circulation with pruning. Water at soil level only. Practice crop rotation. Sterilize pruning tools frequently.'
    },
    29: {
      'name': 'Tomato - Early Blight',
      'treatment': 'Remove infected leaves from bottom of plant. Apply fungicide (Chlorothalonil, Mancozeb, or Azoxystrobin). Prune lower leaves (12 inches from soil). Improve air circulation. Mulch to prevent soil splash. Water at base only.'
    },
    30: {
      'name': 'Tomato - Late Blight',
      'treatment': 'Remove infected leaves and plant debris. Apply systemic fungicide (Metalaxyl, Mancozeb, or Chlorothalonil). Remove lower leaves. Improve drainage and air circulation. Avoid overhead watering. Destroy infected plant material.'
    },
    31: {
      'name': 'Tomato - Leaf Mold',
      'treatment': 'Improve air circulation and reduce humidity. Prune lower leaves. Apply fungicide (Sulfur or Chlorothalonil). Water at soil level only. Space plants for good airflow. Remove infected leaves promptly. Increase ventilation in greenhouse.'
    },
    32: {
      'name': 'Tomato - Septoria Leaf Spot',
      'treatment': 'Remove infected leaves immediately. Apply fungicide (Chlorothalonil, Mancozeb, or Azoxystrobin). Improve air circulation by pruning. Mulch to prevent soil splash. Water at soil level only. Rotate crops annually.'
    },
    33: {
      'name': 'Tomato - Spider Mites (Two-spotted)',
      'treatment': 'Spray with water to remove mites and dust. Apply insecticidal soap or neem oil weekly if needed. Improve humidity to discourage mites. Increase watering frequency. Remove heavily infested leaves. Use sulfur-based spray if warranted.'
    },
    34: {
      'name': 'Tomato - Target Spot',
      'treatment': 'Remove infected leaves and plant debris. Apply fungicide (Chlorothalonil, Mancozeb, or Copper-based). Improve air circulation by pruning. Water at soil level only. Mulch to prevent soil splash. Rotate crops annually.'
    },
    35: {
      'name': 'Tomato - Yellow Leaf Curl Virus',
      'treatment': 'Remove and destroy infected plants to prevent spread. Control whiteflies with insecticidal soap or neem oil. Use reflective mulch to deter insects. Plant resistant varieties. No chemical cure - prevention is critical. Quarantine infected plants.'
    },
    36: {
      'name': 'Tomato - Mosaic Virus',
      'treatment': 'Remove and destroy infected plants to prevent spread. Control aphids with insecticide. Sterilize all tools and hands with bleach solution. Use disease-resistant varieties. Avoid smoking near plants (tobacco mosaic virus). No cure available.'
    },
    37: {
      'name': 'Tomato - Healthy',
      'treatment': 'Plant is healthy! Water consistently at soil level (1-2 inches per week). Provide sturdy support/cages. Prune suckers for better airflow. Apply balanced fertilizer every 3-4 weeks. Monitor for pests and diseases regularly.'
    },
  };

  factory TFLiteIntegrate() {
    return _instance;
  }

  TFLiteIntegrate._internal();

  // Initialize and load the model
  Future<bool> loadModel([String? customPath]) async {
    try {
      String pathToLoad = customPath ?? MODEL_PATH;
      _interpreter = await Interpreter.fromAsset(pathToLoad);
      _isModelLoaded = true;
      print('✅ TFLite Model Loaded Successfully from: $pathToLoad');
      return true;
    } catch (e) {
      print('❌ Error Loading Model: $e');
      _isModelLoaded = false;
      return false;
    }
  }

  // Check if model is loaded
  bool get isModelLoaded => _isModelLoaded;

  //  Preprocess image for TFLite model
  List<List<List<List<double>>>> preprocessImage(File imageFile) {
    try {
      // Read image file
      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to model input size (224x224)
      img.Image resized = img.copyResize(
        image,
        width: INPUT_SIZE,
        height: INPUT_SIZE,
      );

      // Convert to normalized float values (0-1 range)
      List<List<List<List<double>>>> input = List.generate(
        1,
            (i) => List.generate(
          INPUT_SIZE,
              (j) => List.generate(
            INPUT_SIZE,
                (k) => List.generate(
              3,
                  (l) {
                // Get pixel value and normalize to 0-1
                var pixel = resized.getPixelSafe(k, j);
                num pixelValue = pixel.toList()[l] ?? 0;
                int value = pixelValue.toInt();
                return value / 255.0;
              },
            ),
          ),
        ),
      );

      return input;
    } catch (e) {
      print('❌ Preprocessing Error: $e');
      throw Exception('Image preprocessing failed: $e');
    }
  }

  //  Run inference on image
  Future<Map<String, dynamic>> runInference(File imageFile) async {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      // Preprocess image
      var input = preprocessImage(imageFile);

      // Prepare output
      var output = List.filled(1, List.filled(NUM_CLASSES, 0.0));

      // Run inference
      _interpreter.run(input, output);

      // Get predictions
      List<double> predictions = output[0].cast<double>();

      // Find class with highest probability
      int classIndex = 0;
      double maxConfidence = 0.0;

      for (int i = 0; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          classIndex = i;
        }
      }

      // Get disease info from map
      Map<String, String> info = diseaseInfo[classIndex] ?? {
        'name': 'Unknown Disease',
        'treatment': 'Unable to identify. Please consult an agricultural expert.'
      };

      print('✅ Inference Success - Class: ${info['name']}, Confidence: ${(maxConfidence * 100).toStringAsFixed(2)}%');

      return {
        'classIndex': classIndex,
        'confidence': (maxConfidence * 100).toStringAsFixed(2),
        'diseaseName': info['name'],
        'treatment': info['treatment'],
        'allPredictions': predictions,
      };
    } catch (e) {
      print('❌ Inference Error: $e');
      throw Exception('Inference failed: $e');
    }
  }

  //  Get detailed predictions for all classes
  Future<List<Map<String, dynamic>>> getDetailedPredictions(File imageFile) async {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded.');
    }

    try {
      var input = preprocessImage(imageFile);
      var output = List.filled(1, List.filled(NUM_CLASSES, 0.0));

      _interpreter.run(input, output);

      List<double> predictions = output[0].cast<double>();
      List<Map<String, dynamic>> results = [];

      for (int i = 0; i < predictions.length; i++) {
        results.add({
          'classIndex': i,
          'className': diseaseInfo[i]?['name'] ?? 'Unknown',
          'confidence': (predictions[i] * 100).toStringAsFixed(2),
          'probability': predictions[i],
        });
      }

      // Sort by confidence descending
      results.sort((a, b) => (b['probability'] as double).compareTo(a['probability'] as double));

      return results;
    } catch (e) {
      print('❌ Error Getting Detailed Predictions: $e');
      throw Exception('Failed to get predictions: $e');
    }
  }

  //  Dispose interpreter
  void dispose() {
    if (_isModelLoaded) {
      try {
        _interpreter.close();
        _isModelLoaded = false;
        print('✅ Model Disposed Successfully');
      } catch (e) {
        print('❌ Error Disposing Model: $e');
      }
    }
  }
}