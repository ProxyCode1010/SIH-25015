import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class RoverControlDemo extends StatelessWidget {
  const RoverControlDemo({super.key});

  // Video paths for different languages from assets
  static const Map<String, String> videoPaths = {
    'Hindi': 'assets/videos/hindi.mp4',
    'Punjabi': 'assets/videos/punjabi.mp4',
    'English': 'assets/videos/english.mp4'
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DemoVideoPlayer(
                  videoPath: videoPath,
                  language: language,
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
          'Rover Control Guide',
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
              'How Control buttons in our app is used?',
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
                      'Select an option above to view the control instructions.',
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

// Video Player Screen
class DemoVideoPlayer extends StatefulWidget {
  final String videoPath;
  final String language;

  const DemoVideoPlayer({
    required this.videoPath,
    required this.language,
    super.key,
  });

  @override
  State<DemoVideoPlayer> createState() => _DemoVideoPlayerState();
}

class _DemoVideoPlayerState extends State<DemoVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath)
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
          });
          _controller.play();
        }).catchError((error) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error loading video: $error';
          });
        });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: !isLandscape ? AppBar(
        backgroundColor: Color(0xFF1e5128),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.language} - Rover Control',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ) : null,
      body: Center(
        child: _isLoading
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
              'Loading video...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        )
            : _errorMessage != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializeVideo();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1e5128),
              ),
              child: Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        )
            : AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              CustomVideoControlsOverlay(
                controller: _controller,
                onFullScreenToggle: _toggleFullScreen,
                isFullScreen: _isFullScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Video Controls with Professional Design
class CustomVideoControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onFullScreenToggle;
  final bool isFullScreen;

  const CustomVideoControlsOverlay({
    required this.controller,
    required this.onFullScreenToggle,
    required this.isFullScreen,
    super.key,
  });

  @override
  State<CustomVideoControlsOverlay> createState() =>
      _CustomVideoControlsOverlayState();
}

class _CustomVideoControlsOverlayState extends State<CustomVideoControlsOverlay>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = true;
  bool _showControls = true;
  late VideoPlayerController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_updateStatus);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _updateStatus() {
    setState(() {
      _isPlaying = _controller.value.isPlaying;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours == 0) {
      return '$minutes:$seconds';
    }
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.removeListener(_updateStatus);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // Play/Pause overlay when paused
          if (!_isPlaying)
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
          // Controls at bottom
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
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: VideoProgressIndicator(
                      _controller,
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
                        // Play/Pause Button
                        GestureDetector(
                          onTap: () {
                            if (_isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF1e5128),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Time Display
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                _formatDuration(_controller.value.position),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                ' / ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Volume Button
                        GestureDetector(
                          onTap: () {
                            if (_controller.value.volume > 0) {
                              _controller.setVolume(0);
                            } else {
                              _controller.setVolume(1);
                            }
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              _controller.value.volume > 0
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Fullscreen/Rotate Button
                        GestureDetector(
                          onTap: widget.onFullScreenToggle,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              widget.isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                              size: 24,
                            ),
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
    );
  }
}