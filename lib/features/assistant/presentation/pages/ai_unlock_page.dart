import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/ai_access_config.dart';
import '../../data/ai_access_prefs.dart';
import '../../data/gemma_model_service.dart';
import '../providers/voice_controller.dart';

enum _UnlockStage { locked, downloading, ready, error }

/// Access-code gate that unlocks the on-device AI and then auto-downloads
/// BOTH models (the Gemma text model + the sherpa voice model) with
/// progress, one after the other.
///
/// [gemmaService] and [prefs] are injected as constructor parameters so
/// tests can supply fakes without a DI container (same pattern used by
/// [ModelSetupPage]); when omitted, production singletons are used. The
/// voice model is fetched from a [VoiceController] found via `Provider`.
class AiUnlockPage extends StatefulWidget {
  const AiUnlockPage({
    super.key,
    this.onUnlocked,
    AiAccessPrefs? prefs,
    GemmaModelService? gemmaService,
  })  : _prefs = prefs,
        _gemmaService = gemmaService;

  /// Called instead of popping the page (with `true`) once both models are
  /// ready, if provided.
  final VoidCallback? onUnlocked;

  final AiAccessPrefs? _prefs;
  final GemmaModelService? _gemmaService;

  @override
  State<AiUnlockPage> createState() => _AiUnlockPageState();
}

class _AiUnlockPageState extends State<AiUnlockPage> {
  late final AiAccessPrefs _prefs;
  late final GemmaModelService _gemmaService;

  final TextEditingController _codeCtrl = TextEditingController();

  _UnlockStage _stage = _UnlockStage.locked;
  String? _codeError;
  String? _downloadError;
  bool _isSubmitting = false;

  bool _gemmaDone = false;
  bool _voiceDone = false;
  int _gemmaPercent = 0;
  int _voicePercent = 0;

  @override
  void initState() {
    super.initState();
    _prefs = widget._prefs ?? AiAccessPrefs();
    _gemmaService = widget._gemmaService ?? GemmaModelService();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    setState(() {
      _isSubmitting = true;
      _codeError = null;
    });
    final ok = await _prefs.tryUnlock(_codeCtrl.text);
    if (!mounted) return;
    if (!ok) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isSubmitting = false;
        _codeError = l10n.wrongCode;
      });
      return;
    }
    setState(() {
      _isSubmitting = false;
      _stage = _UnlockStage.downloading;
    });
    _startDownloads();
  }

  Future<void> _startDownloads() async {
    setState(() {
      _stage = _UnlockStage.downloading;
      _downloadError = null;
    });
    try {
      if (!_gemmaDone) {
        final installed = await _gemmaService.isInstalled();
        if (!installed) {
          await _gemmaService.download(
            url: kGemmaModelUrl,
            token: null,
            onProgress: (int p) {
              if (mounted) setState(() => _gemmaPercent = p);
            },
          );
        }
        if (!mounted) return;
        setState(() {
          _gemmaDone = true;
          _gemmaPercent = 100;
        });
      }

      if (!_voiceDone) {
        final voice = context.read<VoiceController>();
        if (!voice.voiceModelReady) {
          await voice.ensureVoiceModel(
            onProgress: (double p) {
              if (mounted) setState(() => _voicePercent = (p * 100).round());
            },
          );
        }
        if (!mounted) return;
        setState(() {
          _voiceDone = true;
          _voicePercent = 100;
        });
      }

      if (!mounted) return;
      setState(() => _stage = _UnlockStage.ready);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _stage = _UnlockStage.error;
        _downloadError = l10n.downloadError;
      });
    }
  }

  void _continue() {
    final onUnlocked = widget.onUnlocked;
    if (onUnlocked != null) {
      onUnlocked();
    } else {
      Navigator.of(context).maybePop(true);
    }
  }

  String _sizeHint(BuildContext context, AppLocalizations l10n) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final extra = isEs ? ' + ~103 MB (modelo de voz)' : ' + ~103 MB (voice model)';
    return '${l10n.wifiWarning}$extra';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exclusiveAccess)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _buildBody(context, l10n),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    switch (_stage) {
      case _UnlockStage.locked:
        return _buildLocked(context, l10n);
      case _UnlockStage.downloading:
        return _buildDownloading(context, l10n);
      case _UnlockStage.ready:
        return _buildReady(context, l10n);
      case _UnlockStage.error:
        return _buildError(context, l10n);
    }
  }

  Widget _buildLocked(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      children: [
        Text(l10n.exclusiveAccess, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.wifi, color: cs.primary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                _sizeHint(context, l10n),
                style: theme.textTheme.bodySmall?.copyWith(color: cs.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.accessCodeHint, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _codeCtrl,
          obscureText: true,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: l10n.accessCodeHint,
            border: const OutlineInputBorder(),
            errorText: _codeError,
          ),
          onSubmitted: (_) => _isSubmitting ? null : _submitCode(),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: l10n.unlock,
          icon: Icons.lock_open,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submitCode,
        ),
      ],
    );
  }

  Widget _buildDownloading(BuildContext context, AppLocalizations l10n) {
    return ListView(
      children: [
        _buildStepTile(
          context,
          label: l10n.downloadingAiModel,
          done: _gemmaDone,
          active: !_gemmaDone,
          percent: _gemmaPercent,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildStepTile(
          context,
          label: l10n.downloadingVoiceModel,
          done: _voiceDone,
          active: _gemmaDone && !_voiceDone,
          percent: _voicePercent,
        ),
      ],
    );
  }

  Widget _buildStepTile(
    BuildContext context, {
    required String label,
    required bool done,
    required bool active,
    required int percent,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.hourglass_top,
                  color: done ? cs.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: done ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (active) Text('$percent%', style: theme.textTheme.bodyMedium),
              ],
            ),
            if (active) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(value: percent / 100),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          color: cs.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: cs.onPrimaryContainer),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.aiReady,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: l10n.continueLabel,
          icon: Icons.arrow_forward,
          onPressed: _continue,
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: cs.error, size: 40),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _downloadError ?? l10n.downloadError,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: l10n.retry,
          icon: Icons.refresh,
          onPressed: _startDownloads,
        ),
      ],
    );
  }
}
