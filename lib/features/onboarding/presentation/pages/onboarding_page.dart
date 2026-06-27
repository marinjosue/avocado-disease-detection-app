import 'package:flutter/material.dart';
import 'package:aplication_tesis/core/services/onboarding_service.dart';
import 'package:aplication_tesis/core/theme/app_tokens.dart';
import 'package:aplication_tesis/core/widgets/app_buttons.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

/// Data for a single onboarding slide.
class _SlideData {
  const _SlideData({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

/// Full-screen onboarding flow shown on first launch.
///
/// Three slides (welcome / photo tips / results), a "Saltar" skip button,
/// page-dot indicator, and a primary action button (Next / Get started).
///
/// On skip OR finish: marks onboarding as seen, then calls [onFinish].
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.onFinish});

  /// Called after the user completes or skips onboarding.
  final VoidCallback? onFinish;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingService().markSeen();
    widget.onFinish?.call();
  }

  void _nextOrFinish() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final slides = <_SlideData>[
      _SlideData(
        icon: Icons.eco_rounded,
        title: l10n?.onbWelcomeTitle ?? 'Welcome to avocadoIA',
        body: l10n?.onbWelcomeBody ?? 'Detect Black Spot and Scab in avocado from a photo.',
      ),
      _SlideData(
        icon: Icons.camera_alt_rounded,
        title: l10n?.onbPhotoTitle ?? 'Take a good photo',
        body: l10n?.onbPhotoBody ?? 'Good light, get close to the fruit, keep it in focus.',
      ),
      _SlideData(
        icon: Icons.bar_chart_rounded,
        title: l10n?.onbResultsTitle ?? 'See results and tips',
        body: l10n?.onbResultsBody ?? 'Review the diagnosis, recommendations and your history.',
      ),
    ];

    final skipLabel = l10n?.onbSkip ?? 'Skip';
    final nextLabel = l10n?.onbNext ?? 'Next';
    final startLabel = l10n?.onbStart ?? 'Get started';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button row ──────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  right: AppSpacing.lg,
                ),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    skipLabel,
                    style: tt.labelLarge?.copyWith(color: cs.primary),
                  ),
                ),
              ),
            ),

            // ── Slides ───────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return _SlidePage(slide: slide);
                },
              ),
            ),

            // ── Page-dots indicator ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    width: active ? AppSpacing.xxl : AppSpacing.sm,
                    height: AppSpacing.sm,
                    decoration: BoxDecoration(
                      color: active ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  );
                }),
              ),
            ),

            // ── Primary action button ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                0,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _currentPage < 2 ? nextLabel : startLabel,
                  onPressed: _nextOrFinish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Content for a single onboarding slide: large icon + title + body.
class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon in a rounded surface container
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              slide.icon,
              size: 72,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: tt.headlineSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
