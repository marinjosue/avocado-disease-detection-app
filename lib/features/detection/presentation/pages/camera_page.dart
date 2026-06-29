import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/models/detection_result.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/disease_colors.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/confidence_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/services/detection_service.dart';
import '../providers/detection_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../assistant/domain/assistant_context.dart';
import '../../../assistant/presentation/pages/chat_page.dart';
import '../../../assistant/presentation/providers/assistant_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  DetectionResult? _detectionResult;
  bool _isProcessing = false;
  final DetectionService _detectionService = DetectionService.instance;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await _detectionService.loadModel();
    } catch (e) {
      debugPrint('Error initializing model: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _detectionResult = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showErrorDialog('${l10n.selectImageError}: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Save image permanently
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'detection_$timestamp.jpg';
      final savedImagePath = path.join(directory.path, fileName);

      await _selectedImage!.copy(savedImagePath);

      // Detect disease
      final result = await _detectionService.detectDisease(savedImagePath);

      setState(() {
        _detectionResult = result;
        _isProcessing = false;
      });

      // Save to database
      if (mounted) {
        await context.read<DetectionProvider>().addDetection(result);
        _showResultDialog(result);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showErrorDialog('${l10n.analyzeError}: $e');
    }
  }

  void _showResultDialog(DetectionResult result) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final diseaseColors = theme.extension<DiseaseColors>()!;
    final diseaseColor = diseaseColors.forType(result.diseaseType);
    final diseaseName = l10n.localeName == 'es'
        ? result.getDiseaseNameES()
        : result.getDiseaseNameEN();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            StatusBadge(diseaseType: result.diseaseType, label: diseaseName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diseaseName,
              style: theme.textTheme.titleLarge?.copyWith(
                color: diseaseColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ConfidenceBar(value: result.confidence, label: l10n.confidence),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: l10n.recommendations),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.localeName == 'es'
                  ? result.getRecommendationES()
                  : result.getRecommendationEN(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reset();
            },
            child: Text(
              l10n.newDetection,
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          l10n.error,
          style: theme.textTheme.titleMedium,
        ),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _detectionResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.camera),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _reset,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // ── Image Preview ──────────────────────────────────────────
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg - 2),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.selectImage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Action Buttons ─────────────────────────────────────────
            if (_selectedImage == null) ...[
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  icon: Icons.camera_alt,
                  label: l10n.takePhoto,
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  icon: Icons.photo_library,
                  label: l10n.chooseFromGallery,
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  icon: Icons.analytics,
                  label: _isProcessing ? l10n.analyzing : l10n.analyzeImage,
                  isLoading: _isProcessing,
                  onPressed: _isProcessing ? null : _analyzeImage,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // ── Result Card ────────────────────────────────────────────
            if (_detectionResult != null)
              _buildResultCard(_detectionResult!, l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    DetectionResult result,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final cs = theme.colorScheme;
    final diseaseColors = theme.extension<DiseaseColors>()!;
    final diseaseColor = diseaseColors.forType(result.diseaseType);
    final diseaseName = l10n.localeName == 'es'
        ? result.getDiseaseNameES()
        : result.getDiseaseNameEN();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result banner: badge + disease name
          StatusBadge(diseaseType: result.diseaseType, label: diseaseName),
          const SizedBox(height: AppSpacing.md),
          Text(
            diseaseName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: diseaseColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Confidence bar
          ConfidenceBar(value: result.confidence, label: l10n.confidence),
          const SizedBox(height: AppSpacing.lg),

          Divider(color: theme.dividerColor),
          const SizedBox(height: AppSpacing.lg),

          // Recommendations
          SectionHeader(title: l10n.recommendations),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.localeName == 'es'
                ? result.getRecommendationES()
                : result.getRecommendationEN(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Actions
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              icon: Icons.smart_toy,
              label: l10n.askAI,
              onPressed: () async {
                final ctx = AssistantContext.fromDetection(
                  result,
                  isSpanish: l10n.localeName == 'es',
                );
                final provider = context.read<AssistantProvider>();
                final nav = Navigator.of(context);
                await provider.openOrCreateForDetection(ctx);
                nav.push(
                  MaterialPageRoute(
                    builder: (_) => const ChatPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              icon: Icons.refresh,
              label: l10n.newDetection,
              onPressed: _reset,
            ),
          ),
        ],
      ),
    );
  }
}
