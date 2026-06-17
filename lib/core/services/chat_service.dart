import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatHistoryMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatHistoryMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    return ChatHistoryMessage(
      role: json['role'] as String? ?? 'assistant',
      content: json['content'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  bool get isUser => role == 'user';
}

class ChatService {
  static const _base = 'http://91.108.113.135';
  static const _timeout = Duration(seconds: 30);

  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> newSession({String userId = 'user'}) async {
    final res = await http
        .post(
          Uri.parse('$_base/api/chat/new-session'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Server error ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final sessionId = json['session_id'] as String?;
    if (json['success'] != true || sessionId == null) {
      throw Exception('Could not start a chat session');
    }
    return sessionId;
  }

  Future<String> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    final res = await http
        .post(
          Uri.parse('$_base/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'session_id': sessionId, 'message': message}),
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Server error ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['success'] != true) {
      throw Exception(json['error']?.toString() ?? 'Something went wrong');
    }
    return json['reply'] as String? ?? '';
  }

  Future<List<ChatHistoryMessage>> getHistory(String sessionId) async {
    final res = await http
        .get(Uri.parse('$_base/api/chat/history/$sessionId'))
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Server error ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final messages = (json['messages'] as List?) ?? const [];
    return messages
        .map((m) => ChatHistoryMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteHistory(String sessionId) async {
    final res = await http
        .delete(Uri.parse('$_base/api/chat/history/$sessionId'))
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Server error ${res.statusCode}');
    }
  }
}
