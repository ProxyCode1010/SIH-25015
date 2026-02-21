import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:vrikshanova/navigation/bottom_nav/disease_diagnosis/tfilite_integrate.dart';
import 'package:vrikshanova/navigation/custom_navscreen.dart';

class DiseaseCheck extends StatefulWidget {
  const DiseaseCheck({super.key});

  @override
  State<DiseaseCheck> createState() => _DiseaseCheckState();
}

class _DiseaseCheckState extends State<DiseaseCheck> with TickerProviderStateMixin {
  // --- State Variables ---
  int _currentIndex = 1;
  File? _selectedImage;
  bool _isLoading = false;
  bool _diseaseDetected = false;
  bool _isPlantImage = true;
  bool _modelLoaded = false;

  String _plantType = 'Unknown Plant';
  String _diseaseName = 'No disease detected';
  String _confidence = '0%';
  String _treatment = 'No recommendations available.';

  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _loadingController;
  late TFLiteIntegrate _tfliteService;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _initializeTFLite();
  }

  // 👇 Initialize TFLite Model
  Future<void> _initializeTFLite() async {
    try {
      _tfliteService = TFLiteIntegrate();
      bool loaded = await _tfliteService.loadModel('assets/model/plant_disease_model.tflite');

      setState(() {
        _modelLoaded = loaded;
      });

      if (loaded) {
        print('✅ TFLite Model initialized successfully');
      } else {
        print('❌ Failed to load TFLite Model');
        if (mounted) {
          _showErrorSnackBar('Model failed to load. Check your assets.', color: Colors.red);
        }
      }
    } catch (e) {
      print('❌ Error initializing TFLite: $e');
      if (mounted) {
        _showErrorSnackBar('Error initializing model: $e', color: Colors.red);
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message, {Color color = Colors.red}) {
    if (mounted) {
      final displayMessage = message.length > 100 ? '${message.substring(0, 97)}...' : message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayMessage),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      _diseaseDetected = false;
      _isPlantImage = true;
      _plantType = 'Unknown Plant';
      _diseaseName = 'No disease detected';
      _confidence = '0%';
      _treatment = 'No recommendations available.';
    });
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (photo != null) {
        if (mounted) {
          Navigator.pop(context);
          await _processImage(File(photo.path));
        }
      }
    } catch (e) {
      _showErrorSnackBar('कैमरा त्रुटि: कृपया परमीशन (permissions) जाँचें।');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        if (mounted) {
          Navigator.pop(context);
          await _processImage(File(image.path));
        }
      }
    } catch (e) {
      _showErrorSnackBar('गैलरी त्रुटि: कृपया परमीशन (permissions) जाँचें।');
    }
  }

  // 👇 Check Disease using TFLite Model
  Future<void> _checkDisease() async {
    if (_selectedImage == null || _isLoading) {
      _showErrorSnackBar("कृपया पहले एक फोटो चुनें।", color: Colors.orange);
      return;
    }

    if (!_modelLoaded) {
      _showErrorSnackBar("मॉडल अभी लोड हो रहा है। कृपया प्रतीक्षा करें।", color: Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _diseaseDetected = false;
      _plantType = 'विश्लेषण कर रहा है...';
      _diseaseName = 'विश्लेषण कर रहा है...';
      _treatment = 'सिस्टम इमेज का विश्लेषण कर रहा है, कृपया प्रतीक्षा करें...';
    });
    _loadingController.repeat();

    try {
      // 👇 Run TFLite Inference
      final results = await _tfliteService.runInference(_selectedImage!);

      if (!mounted) return;

      setState(() {
        _diseaseDetected = true;
        _diseaseName = results['diseaseName'] ?? 'Unknown Disease';
        _confidence = '${results['confidence']}%';
        _plantType = 'पौधा पहचाना गया';
        _treatment = results['treatment'] ?? 'No recommendations available.';
      });

      // Show success message if plant is healthy
      if (results['diseaseName'].toString().toLowerCase().contains('healthy')) {
        _showErrorSnackBar("पौधा स्वस्थ है!", color: Colors.green);
      }

    } catch (e) {
      print('❌ Disease Check Error: $e');
      _showErrorSnackBar('विश्लेषण में त्रुटि: ${e.toString()}', color: Colors.red);

      if (mounted) {
        setState(() {
          _diseaseDetected = false;
          _plantType = 'Unknown Plant';
          _diseaseName = 'No disease detected';
          _confidence = '0%';
          _treatment = 'No recommendations available.';
        });
      }
    } finally {
      _loadingController.stop();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImageDialog(BuildContext context) {
    if (_selectedImage == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(_selectedImage!, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Image Source',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.grey, size: 28),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Use your camera to capture the plant.',
                  onTap: _pickImageFromCamera,
                ),
                const SizedBox(height: 16),
                _buildImageSourceOption(
                  icon: Icons.image,
                  title: 'Choose from Gallery',
                  subtitle: 'Select a photo from your local storage.',
                  onTap: _pickImageFromGallery,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4CAF50), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF4CAF50), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: label == 'Plant'
                ? const Color(0xFFE8F5E9)
                : label == 'Confidence'
                ? const Color(0xFFFFF9C4)
                : const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: label == 'Plant'
                      ? const Color(0xFF4CAF50)
                      : label == 'Confidence'
                      ? const Color(0xFFFBC02D)
                      : Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildTreatmentList(String treatmentText) {
    final points =
    treatmentText.split('.').where((s) => s.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Icon(Icons.check_circle_outline,
                      size: 16, color: Color(0xFF4CAF50))),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(point.trim(),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeverityBar(double confidenceLevel) {
    final progressValue = confidenceLevel / 100.0;
    final color = progressValue > 0.8
        ? Colors.red
        : progressValue > 0.5
        ? Colors.orange
        : const Color(0xFF4CAF50);
    final label = progressValue > 0.8
        ? 'उच्च गंभीरता'
        : progressValue > 0.5
        ? 'मध्यम जोखिम'
        : 'कम जोखिम';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('गंभीरता स्तर: $label',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      height: 80.0 + statusBarHeight,
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Card(
            elevation: 6,
            color: const Color(0xFF2E5339),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                  splashColor: Colors.white24,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Text(
                      'Plant Disease Check',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double getConfidenceValue() {
      final String confidenceString =
      _confidence.replaceAll('%', '').trim();
      return double.tryParse(confidenceString) ?? 0.0;
    }

    final bool showCenteredUpload =
        _selectedImage == null || !_diseaseDetected;

    return Scaffold(
      bottomNavigationBar: CustomNavscreen(
          currentIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          screenContext: context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: _buildCustomAppBar(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF1F8F6),
              Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: showCenteredUpload
              ? Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showImagePickerBottomSheet,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(28),
                      padding: _selectedImage != null
                          ? EdgeInsets.zero
                          : const EdgeInsets.all(20),
                      color: const Color(0xFF4CAF50),
                      strokeWidth: 2.5,
                      dashPattern: const [10, 8],
                      child: Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(28),
                          child: Image.file(_selectedImage!,
                              fit: BoxFit.cover),
                        )
                            : Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                  color:
                                  const Color(0xFFE8F5E9),
                                  borderRadius:
                                  BorderRadius.circular(16)),
                              child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: Color(0xFF4CAF50)),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                                'Tap to Upload Plant Photo',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const SizedBox(height: 8),
                            const Text(
                                'High-quality image for better accuracy',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedImage != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _checkDisease,
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? const Color(0xFF66BB6A)
                                : const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF4CAF50)
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? AnimatedBuilder(
                              animation: _loadingController,
                              builder: (context, child) {
                                return SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      valueColor:
                                      const AlwaysStoppedAnimation(
                                          Colors.white),
                                      strokeWidth: 3,
                                      value: _loadingController
                                          .value),
                                );
                              },
                            )
                                : const Text('Check Disease',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 12),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showImageDialog(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF4CAF50), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility,
                                color: Color(0xFF4CAF50)),
                            SizedBox(width: 8),
                            Text('View Uploaded Image',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: _diseaseName == 'स्वस्थ!' ||
                                        _diseaseName == 'Healthy'
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFE0E0),
                                    borderRadius:
                                    BorderRadius.circular(12)),
                                child: Icon(
                                    _diseaseName == 'स्वस्थ!' ||
                                        _diseaseName == 'Healthy'
                                        ? Icons.check_circle
                                        : Icons.bug_report,
                                    color: _diseaseName == 'स्वस्थ!' ||
                                        _diseaseName == 'Healthy'
                                        ? const Color(0xFF4CAF50)
                                        : Colors.red,
                                    size: 28),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text('Diagnosis Result',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey)),
                                  Text(_diseaseName,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _diseaseName ==
                                              'स्वस्थ!' ||
                                              _diseaseName == 'Healthy'
                                              ? const Color(0xFF4CAF50)
                                              : Colors.red)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildResultRow('Plant', _plantType),
                          const SizedBox(height: 16),
                          _buildResultRow('Confidence', _confidence),
                          const SizedBox(height: 24),
                          if (_diseaseName != 'स्वस्थ!' &&
                              _diseaseName != 'Healthy' &&
                              _diseaseName != 'अस्पष्ट परिणाम')
                            _buildSeverityBar(getConfidenceValue()),
                          if (_diseaseName != 'स्वस्थ!' &&
                              _diseaseName != 'Healthy' &&
                              _diseaseName != 'अस्पष्ट परिणाम')
                            const SizedBox(height: 24),
                          const Text('Recommended Treatment 💊',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius:
                                BorderRadius.circular(12)),
                            child: _buildTreatmentList(_treatment),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                        _diseaseDetected = false;
                                      });
                                    },
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets
                                          .symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(
                                                  0xFF4CAF50),
                                              width: 2),
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                      child: const Center(
                                          child: Text('Check New',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Color(
                                                      0xFF4CAF50)))),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets
                                          .symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                      child: const Center(
                                          child: Text(
                                              'Get Expert Help',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors
                                                      .white))),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}