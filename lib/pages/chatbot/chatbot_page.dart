import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/chatbot_provider.dart';
import '../../providers/emotion_history_provider.dart';
import '../../models/chat_message.dart';
import '../../theme.dart';
import '../../widgets/animated_typing_indicator.dart';
import 'package:uuid/uuid.dart';

/// 💬 AI Emotional Companion — mood-aware chat with kid mode
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();
  bool _isTyping = false;
  bool _kidMode = true;
  String _currentMood = 'neutral';
  String _currentMoodEmoji = '😊';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = context.read<EmotionHistoryProvider>();
      if (history.recentHistory.isNotEmpty) {
        final last = history.recentHistory.first;
        setState(() {
          _currentMood = last.emotion.toLowerCase();
          _currentMoodEmoji = EmotionTheme.emoji(last.emotion);
        });
      }

      final provider = context.read<ChatbotProvider>();
      if (provider.messages.isEmpty) {
        _addBotMessage(_getWelcomeMessage());
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getWelcomeMessage() {
    if (_kidMode) {
      return "Hi there! 👋 I'm your emotion buddy! I'm here to help you understand your feelings. You can tell me how you feel, or ask me anything! 🌈";
    }
    return "Welcome to your AI Emotional Companion. I'm here to help you explore and understand emotions. How are you feeling today?";
  }

  void _updateMood(String mood, String emoji) {
    setState(() {
      _currentMood = mood;
      _currentMoodEmoji = emoji;
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final provider = context.read<ChatbotProvider>();

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    provider.addMessage(userMsg);
    _textController.clear();
    _scrollToBottom();

    _detectMoodFromMessage(text);

    setState(() => _isTyping = true);
    _generateResponse(text, provider);
  }

  void _detectMoodFromMessage(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('sad') || lower.contains('cry') || lower.contains('upset')) {
      _updateMood('sad', '😢');
    } else if (lower.contains('happy') || lower.contains('great') || lower.contains('good') || lower.contains('love')) {
      _updateMood('happy', '😊');
    } else if (lower.contains('angry') || lower.contains('mad') || lower.contains('hate')) {
      _updateMood('angry', '😠');
    } else if (lower.contains('scared') || lower.contains('afraid') || lower.contains('worry')) {
      _updateMood('fear', '😨');
    } else if (lower.contains('calm') || lower.contains('relax') || lower.contains('peace')) {
      _updateMood('neutral', '😌');
    }
  }

  Future<void> _generateResponse(String userMessage, ChatbotProvider provider) async {
    await Future.delayed(Duration(milliseconds: 1200 + (userMessage.length * 10)));
    if (!mounted) return;

    String response;
    final lower = userMessage.toLowerCase();

    if (lower.contains('calm') || lower.contains('breathe') || lower.contains('relax')) {
      response = _kidMode
          ? "Let's do some breathing! 🌬️ Breathe in slowly... 1, 2, 3, 4... Hold... Now breathe out slowly... 1, 2, 3, 4, 5, 6, 7, 8. Feel better? 💙"
          : "I understand you need to feel calmer. Try the 4-7-8 breathing technique: inhale for 4 seconds, hold for 7, exhale for 8. Would you like me to guide you through it?";
    } else if (lower.contains('sad') || lower.contains('cry') || lower.contains('upset') || lower.contains('lonely')) {
      response = _kidMode
          ? "It's okay to feel sad sometimes 💙 Everyone has sad days. You're very brave for sharing that! Would you like to play a game to feel better, or should we talk more about it? 🤗"
          : "I hear you, and it's completely valid to feel sad. Sadness is a natural emotion — it tells us something matters to us. Would you like to explore what triggered this feeling?";
    } else if (lower.contains('angry') || lower.contains('mad') || lower.contains('frustrated')) {
      response = _kidMode
          ? "I can tell you're feeling frustrated 😤 That's okay! Let's take 3 big breaths together: In... Out... In... Out... In... Out... Feeling a bit calmer? 🌈"
          : "Anger is a powerful emotion, and it's okay to feel it. The key is how we respond. Would you like to try a grounding exercise to process this feeling?";
    } else if (lower.contains('happy') || lower.contains('great') || lower.contains('awesome') || lower.contains('excited')) {
      response = _kidMode
          ? "YAY! That makes me so happy too! 🎉🌟 Your smile is like sunshine! What made you feel so happy? Tell me everything! 😄"
          : "That's wonderful to hear! Positive emotions are worth savoring. What contributed to this feeling? Acknowledging the source of joy helps build emotional awareness.";
    } else if (lower.contains('scared') || lower.contains('afraid') || lower.contains('nervous')) {
      response = _kidMode
          ? "It's okay to feel scared 💫 You know what? Even superheroes feel scared sometimes! You're safe here. Let's count 5 things you can see around you. Ready? 🌟"
          : "Fear is your brain's way of trying to protect you. Let's try a grounding technique: name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.";
    } else if (lower.contains('help') || lower.contains('explain') || lower.contains('what is')) {
      response = _kidMode
          ? "I'm here to help! 🌈 I can explain emotions, play games with you, or help you feel calm. What would you like to do? 😊"
          : "I'm here to support your emotional well-being. I can explain emotions, suggest coping strategies, or just listen. What would you like to explore?";
    } else {
      final defaults = _kidMode
          ? [
              "That's really interesting! Tell me more 🌟",
              "I'm listening! How does that make you feel? 😊",
              "Wow, thank you for sharing that with me! 💫",
              "That sounds important to you. Want to talk more about it? 🤗",
              "I understand! Did you know that feelings are like weather — they come and go? 🌈",
            ]
          : [
              "Thank you for sharing that. How are you feeling about it?",
              "I appreciate you opening up. Let's explore that further.",
              "That's a meaningful observation. What emotions come up when you think about it?",
              "I'm here to listen. Take your time.",
              "Understanding our emotions is a journey. You're making great progress.",
            ];
      response = defaults[DateTime.now().second % defaults.length];
    }

    _addBotMessage(response);
    setState(() => _isTyping = false);
  }

  void _addBotMessage(String text) {
    final provider = context.read<ChatbotProvider>();
    final msg = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    provider.addMessage(msg);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatbotProvider>();
    final moodColor = EmotionTheme.color(_currentMood);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              moodColor.withValues(alpha: 0.03),
              AppColors.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(moodColor),
              _buildQuickReplies(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: provider.messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == provider.messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(provider.messages[index]);
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color moodColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
        boxShadow: [
          BoxShadow(
            color: moodColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 18),
            ),
          ),
          // Bot avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A.A.K.A.R Companion',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online • Mood: $_currentMoodEmoji',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Kid mode toggle
          GestureDetector(
            onTap: () => setState(() => _kidMode = !_kidMode),
            child: AnimatedContainer(
              duration: AppAnimations.normal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: _kidMode ? AppColors.goldGradient : null,
                color: _kidMode ? null : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: _kidMode
                    ? null
                    : Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                _kidMode ? '🧒 Kid' : '👤 Adult',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kidMode ? Colors.black : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    final replies = _kidMode
        ? ['😊 I feel happy', '😢 I feel sad', '😨 I feel scared', '🧘 Help me calm down', '🤔 Explain emotions']
        : ['How am I feeling?', 'Help me relax', 'Explain my mood', 'Coping strategies'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: replies.map((reply) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _sendMessage(reply),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  reply,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return FadeInUp(
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isUser ? AppColors.primaryGradient : null,
                  color: isUser ? null : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: AppColors.glassBorder),
                  boxShadow: isUser
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  message.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isUser ? Colors.white : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const AnimatedTypingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Calm button
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/breathing-exercise'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.calmGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Center(
                child: Text('🧘', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: TextField(
                controller: _textController,
                onSubmitted: _sendMessage,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: _kidMode
                      ? 'Tell me how you feel... 💬'
                      : 'Type your message...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: () => _sendMessage(_textController.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
