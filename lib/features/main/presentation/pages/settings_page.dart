import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/theme_mode_selector.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../assistant/presentation/pages/ai_unlock_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Apariencia ──────────────────────────────────────────────────
          SectionHeader(title: l10n.appearance),
          const SizedBox(height: AppSpacing.sm),
          ThemeModeSelector(
            value: context.watch<ThemeProvider>().themeMode,
            onChanged: (m) => context.read<ThemeProvider>().setThemeMode(m),
            lightLabel: l10n.themeLight,
            darkLabel: l10n.themeDark,
            systemLabel: l10n.themeSystem,
          ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.xl),

          // ── Idioma ──────────────────────────────────────────────────────
          SectionHeader(title: l10n.language),
          const SizedBox(height: AppSpacing.sm),
          _buildLanguageSelector(context),

          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.xl),

          // ── Asistente IA ────────────────────────────────────────────────
          SectionHeader(title: l10n.aiModelTile),
          const SizedBox(height: AppSpacing.sm),
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: Icon(Icons.smart_toy, color: cs.primary),
              title: Text(l10n.aiModelTile, style: theme.textTheme.titleMedium),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiUnlockPage()),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.xl),

          // ── Acerca de ───────────────────────────────────────────────────
          SectionHeader(title: l10n.aboutApp),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoTile(
            context,
            icon: Icons.info_outline,
            title: l10n.version,
            subtitle: '1.0.0',
          ),
          _buildInfoTile(
            context,
            icon: Icons.description,
            title: l10n.aboutApp,
            subtitle: l10n.aboutDescription,
          ),
          _buildTutorialTile(context, l10n),

          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.xl),

          // ── Sobre el proyecto ───────────────────────────────────────────
          SectionHeader(title: l10n.aboutProject),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.appDescription,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.detectedDiseases2,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '• ${l10n.manchaNegra} (Black Spot)\n'
                    '• ${l10n.rona} (Scab)\n'
                    '• ${l10n.healthy}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.features,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '✓ ${l10n.realTimeDetection}\n'
                    '✓ ${l10n.offlineFunctionality}\n'
                    '✓ ${l10n.detectionHistory}\n'
                    '✓ ${l10n.statisticsAnalysis}\n'
                    '✓ ${l10n.automaticRecommendations}\n'
                    '✓ ${l10n.multiLanguageSupport}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Créditos ────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  l10n.developedBy,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'ESPE ${DateTime.now().year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale.languageCode;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: RadioGroup<String>(
        groupValue: currentLocale,
        onChanged: (value) {
          if (value != null) localeProvider.setLocale(Locale(value));
        },
        child: Column(
          children: [
            RadioListTile<String>(
              title: const Row(
                children: [
                  Text('🇪🇸', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Text('Español'),
                ],
              ),
              value: 'es',
              activeColor: cs.primary,
            ),
            const Divider(height: 1),
            RadioListTile<String>(
              title: const Row(
                children: [
                  Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Text('English'),
                ],
              ),
              value: 'en',
              activeColor: cs.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: cs.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  Widget _buildTutorialTile(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(Icons.school, color: cs.primary),
        title: Text(l10n.viewTutorial, style: Theme.of(context).textTheme.titleMedium),
        trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        onTap: () async {
          await OnboardingService().reset();
          if (!context.mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OnboardingPage(
                onFinish: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      ),
    );
  }
}
