import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aplication_tesis/core/theme/app_tokens.dart';
import 'package:aplication_tesis/core/widgets/status_badge.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.context, this.greeting});

  final AssistantContext? context;
  final String? greeting;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AssistantProvider>().startSession(
            context: widget.context,
            greeting: widget.greeting,
          );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.assistant ?? 'Asistente IA'),
      ),
      body: Column(
        children: [
          // Disclaimer banner
          _DisclaimerBanner(text: l10n?.assistantDisclaimer ?? 'Orientativo — no sustituye a un agrónomo certificado.'),

          // Detection context chip row
          if (widget.context?.hasDetection == true)
            _ContextChipRow(ctx: widget.context!, l10n: l10n),

          // Message list
          Expanded(
            child: Consumer<AssistantProvider>(
              builder: (context, provider, _) {
                _scrollToBottom();
                final messages = provider.messages;
                final isThinking = provider.isThinking;
                final itemCount = messages.length + (isThinking ? 1 : 0);

                if (itemCount == 0) {
                  return Center(
                    child: Text(
                      l10n?.chatInputHint ?? 'Escribe tu pregunta…',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    // Thinking indicator as last synthetic bubble
                    if (isThinking && index == messages.length) {
                      return _ThinkingBubble(text: l10n?.assistantThinking ?? 'Pensando…');
                    }
                    final msg = messages[index];
                    return _MessageBubble(message: msg, colorScheme: cs, theme: theme);
                  },
                );
              },
            ),
          ),

          // Bottom input row
          _InputRow(
            controller: _textController,
            hintText: l10n?.chatInputHint ?? 'Escribe tu pregunta…',
            onSend: () {
              final provider = context.read<AssistantProvider>();
              _sendMessage(provider);
            },
          ),
        ],
      ),
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
          Icon(Icons.info_outline, size: 14, color: cs.onSurface.withValues(alpha: 0.6)),
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
// Detection context chip row
// ---------------------------------------------------------------------------

class _ContextChipRow extends StatelessWidget {
  const _ContextChipRow({required this.ctx, required this.l10n});
  final AssistantContext ctx;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confPct = ((ctx.confidence ?? 0.0) * 100).round();
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          Text(
            '${l10n?.assistantTalkingAbout ?? 'Sobre'}:',
            style: theme.textTheme.bodySmall,
          ),
          StatusBadge(
            diseaseType: ctx.diseaseType!,
            label: ctx.diseaseName ?? ctx.diseaseType!,
          ),
          Text(
            '· $confPct%',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.colorScheme,
    required this.theme,
  });

  final AssistantMessage message;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AssistantRole.user;
    final bgColor = isUser
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.sm),
            bottomRight: Radius.circular(isUser ? AppRadius.sm : AppRadius.lg),
          ),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
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
// Bottom input row
// ---------------------------------------------------------------------------

class _InputRow extends StatefulWidget {
  const _InputRow({
    required this.controller,
    required this.hintText,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;

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
            // Fase 2C: aquí irá el botón de micrófono 🎤
            IconButton(
              icon: Icon(
                Icons.send,
                color: _hasText ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
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
