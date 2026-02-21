import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class DiseaseCheckDemo extends StatelessWidget {
  const DiseaseCheckDemo({super.key});

  // Video paths for different languages from assets
  static const Map<String, String> videoPaths = {
    'Hindi': 'assets/videos/hindii.mp4',
    'Punjabi': 'assets/videos/eng.mp4',
    'English': 'assets/videos/punjabii.mp4'
  };

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Choose Language to See Video',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0d3b1f),
                ),
              ),
              SizedBox(height: 24),

              // Language Options
              ..._buildLanguageOptions(context),

              SizedBox(height: 16),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFcce5cc),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Color(0xFF0d3b1f),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLanguageOptions(BuildContext context) {
    return videoPaths.entries.map((entry) {
      String language = entry.key;
      String videoPath = entry.value;

      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            // Navigate to video player screen with selected language
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiseaseVideoPlayerScreen(
                  initialLanguage: language,
                  videoPaths: videoPaths,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFe8f5e9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF2d6a4f),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Color(0xFF1e5128),
                  size: 28,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    language,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1e5128),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF2d6a4f),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F9F0),
      appBar: AppBar(
        backgroundColor: Color(0xFF1e5128),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Disease Detection Guide',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Text
            Text(
              'How to use Disease Detection feature?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0d3b1f),
              ),
            ),
            SizedBox(height: 24),

            // Interactive Buttons Row
            Row(
              children: [
                // Text Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Showing text explanation'),
                          backgroundColor: Color(0xFF1e5128),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(Icons.text_fields, size: 20),
                    label: Text(
                      'Text',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2d6a4f),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Video Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showLanguageBottomSheet(context);
                    },
                    icon: Icon(Icons.play_circle_outline, size: 20),
                    label: Text(
                      'See Video',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1e5128),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Info Container
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF2d6a4f),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select an option above to learn about disease detection.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF558b5f),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Video Player Screen with Tabs
class DiseaseVideoPlayerScreen extends StatefulWidget {
  final String initialLanguage;
  final Map<String, String> videoPaths;

  const DiseaseVideoPlayerScreen({
    required this.initialLanguage,
    required this.videoPaths,
    super.key,
  });

  @override
  State<DiseaseVideoPlayerScreen> createState() =>
      _DiseaseVideoPlayerScreenState();
}

class _DiseaseVideoPlayerScreenState extends State<DiseaseVideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, VideoPlayerController> _controllers;
  late String _currentLanguage;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage;

    // Initialize TabController
    final languages = widget.videoPaths.keys.toList();
    final initialIndex = languages.indexOf(_currentLanguage);
    _tabController = TabController(
      length: languages.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );

    // Initialize video controllers
    _controllers = {};
    _initializeControllers();

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newLanguage = languages[_tabController.index];
        if (newLanguage != _currentLanguage) {
          _switchLanguage(newLanguage);
        }
      }
    });
  }

  Future<void> _initializeControllers() async {
    for (var entry in widget.videoPaths.entries) {
      final language = entry.key;
      final path = entry.value;

      try {
        final controller = VideoPlayerController.asset(path);
        _controllers[language] = controller;

        if (language == _currentLanguage) {
          try {
            await controller.initialize();
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              controller.play();
            }
          } catch (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Video not found. Please check:\n1. Video file exists in assets folder\n2. Path in pubspec.yaml is correct\n\nPath: $path';
              });
            }
          }
        }
      } catch (e) {
        if (language == _currentLanguage && mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load video.\nPlease ensure video is added to assets folder.\n\nPath: $path';
          });
        }
      }
    }
  }

  Future<void> _switchLanguage(String newLanguage) async {
    // Pause current video
    final currentController = _controllers[_currentLanguage];
    if (currentController != null && currentController.value.isInitialized) {
      currentController.pause();
    }

    setState(() {
      _currentLanguage = newLanguage;
      _isLoading = true;
      _errorMessage = null;
    });

    // Play new video
    final newController = _controllers[newLanguage];
    if (newController != null) {
      if (newController.value.isInitialized) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          newController.play();
        }
      } else {
        try {
          await newController.initialize();
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            newController.play();
          }
        } catch (error) {
          if (mounted) {
            final path = widget.videoPaths[newLanguage] ?? '';
            setState(() {
              _isLoading = false;
              _errorMessage = 'Video not found. Please check:\n1. Video file exists in assets folder\n2. Path in pubspec.yaml is correct\n\nPath: $path';
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controllers.values.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languages = widget.videoPaths.keys.toList();
    final currentController = _controllers[_currentLanguage];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF1e5128),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Disease Detection Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          tabs: languages.map((lang) {
            return Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentLanguage == lang)
                    Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.play_circle_filled, size: 18),
                    ),
                  Text(lang),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe
        children: languages.map((language) {
          final isCurrentLanguage = language == _currentLanguage;

          return Center(
            child: _isLoading && isCurrentLanguage
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF1e5128),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading $language video...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            )
                : _errorMessage != null && isCurrentLanguage
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });

                    // Dispose old controllers
                    _controllers.values.forEach((controller) {
                      controller.dispose();
                    });
                    _controllers.clear();

                    // Re-initialize
                    _initializeControllers();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1e5128),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            )
                : currentController != null &&
                currentController.value.isInitialized &&
                isCurrentLanguage
                ? AspectRatio(
              aspectRatio: currentController.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(currentController),
                  VideoControlsOverlay(
                    controller: currentController,
                    language: language,
                  ),
                ],
              ),
            )
                : Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  'Switch to $language tab to play video',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Video Controls Overlay
class VideoControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final String language;

  const VideoControlsOverlay({
    required this.controller,
    required this.language,
    super.key,
  });

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.controller.value.isPlaying;

    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Center Play/Pause Button
            if (!isPlaying)
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

            // Bottom Controls
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Progress Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: VideoProgressIndicator(
                        widget.controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: Color(0xFF1e5128),
                          bufferedColor: Color(0xFF1e5128).withOpacity(0.5),
                          backgroundColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Control Buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Play/Pause
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isPlaying) {
                                  widget.controller.pause();
                                } else {
                                  widget.controller.play();
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF1e5128),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),

                          // Time
                          Expanded(
                            child: Text(
                              '${_formatDuration(widget.controller.value.position)} / ${_formatDuration(widget.controller.value.duration)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Volume
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (widget.controller.value.volume > 0) {
                                  widget.controller.setVolume(0);
                                } else {
                                  widget.controller.setVolume(1);
                                }
                              });
                            },
                            child: Icon(
                              widget.controller.value.volume > 0
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}