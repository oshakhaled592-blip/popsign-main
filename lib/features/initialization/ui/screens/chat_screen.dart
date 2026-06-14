import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

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



  late AnimationController _pageController;
  late Animation<double> _pageFade;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  final List<String> questions = [
    "ما هي مميزات التطبيق؟",
    "كيف أتواصل مع شخص أصم؟",
    "كيف أقول مرحبا بلغة الإشارة؟",
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
      _showSnack('أوقف التطبيق وأعِد تشغيله لتفعيل الميكروفون');
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
        _showSnack('تعذّر تشغيل الميكروفون، أعِد تشغيل التطبيق');
      }
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1A2030),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  String _getResponse(String input) {
    final q = input.trim().toLowerCase();

    if (_matches(q, ['مرحبا', 'هاي', 'اهلا', 'السلام', 'صباح', 'مساء', 'hi', 'hello'])) {
      return 'أهلاً وسهلاً بك! 😊\nأنا هنا لمساعدتك في كل ما يتعلق بتطبيق PopSign وتعلم لغة الإشارة. ما الذي تريد معرفته؟';
    }
    if (_matches(q, ['مميزات', 'ميزة', 'features', 'يعمل', 'فيه ايه', 'بيعمل'])) {
      return 'تطبيق PopSign يتميز بثلاث مميزات رئيسية:\n\n'
          '🤟 1. تحليل لغة الإشارة\nيستخدم الذكاء الاصطناعي لتحليل إشارات لغة الإشارة في الوقت الفعلي.\n\n'
          '🌍 2. الترجمة\nيترجم بين لغة الإشارة والنص المكتوب مع دعم 14 لغة مختلفة.\n\n'
          '📚 3. التعلم التدريجي\nنظام تعليمي بـ 6 مستويات (A1 إلى C2) لتعلم الإشارات خطوة بخطوة.\n\n'
          'هل تريد معرفة المزيد عن أي ميزة منهم؟';
    }
    if (_matches(q, ['اتواصل', 'تواصل', 'شخص اصم', 'أصم', 'deaf', 'سمع'])) {
      return 'للتواصل مع شخص أصم باستخدام PopSign! ❤️\n\n'
          '1️⃣ افتح ميزة "الترجمة" من الملف الشخصي\n'
          '2️⃣ سجّل فيديو للإشارة التي يؤديها\n'
          '3️⃣ التطبيق يترجمها فوراً إلى نص\n'
          '4️⃣ يمكنك تجميع عدة إشارات لتكوين جملة كاملة\n\n'
          'التواصل الحقيقي يبدأ بتعلم لغة الآخرين 🌟';
    }
    if (_matches(q, ['مرحبا بلغة', 'اقول مرحبا', 'إشارة مرحبا', 'hello sign', 'كيف اقول'])) {
      return 'لقول "مرحباً" بلغة الإشارة 🤟\n\n'
          'الطريقة الشائعة في لغة الإشارة الأمريكية (ASL):\n'
          '• افتح يدك بالكامل\n'
          '• ضع أصابعك بجانب رأسك\n'
          '• حرّك يدك للأمام بشكل تحية عسكرية\n\n'
          'يمكنك التدرب على هذه الإشارة في قسم "التعلم" في التطبيق! 📱';
    }
    if (_matches(q, ['كيف اتعلم', 'طريقة', 'تعلم', 'ابدا', 'ابدأ', 'learn'])) {
      return 'طريقة التعلم في PopSign سهلة جداً! 📖\n\n'
          '1️⃣ اختر لغتك من 14 لغة متاحة\n'
          '2️⃣ اختر مستواك (A1 للمبتدئين)\n'
          '3️⃣ اضغط "تعلم" على أي كلمة\n'
          '4️⃣ سجّل فيديو وأنت تؤدي الإشارة\n'
          '5️⃣ الذكاء الاصطناعي يحكم: صح أم غلط ✓\n\n'
          'كل كلمة تحتاج 3 مراجعات ناجحة! 🎯';
    }
    if (_matches(q, ['مستوى', 'مستويات', 'level', 'a1', 'a2', 'b1', 'b2', 'c1', 'c2'])) {
      return 'التطبيق يدعم 6 مستويات حسب نظام CEFR 🎓\n\n'
          '🟢 A1 - مبتدئ تماماً\n'
          '🟩 A2 - أساسي\n'
          '🟡 B1 - متوسط\n'
          '🟠 B2 - فوق المتوسط\n'
          '🔴 C1 - متقدم\n'
          '🔵 C2 - متقن\n\n'
          'ننصح بالبدء من A1! 💪';
    }
    if (_matches(q, ['ترجمة', 'ترجم', 'translate', 'مترجم'])) {
      return 'ميزة الترجمة في PopSign 🔄\n\n'
          '① من الملف الشخصي → اضغط "الترجمة"\n'
          '② ارفع فيديو لأي إشارة\n'
          '③ الذكاء الاصطناعي يترجمها فوراً\n\n'
          '✨ يمكنك بناء جملة كاملة من عدة إشارات!';
    }
    if (_matches(q, ['لغة', 'لغات', 'language', 'languages'])) {
      return 'التطبيق يدعم 14 لغة! 🌍\n\n'
          '🇸🇦 العربية  •  🇺🇸 الإنجليزية  •  🇫🇷 الفرنسية\n'
          '🇪🇸 الإسبانية  •  🇷🇺 الروسية  •  🇩🇪 الألمانية\n'
          '🇮🇹 الإيطالية  •  🇹🇷 التركية  •  🇯🇵 اليابانية\n'
          '🇨🇳 الصينية  •  🇰🇷 الكورية  •  🇧🇷 البرتغالية\n'
          '🇮🇳 الهندية  •  🇳🇱 الهولندية';
    }
    if (_matches(q, ['شكرا', 'شكراً', 'thanks', 'ممتاز', 'تمام', 'كويس'])) {
      return 'العفو! يسعدني مساعدتك دائماً 😊\nهل هناك أي شيء آخر تريد معرفته؟';
    }
    return _defaultResponse();
  }

  String _defaultResponse() {
    final responses = [
      'سؤال رائع! 🤔\nأنا متخصص في الإجابة عن أسئلة تطبيق PopSign ولغة الإشارة.\n\nجرب أن تسألني عن:\n• مميزات التطبيق\n• كيفية التعلم\n• المستويات المتاحة',
      'شكراً على سؤالك! 💬\nيمكنني مساعدتك في:\n✅ كيفية استخدام التطبيق\n✅ تعلم لغة الإشارة\n✅ المستويات والمميزات',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  bool _matches(String input, List<String> keywords) {
    for (final k in keywords) {
      if (input.contains(k)) return true;
    }
    return false;
  }

  // ─── إرسال رسالة ──────────────────────────────────────
  void _sendMessage([String? override]) async {
    final text = override ?? _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    final delay = 700 + min(text.length * 18, 1000).toInt();
    await Future.delayed(Duration(milliseconds: delay));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: _getResponse(text), isUser: false));
    });
    _scrollToBottom();
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
            colors: [Color(0xFF0D1018), Color(0xFF070C17), Color(0xFF050914)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Container(height: 1, color: Colors.white54),
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
        padding: const EdgeInsets.only(top: 16, left: 4, right: 20, bottom: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white38, size: 20),
            ),
            const SizedBox(width: 2),

            const RobotIcon(size: 40),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ChatGPT',
                  style: TextStyle(
                    color: Color(0xFF3D73FF),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1.0),
                  duration: const Duration(seconds: 1),
                  builder: (_, v, child) => Opacity(opacity: v, child: child),
                  child: const Text(
                    '• Online',
                    style: TextStyle(color: Colors.green, fontSize: 15),
                  ),
                ),
              ],
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
          const SizedBox(height: 28),

          Icon(
            Icons.edit_outlined,
            color: Colors.white.withValues(alpha: 0.15),
            size: 30,
          ),

          const SizedBox(height: 6),

          Text(
            'Common Question',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.15),
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          
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
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2030),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const RobotIcon(size: 28),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser ? const Color(0xFF3D73FF) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
              ),
              child: Text(
                msg.text,
                softWrap: true,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

 
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2030),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const RobotIcon(size: 28),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18)),
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
        margin: const EdgeInsets.all(18),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2030),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                cursorColor: Colors.white,
                cursorWidth: 2,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  hintText: 'اكتب رسالتك...',
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: 15,
                  ),
                  hintTextDirection: TextDirection.rtl,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isListening
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _isListening ? Colors.red : Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.9, end: 1.0),
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D73FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
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
        color: const Color(0xFF1A2030),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
         
          Container(
            width: size * 0.72,
            height: size * 0.62,
            decoration: BoxDecoration(
              color: const Color(0xFF3D73FF),
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
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 7, height: 7,
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
