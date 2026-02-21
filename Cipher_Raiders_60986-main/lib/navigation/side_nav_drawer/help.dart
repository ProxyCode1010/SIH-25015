import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? expandedIndex;

  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I get started with the app?',
      'answer': 'Simply create an account, complete your profile, and explore the features. Our onboarding guide will help you through the process.'
    },
    {
      'question': 'How can I reset my password?',
      'answer': 'Go to Settings > Account > Change Password. You can also use the "Forgot Password" option on the login screen.'
    },
    {
      'question': 'Is my data secure?',
      'answer': 'Yes! We use industry-standard encryption and security measures to protect your data. Your privacy is our top priority.'
    },
    {
      'question': 'How do I contact support?',
      'answer': 'You can reach us through the social media icons at the bottom right, or email us at ciphers.raiders2025@gmail.com'
    },
    {
      'question': 'Can I use the app offline?',
      'answer': 'Some features are available offline, but you\'ll need an internet connection for real-time updates and synchronization.'
    },
  ];

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Color(0xFF1e5128),
          ),
        );
      }
    }
  }

  Future<void> _openLiveChat() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LiveChatBottomSheet(),
    );
  }

  Future<void> _openEmailUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ciphers.raiders2025@gmail.com',
      query: 'subject=Help & Support Request',
    );
    await _launchUrl(emailUri.toString());
  }

  Widget _buildCustomAppBar(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.transparent,
      height: 80.0 + statusBarHeight,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Card(
            elevation: 6,
            color: Color(0xFF1e5128),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashColor: Colors.white24,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Help & FAQ's",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.support_agent, color: Colors.white),
                  onPressed: () {
                    _openLiveChat();
                  },
                  splashColor: Colors.white24,
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
    return Scaffold(
      backgroundColor: Color(0xFFf0f9f0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: _buildCustomAppBar(context),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1e5128), Color(0xFF2d6a4f)],
                    ),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.help_outline_rounded,
                                size: 64,
                                color: Color(0xFF1e5128),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Ciphers Raiders',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'We\'re here to help you',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFe8f5e9),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Quick Help Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: Icons.chat_bubble_outline,
                          title: 'Live Chat',
                          color: Color(0xFF2d6a4f),
                          onTap: _openLiveChat,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: Icons.email_outlined,
                          title: 'Email Us',
                          color: Color(0xFF4285f4),
                          onTap: _openEmailUs,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // FAQ Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e5128),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // FAQ List
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    return _buildFAQItem(
                      question: faqs[index]['question']!,
                      answer: faqs[index]['answer']!,
                      index: index,
                    );
                  },
                ),
              ],
            ),
          ),

          // Social Media Icons - Bottom Right
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSocialIcon(
                  icon: FontAwesomeIcons.whatsapp,
                  color: Color(0xFF25D366),
                  onTap: () => _launchUrl('https://wa.me/919718751020'),
                ),
                SizedBox(height: 12),
                _buildSocialIcon(
                  icon: FontAwesomeIcons.instagram,
                  color: Color(0xFFE4405F),
                  onTap: () => _launchUrl('https://instagram.com/cipherraiders'),
                ),
                SizedBox(height: 12),
                _buildSocialIcon(
                  icon: FontAwesomeIcons.phone,
                  color: Color(0xFF4CAF50),
                  onTap: () => _launchUrl('tel:+919718751020'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1e5128).withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1e5128),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required int index,
  }) {
    bool isExpanded = expandedIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1e5128).withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFa8d5ba).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.help_outline,
                          color: Color(0xFF1e5128),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1e5128),
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Color(0xFF2d6a4f),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: SizedBox.shrink(),
                    secondChild: Padding(
                      padding: EdgeInsets.only(top: 12, left: 40),
                      child: Text(
                        answer,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF558b5f),
                          height: 1.5,
                        ),
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FaIcon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// Live Chat Bottom Sheet
class LiveChatBottomSheet extends StatefulWidget {
  const LiveChatBottomSheet({super.key});

  @override
  State<LiveChatBottomSheet> createState() => _LiveChatBottomSheetState();
}

class _LiveChatBottomSheetState extends State<LiveChatBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  final List<String> _quickQuestions = [
    'How do I reset my password?',
    'How to contact support?',
    'App features information',
    'Account and privacy settings',
    'Technical issues and troubleshooting',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add({
      'text': 'Hello! Welcome to Ciphers.Raiders support. How can I help you today?',
      'isUser': false,
      'time': _getCurrentTime(),
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'time': _getCurrentTime(),
      });
    });

    _messageController.clear();

    // Simulate bot response
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': _getBotResponse(text),
            'isUser': false,
            'time': _getCurrentTime(),
          });
        });
      }
    });
  }

  String _getBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('password') || lowerMessage.contains('reset')) {
      return 'To reset your password, go to Settings > Account > Change Password. You can also use "Forgot Password" on the login screen.';
    } else if (lowerMessage.contains('contact') || lowerMessage.contains('support')) {
      return 'You can reach us via email at ciphers.raiders2025@gmail.com or WhatsApp at +91 9718751020. We typically respond within 24 hours.';
    } else if (lowerMessage.contains('feature') || lowerMessage.contains('app')) {
      return 'Our app includes rover control, disease detection, real-time monitoring, and more! Explore the home screen to see all features.';
    } else if (lowerMessage.contains('account') || lowerMessage.contains('privacy')) {
      return 'Your data is secure with us. We use industry-standard encryption. You can manage your privacy settings in the Settings menu.';
    } else if (lowerMessage.contains('technical') || lowerMessage.contains('issue') || lowerMessage.contains('problem')) {
      return 'For technical issues, please try restarting the app first. If the problem persists, contact us at ciphers.raiders2025@gmail.com with details.';
    } else {
      return 'Thank you for your message! For more detailed assistance, please email us at ciphers.raiders2025@gmail.com or choose a quick question below.';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1e5128),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Support',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Online now',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Quick Questions
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickQuestions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _sendMessage(_quickQuestions[index]),
                    child: Chip(
                      label: Text(
                        _quickQuestions[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1e5128),
                        ),
                      ),
                      backgroundColor: Color(0xFFe8f5e9),
                      side: BorderSide(color: Color(0xFF1e5128).withOpacity(0.3)),
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message['text'],
                  message['isUser'],
                  message['time'],
                );
              },
            ),
          ),

          // Input Field
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1e5128),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFF1e5128),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent, color: Colors.white, size: 16),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? Color(0xFF1e5128) : Color(0xFFe8f5e9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Color(0xFF1e5128),
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isUser)
            Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }
}