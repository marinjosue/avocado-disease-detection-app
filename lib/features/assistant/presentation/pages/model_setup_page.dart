import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/assistant_prefs.dart';
import '../../data/gemma_model_service.dart';

/// Page that lets the user download the on-device Gemma model.
///
/// [service] and [prefs] are injected as constructor parameters so that tests
/// can supply fakes without needing a DI container. When omitted, production
/// singletons are used.
class ModelSetupPage extends StatefulWidget {
  const ModelSetupPage({
    super.key,
    GemmaModelService? service,
    AssistantPrefs? prefs,
  })  : _service = service,
        _prefs = prefs;

  final GemmaModelService? _service;
  final AssistantPrefs? _prefs;

  @override
  State<ModelSetupPage> createState() => _ModelSetupPageState();
}

class _ModelSetupPageState extends State<ModelSetupPage> {
  late final GemmaModelService _service;
  late final AssistantPrefs _prefs;

  final TextEditingController _tokenCtrl = TextEditingController();
  final TextEditingController _urlCtrl = TextEditingController();

  bool _isInstalled = false;
  bool _isDownloading = false;
  bool _isLoading = true; // initial check
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _service = widget._service ?? GemmaModelService();
    _prefs = widget._prefs ?? AssistantPrefs();
    _init();
  }

  Future<void> _init() async {
    final token = await _prefs.getToken();
    final url = await _prefs.getModelUrl();
    final installed = await _service.isInstalled();

    if (mounted) {
      setState(() {
        _tokenCtrl.text = token ?? '';
        _urlCtrl.text = url;
        _isInstalled = installed;
        _isLoading = false;
      });
    }
  }

  Future<void> _startDownload() async {
    final l10n = AppLocalizations.of(context)!;
    final token = _tokenCtrl.text.trim();
    final url = _urlCtrl.text.trim();

    // Persist settings before downloading
    await _prefs.setModelUrl(url);
    if (token.isNotEmpty) {
      await _prefs.setToken(token);
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      await _service.download(
        url: url,
        token: token.isEmpty ? null : token,
        onProgress: (int p) {
          if (mounted) setState(() => _progress = p);
        },
      );

      if (mounted) {
        setState(() {
          _isInstalled = true;
          _isDownloading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.downloadError)),
        );
      }
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modelSetupTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // ── Intro card ──────────────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.modelSetupIntro,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.wifi,
                              size: 18,
                              color: cs.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                l10n.wifiWarning,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Model ready state ───────────────────────────────────────
                if (_isInstalled) ...[
                  Card(
                    color: cs.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: cs.onPrimaryContainer,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.modelReady,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // ── Token field ─────────────────────────────────────────
                  Text(
                    l10n.hfTokenLabel,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _tokenCtrl,
                    obscureText: true,
                    enabled: !_isDownloading,
                    decoration: InputDecoration(
                      hintText: l10n.hfTokenHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── URL field ───────────────────────────────────────────
                  Text(
                    l10n.modelUrlLabel,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _urlCtrl,
                    enabled: !_isDownloading,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Progress / Download button ──────────────────────────
                  if (_isDownloading) ...[
                    Text(
                      '${l10n.downloading} $_progress%',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(value: _progress / 100),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  PrimaryButton(
                    label: l10n.downloadModel,
                    icon: Icons.download,
                    isLoading: _isDownloading,
                    onPressed: _isDownloading ? null : _startDownload,
                  ),
                ],
              ],
            ),
    );
  }
}
