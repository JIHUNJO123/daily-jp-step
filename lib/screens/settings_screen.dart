import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';
import '../services/translation_service.dart';
import '../services/purchase_service.dart';
import '../services/ad_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _restorePurchase() async {
    setState(() => _isRestoring = true);

    final purchaseService = PurchaseService.instance;
    await purchaseService.restorePurchases();

    // Wait for restore to complete
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRestoring = false;
    });

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.restoreComplete),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Language Section
          _buildSectionHeader(l10n.language),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.displayLanguage),
            subtitle: Text(
              TranslationService.instance.currentLanguageInfo.nativeName,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(),
          ),

          const Divider(),

          // Ads Section
          _buildSectionHeader(l10n.removeAds),
          // 잠금 해제 상태 표시
          ListTile(
            leading: Icon(
              AdService.instance.isUnlocked ? Icons.lock_open : Icons.lock_outline,
              color: AdService.instance.isUnlocked ? Colors.green : null,
            ),
            title: Text(AdService.instance.isUnlocked ? l10n.unlockedUntilMidnight : l10n.lockedContent),
            subtitle: Text(
              AdService.instance.isUnlocked 
                ? l10n.thankYou 
                : l10n.watchAdToUnlock,
            ),
          ),
          // IAP 광고 제거 구매 (스토어 사용 가능한 경우에만 표시)
          if (PurchaseService.instance.isAvailable) ...[
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(l10n.removeAds),
              subtitle: const Text('\$1.99'),
              trailing: ElevatedButton(
                onPressed: () => _purchaseAdRemoval(),
                child: Text(l10n.buy),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(l10n.restorePurchase),
              subtitle: Text(l10n.restorePurchaseDesc),
              trailing:
                  _isRestoring
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : null,
              onTap: _isRestoring ? null : _restorePurchase,
            ),
          ],

          const Divider(),

          // Info Section
          _buildSectionHeader(l10n.info),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrivacyPolicy(),
          ),
          ListTile(
            leading: const Icon(Icons.warning_outlined),
            title: Text(l10n.disclaimer),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showDisclaimer(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final currentLang = TranslationService.instance.currentLanguage;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.selectLanguage),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  TranslationService.supportedLanguages.map((lang) {
                    return RadioListTile<String>(
                      title: Text(lang.nativeName),
                      subtitle: Text(lang.name),
                      value: lang.code,
                      groupValue: currentLang,
                      onChanged: (value) async {
                        if (value != null) {
                          await TranslationService.instance.setLanguage(value);
                          MyApp.setLocale(context, Locale(value));
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  Future<void> _purchaseAdRemoval() async {
    final purchaseService = PurchaseService.instance;
    await purchaseService.buyRemoveAds();
  }

  void _showPrivacyPolicy() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.privacyPolicy),
            content: SingleChildScrollView(
              child: Text(l10n.privacyPolicyContent),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showDisclaimer() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.disclaimer),
            content: SingleChildScrollView(child: Text(l10n.disclaimerText)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
