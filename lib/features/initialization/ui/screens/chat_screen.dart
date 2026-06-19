import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/services/chat_service.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

enum _ServerStatus { connecting, online, offline }

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  final _service = ChatService();
  String? _sessionId;
  Future<String>? _sessionFuture;
  _ServerStatus _serverStatus = _ServerStatus.connecting;

  late AnimationController _pageController;
  late Animation<double> _pageFade;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  final List<String> questions = [
    "What are the app's features?",
    "How do I communicate with a deaf person?",
    "How do I say hello in sign language?",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pageFade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);
    _pageController.forward();
    _initSpeech();
    _checkServerHealth();
    _sessionFuture = _startSession();
  }

  Future<void> _checkServerHealth() async {
    final online = await _service.checkHealth();
    if (mounted) {
      setState(() => _serverStatus = online ? _ServerStatus.online : _ServerStatus.offline);
    }
  }

  Future<String> _startSession() async {
    final id = await _service.newSession();
    _sessionId = id;
    return id;
  }

  Future<String> _ensureSession() {
    if (_sessionId != null) return Future.value(_sessionId);
    _sessionFuture ??= _startSession();
    return _sessionFuture!;
  }

  Future<void> _initSpeech() async {
    try {
   
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _speechAvailable = false;
        if (mounted) setState(() {});
        return;
      }
      _speechAvailable = await _speech.initialize(
        onError: (e) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
            final text = _inputController.text.trim();
            if (text.isNotEmpty) _sendMessage();
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      _showSnack('Please restart the app to enable the microphone');
      return;
    }

    if (_isListening) {
      try { await _speech.stop(); } catch (_) {}
      setState(() => _isListening = false);
      final text = _inputController.text.trim();
      if (text.isNotEmpty) _sendMessage();
    } else {
      _inputController.clear();
      setState(() => _isListening = true);
      try {
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _inputController.text = result.recognizedWords;
                _inputController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _inputController.text.length),
                );
              });
            }
          },
          listenOptions: stt.SpeechListenOptions(
            partialResults: true,
            autoPunctuation: true,
            listenFor: const Duration(seconds: 15),
            pauseFor: const Duration(seconds: 3),
          ),
        );
      } catch (_) {
        setState(() => _isListening = false);
        _showSnack('Could not start the microphone, please restart the app');
      }
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1A1D2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _speech.stop();
    _pageController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Send a message ──────────────────────────────────────
  void _sendMessage([String? override]) async {
    final text = override ?? _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    String reply;
    try {
      final sessionId = await _ensureSession();
      reply = await _service.sendMessage(sessionId: sessionId, message: text);
    } catch (_) {
      reply = "Sorry, I couldn't reach the server. Please check your connection and try again.";
    }
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: reply, isUser: false));
    });
    _scrollToBottom();
  }

  Future<void> _clearChat() async {
    final sessionId = _sessionId;
    setState(() {
      _messages.clear();
      _sessionId = null;
    });
    if (sessionId != null) {
      try {
        await _service.deleteHistory(sessionId);
      } catch (_) {}
    }
    _sessionFuture = _startSession();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0F1A), Color(0xFF0A0C15), Color(0xFF080910)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Container(height: 1.h, color: Colors.white.withValues(alpha: 0.08)),
              Expanded(
                child: _messages.isEmpty
                    ? _buildCommonQuestions()
                    : _buildMessageList(),
              ),
              if (_isTyping) _buildTypingIndicator(),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

 
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _pageFade,
      child: Padding(
        padding: EdgeInsets.only(top: 16.h, left: 4.w, right: 20.w, bottom: 12.h),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new,
                  color: Colors.white38, size: 20.sp),
            ),
            SizedBox(width: 2.w),

            RobotIcon(size: 40.w),

            SizedBox(width: 10.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign Assistant',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF7C3AED),
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    switch (_serverStatus) {
                      _ServerStatus.online => '• Online',
                      _ServerStatus.offline => '• Offline',
                      _ServerStatus.connecting => '• Connecting…',
                    },
                    style: TextStyle(
                      color: switch (_serverStatus) {
                        _ServerStatus.online => Colors.green,
                        _ServerStatus.offline => Colors.red,
                        _ServerStatus.connecting => Colors.orange,
                      },
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: _messages.isEmpty ? null : _clearChat,
              icon: Icon(Icons.refresh_rounded,
                  color: _messages.isEmpty ? Colors.white12 : Colors.white38, size: 22.sp),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCommonQuestions() {
    return FadeTransition(
      opacity: _pageFade,
      child: Column(
        children: [
          SizedBox(height: 28.h),

          Icon(
            Icons.edit_outlined,
            color: Colors.white.withValues(alpha: 0.15),
            size: 30.sp,
          ),

          SizedBox(height: 6.h),

          Text(
            'Common Question',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.15),
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 18.h),

          
          ...List.generate(
            questions.length,
            (index) => _buildQuestionCard(questions[index], index),
          ),
        ],
      ),
    );
  }

  
  Widget _buildQuestionCard(String title, int index) {
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Interval(
        0.2 + (index * 0.15),
        0.7 + (index * 0.15),
        curve: Curves.easeOutBack,
      ),
    ));

    final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Interval(
          0.2 + (index * 0.15),
          0.7 + (index * 0.15),
          curve: Curves.easeOut,
        ),
      ),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: GestureDetector(
          onTap: () => _sendMessage(title),
          child: Container(
            height: 52.h,
            margin: EdgeInsets.symmetric(horizontal: 28.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

 
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28.w, height: 28.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D2E),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: RobotIcon(size: 28.w),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: msg.isUser ? const Color(0xFF7C3AED) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(msg.isUser ? 18.r : 4.r),
                  bottomRight: Radius.circular(msg.isUser ? 4.r : 18.r),
                ),
              ),
              child: Text(
                msg.text,
                softWrap: true,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 15.sp,
                  height: 1.55,
                ),
              ),
            ),
          ),
          if (msg.isUser) SizedBox(width: 8.w),
        ],
      ),
    );
  }


  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, bottom: 4.h),
      child: Row(
        children: [
          Container(
            width: 28.w, height: 28.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: RobotIcon(size: 28.w),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18.r)),
            child: _TypingDots(),
          ),
        ],
      ),
    );
  }

  
  Widget _buildInputBar() {
    return FadeTransition(
      opacity: _pageFade,
      child: Container(
        margin: EdgeInsets.all(18.w),
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D2E),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                cursorColor: Colors.white,
                cursorWidth: 2,
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: 15.sp,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: _isListening
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _isListening ? Colors.red : Colors.white,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: _sendMessage,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.9, end: 1.0),
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 36.w, height: 36.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded,
                      color: Colors.white, size: 20.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class RobotIcon extends StatelessWidget {
  final double size;
  const RobotIcon({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
         
          Container(
            width: size * 0.72,
            height: size * 0.62,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(size * 0.18),
            ),
          ),
          
          Positioned(
            top: size * 0.06,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size * 0.08,
                  height: size * 0.08,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: size * 0.06,
                  height: size * 0.1,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // العينان
          Positioned(
            top: size * 0.32,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _eye(size),
                SizedBox(width: size * 0.14),
                _eye(size),
              ],
            ),
          ),
          // الفم
          Positioned(
            bottom: size * 0.16,
            child: Container(
              width: size * 0.36,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(size * 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eye(double size) => Container(
        width: size * 0.13,
        height: size * 0.13,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
}


class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrls[i],
          builder: (context, child) => Container(
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: 7.w, height: 7.w,
            decoration: BoxDecoration(
              color: Color.lerp(
                  const Color(0xFFAAAAAA), const Color(0xFF1A1A2E), _ctrls[i].value),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
