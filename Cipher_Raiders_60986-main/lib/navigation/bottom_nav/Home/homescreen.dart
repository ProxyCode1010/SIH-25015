import 'package:flutter/material.dart';
import 'package:vrikshanova/homescreen_card/disease_check_demo.dart';
import 'package:vrikshanova/homescreen_card/rover_control_demo.dart' hide VideoPlayerScreen;
import 'package:vrikshanova/navigation/bottom_nav/Home/video_player.dart';
import 'package:vrikshanova/navigation/bottom_nav/Home/weather.dart';
import 'package:vrikshanova/navigation/bottom_nav/disease_diagnosis/disease_diagnosis.dart';
import 'package:vrikshanova/navigation/custom_navscreen.dart';
import 'package:video_player/video_player.dart';


// Vrikshanova App Color Palette
const Color kDarkGreen = Color(0xFF2E5339);

// Feedback Bottom Sheet Dialog
class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> with SingleTickerProviderStateMixin {
  late TextEditingController _problemsController;
  late TextEditingController _feedbackController;
  late AnimationController _animationController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _problemsController = TextEditingController();
    _feedbackController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _problemsController.dispose();
    _feedbackController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_problemsController.text.isEmpty || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: kDarkGreen,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut)),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Share Your Feedback',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: kDarkGreen,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Problems Text Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Problems',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _problemsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe any issues you faced...',
                        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: kDarkGreen,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Feedback Text Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Write Your Valuable Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share your suggestions and improvements...',
                        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: kDarkGreen,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
                      disabledBackgroundColor: kDarkGreen.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SEPARATE CARD WIDGET
class FeatureCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradientColors;
  final Color iconColor;
  final VoidCallback? onTap;

  const FeatureCardWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.gradientColors,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: kDarkGreen, width: 3),
          boxShadow: [
            BoxShadow(
              color: kDarkGreen.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: iconColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom AppBar
class CustomThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomThemedAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.transparent,
      height: preferredSize.height + statusBarHeight,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Card(
            elevation: 6,
            color: kDarkGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    if (Scaffold.of(context).hasDrawer) {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                  splashColor: Colors.white24,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Vrikshanova 🌿',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cloudy_snowing, color: Colors.white),
                  onPressed: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherInfo()))
                    
                  },
               //   onPressed: null,
                  splashColor: Colors.white24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Video Card Widget with Inline Player
class VideoCard extends StatefulWidget {
  final String videoPath;
  final String title;
  final String duration;
  final VoidCallback onFullScreen;

  const VideoCard({
    Key? key,
    required this.videoPath,
    required this.title,
    required this.duration,
    required this.onFullScreen,
  }) : super(key: key);

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }).catchError((error) {
        print('Error initializing video: $error');
      });

    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            // Video Player or Loading
            Positioned.fill(
              child: _isInitialized
                  ? GestureDetector(
                onTap: _togglePlayPause,
                child: VideoPlayer(_controller),
              )
                  : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF66BB6A),
                      Color(0xFF81C784),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Dark Overlay when paused
            if (!_isPlaying)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

            // Play/Pause Button
            if (!_isPlaying)
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: kDarkGreen,
                      size: 45,
                    ),
                  ),
                ),
              ),

            // Duration Badge (Top Right)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Fullscreen Button (Top Left)
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: widget.onFullScreen,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Video Title (Bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isPlaying ? 'Playing...' : 'Tap to play',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
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

// HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _imageAssets = [
    'assets/images/front.png',
    'assets/images/right_side.png',
    'assets/images/left_side.png',
    'assets/images/all.png',
    'assets/images/back.png',
  ];

  // Gallery Videos Data
  final List<Map<String, String>> _galleryVideos = [

    {
      'video': 'assets/videos/trailer.mp4',
      'title': 'Introduction',
      'duration': '1:18'
    },

    {
      'video': 'assets/videos/demo.mp4',
      'title': 'Farmer Suffering',
      'duration': '2:45'
    },

    {
      'video': 'assets/videos/farmer1.mp4',
      'title': 'Farmer Review 1',
      'duration': '1:24'
    },
    {
      'video': 'assets/videos/farmer2.mp4',
      'title': 'Farmer Review 2',
      'duration': '1:41'
    },
    {
      'video': 'assets/videos/farmer3.mp4',
      'title': 'Farmer Review 3',
      'duration': '1:50'
    },
    // {
    //   'video': 'assets/videos/rover.mp4',
    //   'title': 'Data Analysis',
    //   'duration': '0:25'
    // },
  ];

  static const double bannerHeight = 200.0;

  // Helper method to build feature cards with gradient
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required Color iconColor,
    bool isFullWidth = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped')),
        );
      },
      child: Container(
        height: isFullWidth ? 140 : 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: kDarkGreen, width: 3),
          boxShadow: [
            BoxShadow(
              color: kDarkGreen.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isFullWidth ? 50 : 60,
              color: iconColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isFullWidth ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double viewportFraction = 0.85;

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: CustomThemedAppBar(),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFC8E6C9),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),

              // 1. PAGEVIEW.BUILDER (Banner Slider)
              Container(
                height: bannerHeight,
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFC8E6C9),
                      Color(0xFFE8F5E9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: kDarkGreen.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageAssets.length,
                  controller: PageController(
                    viewportFraction: viewportFraction,
                    initialPage: 0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          _imageAssets[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                child: const Text(
                  'App features',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
              ),

              // 2. FEATURE CARDS USING SEPARATE CARD WIDGET WITH NAVIGATION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: FeatureCardWidget(
                        icon: Icons.gamepad_outlined,
                        title: 'Rover\nControl',
                        gradientColors: const [
                          Color(0xFFA5D6A7),
                          Color(0xFFE8F5E9),
                        ],
                        iconColor: kDarkGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoverControlDemo(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FeatureCardWidget(
                        icon: Icons.eco,
                        title: 'Disease\nCheck',
                        gradientColors: const [
                          Color(0xFF81C784),
                          Color(0xFFA5D6A7),
                        ],
                        iconColor: kDarkGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  DiseaseCheckDemo(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // const SizedBox(height: 12),

              //// 3. ANALYSIS CARD (Full Width) - WITH GRADIENT
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: _buildFeatureCard(
              //     icon: Icons.trending_up,
              //     title: 'Analysis',
              //     gradientColors: const [
              //       Color(0xFFA5D6A7),
              //       Color(0xFFE8F5E9),
              //     ],
              //     iconColor: kDarkGreen,
              //     isFullWidth: true,
              //   ),
              // ),

              const SizedBox(height: 30),

              // 4. OUR GALLERY SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Our Gallery',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View All clicked')),
                        );
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: kDarkGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 5. VIDEO GALLERY WITH INLINE PLAYERS
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _galleryVideos.length,
                  itemBuilder: (context, index) {
                    final video = _galleryVideos[index];
                    return VideoCard(
                      videoPath: video['video']!,
                      title: video['title']!,
                      duration: video['duration']!,
                      onFullScreen: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              videoPath: video['video']!,
                              title: video['title']!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 6. FEEDBACK BUTTON (NEW)
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: GestureDetector(
              //     onTap: _showFeedbackBottomSheet,
              //     child: Container(
              //       height: 56,
              //       decoration: BoxDecoration(
              //         gradient: const LinearGradient(
              //           colors: [
              //             Color(0xFF4CAF50),
              //             kDarkGreen,
              //           ],
              //           begin: Alignment.topLeft,
              //           end: Alignment.bottomRight,
              //         ),
              //         borderRadius: BorderRadius.circular(14),
              //         boxShadow: [
              //           BoxShadow(
              //             color: kDarkGreen.withOpacity(0.25),
              //             spreadRadius: 0,
              //             blurRadius: 12,
              //             offset: const Offset(0, 4),
              //           ),
              //         ],
              //       ),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Icon(
              //             Icons.feedback_outlined,
              //             color: Colors.white,
              //             size: 24,
              //           ),
              //           const SizedBox(width: 12),
              //           const Text(
              //             'Share Your Valuable Feedback',
              //             style: TextStyle(
              //               fontSize: 16,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.white,
              //               letterSpacing: 0.3,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              //
              // const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      drawer: CustomSideDrawer(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: CustomNavscreen(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        screenContext: context,
      ),
    );
  }
}