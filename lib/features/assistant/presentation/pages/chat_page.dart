import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';

import 'package:aplication_tesis/core/theme/app_tokens.dart';
import 'package:aplication_tesis/core/theme/disease_colors.dart';
import 'package:aplication_tesis/core/widgets/status_badge.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/voice_controller.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Markdown plain-text helper (used before TTS to strip formatting markers).
// Exposed as a top-level function so unit tests can import it directly.
// ---------------------------------------------------------------------------

/// Strips common Markdown formatting from [md] and returns plain readable text
/// suitable for text-to-speech playback.
///
/// Removes: bold/italic markers (`**`, `__`, `*`, `_`), inline backticks,
/// heading markers (`# `, `## `, …), and list item prefixes (`- `, `* `,
/// `1. `). Collapses any leftover blank lines.
String markdownToPlainText(String md) {
  var text = md;
  // Remove bold (**text** or __text__)
  text = text.replaceAll(RegExp(r'\*\*|__'), '');
  // Remove italic (*text* or _text_) — single markers only
  text = text.replaceAll(RegExp(r'(?<!\*)\*(?!\*)'), '');
  text = text.replaceAll(RegExp(r'(?<!_)_(?!_)'), '');
  // Remove inline code backticks
  text = text.replaceAll('`', '');
  // Remove heading markers at start of line
  text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
  // Remove unordered list markers at start of line (- or *)
  text = text.replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '');
  // Remove ordered list markers at start of line (1. 2. etc.)
  text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
  // Collapse multiple blank lines into one
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Timestamp of the last assistant message that was auto-read.
  DateTime? _lastSpokenTs;

  // Stored references so dispose() can call them without touching context.
  late final AssistantProvider _assistant;
  late final VoiceController _voice;

  @override
  void initState() {
    super.initState();
    _assistant = context.read<AssistantProvider>();
    _voice = context.read<VoiceController>();
    _assistant.addListener(_onAssistant);
  }

  @override
  void dispose() {
    _assistant.removeListener(_onAssistant);
    _voice.stopSpeaking();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Called whenever AssistantProvider notifies — triggers auto-read when a
  /// new assistant reply has completed.
  void _onAssistant() {
    if (!mounted) return;
    if (_assistant.isThinking) return;
    final msgs = _assistant.messages;
    if (msgs.isEmpty) return;
    final last = msgs.last;
    if (last.role != AssistantRole.assistant) return;
    if (last.text.isEmpty) return;
    if (last.timestamp == _lastSpokenTs) return;
    if (!_voice.autoSpeak) return;

    final langTag = _languageTag(context);
    _lastSpokenTs = last.timestamp;
    _voice.speak(markdownToPlainText(last.text), languageTag: langTag);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(AssistantProvider provider) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    provider.send(text);
    _scrollToBottom();
  }

  /// Returns `'es_ES'` or `'en_US'` for STT (underscore form).
  static String _localeId(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'es' ? 'es_ES' : 'en_US';
  }

  /// Returns `'es-ES'` or `'en-US'` for TTS (hyphen form).
  static String _languageTag(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'es' ? 'es-ES' : 'en-US';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final voice = context.watch<VoiceController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.assistant ?? 'Asistente IA'),
        actions: [
          // Auto-read toggle: 🔊 / 🔇
          IconButton(
            icon: Icon(
              voice.autoSpeak ? Icons.volume_up : Icons.volume_off,
            ),
            tooltip: voice.autoSpeak
                ? (l10n?.voiceAutoReadOn ?? 'Lectura automática activada')
                : (l10n?.voiceAutoReadOff ?? 'Lectura automática desactivada'),
            onPressed: () {
              context.read<VoiceController>().toggleAutoSpeak();
            },
          ),
        ],
      ),
      body: Consumer<AssistantProvider>(
        builder: (context, provider, _) {
          final current = provider.current;

          // Guard: no conversation open yet (shouldn't happen in normal flow)
          if (current == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final ctx = current.context;
          final messages = current.messages;
          final isThinking = provider.isThinking;
          final itemCount = messages.length + (isThinking ? 1 : 0);

          _scrollToBottom();

          return Column(
            children: [
              // Disclaimer banner
              _DisclaimerBanner(
                text: l10n?.assistantDisclaimer ??
                    'Orientativo — no sustituye a un agrónomo certificado.',
              ),

              // Detection context card at top when conversation has detection
              if (ctx?.hasDetection == true)
                _DetectionContextCard(ctx: ctx!, l10n: l10n, theme: theme),

              // Partial-text hint shown while voice is listening
              if (voice.isListening)
                _ListeningHint(
                  text: voice.partialText.isNotEmpty
                      ? voice.partialText
                      : (l10n?.voiceListening ?? 'Escuchando…'),
                  theme: theme,
                ),

              // Message list or empty state
              Expanded(
                child: itemCount == 0
                    ? _EmptyState(
                        hasDetection: ctx?.hasDetection == true,
                        diseaseName: ctx?.diseaseName,
                        l10n: l10n,
                        theme: theme,
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          // Thinking indicator as last synthetic bubble
                          if (isThinking && index == messages.length) {
                            return _ThinkingBubble(
                              text: l10n?.assistantThinking ?? 'Pensando…',
                            );
                          }
                          final msg = messages[index];
                          return _MessageBubble(
                            message: msg,
                            colorScheme: theme.colorScheme,
                            theme: theme,
                            voice: voice,
                            languageTag: _languageTag(context),
                            l10n: l10n,
                          );
                        },
                      ),
              ),

              // Bottom input row (with mic button)
              _InputRow(
                controller: _textController,
                hintText: l10n?.chatInputHint ?? 'Escribe tu pregunta…',
                onSend: () {
                  _sendMessage(provider);
                },
                voice: voice,
                localeId: _localeId(context),
                languageTag: _languageTag(context),
                l10n: l10n,
                onFinalDictation: (text, audioPath) {
                  if (text.trim().isNotEmpty) {
                    context
                        .read<AssistantProvider>()
                        .send(text, audioPath: audioPath);
                    _scrollToBottom();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Listening hint bar (shown while STT is active)
// ---------------------------------------------------------------------------

class _ListeningHint extends StatelessWidget {
  const _ListeningHint({required this.text, required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      color: cs.secondaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.mic, size: 16, color: cs.onSecondaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSecondaryContainer,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasDetection,
    required this.diseaseName,
    required this.l10n,
    required this.theme,
  });

  final bool hasDetection;
  final String? diseaseName;
  final AppLocalizations? l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final greeting = hasDetection && diseaseName != null
        ? (l10n?.localeName == 'es'
            ? '¿Tienes alguna pregunta sobre $diseaseName?'
            : 'Do you have any questions about $diseaseName?')
        : (l10n?.assistantGeneralGreeting ?? '¡Hola! ¿En qué te puedo ayudar?');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 48,
              color: cs.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              greeting,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detection context card (image + disease info)
// ---------------------------------------------------------------------------

class _DetectionContextCard extends StatelessWidget {
  const _DetectionContextCard({
    required this.ctx,
    required this.l10n,
    required this.theme,
  });

  final AssistantContext ctx;
  final AppLocalizations? l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final confPct = ((ctx.confidence ?? 0.0) * 100).round();
    final diseaseColors =
        theme.extension<DiseaseColors>() ?? DiseaseColors.light;
    final diseaseColor = diseaseColors.forType(ctx.diseaseType ?? 'healthy');

    return Container(
      width: double.infinity,
      color: cs.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail + disease info row
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: ctx.imagePath != null
                      ? Image.file(
                          File(ctx.imagePath!),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ImagePlaceholder(
                            color: diseaseColor,
                          ),
                        )
                      : _ImagePlaceholder(color: diseaseColor),
                ),
                const SizedBox(width: AppSpacing.md),

                // Disease info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n?.assistantTalkingAbout ?? 'Sobre'}:',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      StatusBadge(
                        diseaseType: ctx.diseaseType!,
                        label: ctx.diseaseName ?? ctx.diseaseType!,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$confPct% confianza',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Recommendation snippet
          if (ctx.recommendation != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(
                ctx.recommendation!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          Divider(height: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: color.withValues(alpha: 0.15),
      child: Icon(Icons.eco_outlined, color: color, size: 32),
    );
  }
}

// ---------------------------------------------------------------------------
// Disclaimer banner
// ---------------------------------------------------------------------------

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      color: cs.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 14, color: cs.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble (with optional play/stop button for assistant messages)
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.colorScheme,
    required this.theme,
    required this.voice,
    required this.languageTag,
    required this.l10n,
  });

  final AssistantMessage message;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoiceController voice;
  final String languageTag;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AssistantRole.user;
    final bgColor = isUser
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final textColor =
        isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.sm,
          top: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft:
                Radius.circular(isUser ? AppRadius.lg : AppRadius.sm),
            bottomRight:
                Radius.circular(isUser ? AppRadius.sm : AppRadius.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: AppSpacing.sm,
                bottom: AppSpacing.xs,
              ),
              // Assistant bubbles render Markdown; user bubbles stay plain text.
              child: isUser
                  ? Text(
                      message.text,
                      style:
                          theme.textTheme.bodyMedium?.copyWith(color: textColor),
                    )
                  : GptMarkdown(
                      message.text,
                      style:
                          theme.textTheme.bodyMedium?.copyWith(color: textColor),
                    ),
            ),
            // Play / stop button — only for assistant messages
            if (!isUser)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    icon: Icon(
                      voice.isSpeaking ? Icons.stop : Icons.volume_up,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    tooltip: voice.isSpeaking
                        ? (l10n?.voiceStop ?? 'Detener')
                        : (l10n?.voicePlay ?? 'Reproducir'),
                    onPressed: message.text.isEmpty
                        ? null
                        : () {
                            if (voice.isSpeaking) {
                              context.read<VoiceController>().stopSpeaking();
                            } else {
                              context.read<VoiceController>().speak(
                                    markdownToPlainText(message.text),
                                    languageTag: languageTag,
                                  );
                            }
                          },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Thinking indicator bubble
// ---------------------------------------------------------------------------

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(AppRadius.sm),
            bottomRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom input row (text field + mic + send)
// ---------------------------------------------------------------------------

class _InputRow extends StatefulWidget {
  const _InputRow({
    required this.controller,
    required this.hintText,
    required this.onSend,
    required this.voice,
    required this.localeId,
    required this.languageTag,
    required this.l10n,
    required this.onFinalDictation,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;
  final VoiceController voice;
  final String localeId;
  final String languageTag;
  final AppLocalizations? l10n;
  final void Function(String text, String? audioPath) onFinalDictation;

  @override
  State<_InputRow> createState() => _InputRowState();
}

class _InputRowState extends State<_InputRow> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final voice = widget.voice;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // Mic button — replaced from `// Fase 2C: micrófono` placeholder
            if (voice.isListening)
              IconButton(
                icon: Icon(Icons.stop, color: cs.error),
                tooltip: widget.l10n?.voiceStop ?? 'Detener',
                onPressed: () {
                  context.read<VoiceController>().stopDictation();
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.mic_none),
                tooltip: widget.l10n?.voiceDictate ?? 'Dictar',
                onPressed: () {
                  context.read<VoiceController>().startDictation(
                        onFinal: (text, audioPath) =>
                            widget.onFinalDictation(text, audioPath),
                        localeId: widget.localeId,
                      );
                },
              ),

            // Send button
            IconButton(
              icon: Icon(
                Icons.send,
                color: _hasText
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.3),
              ),
              onPressed: _hasText ? widget.onSend : null,
              tooltip: 'Enviar',
            ),
          ],
        ),
      ),
    );
  }
}
