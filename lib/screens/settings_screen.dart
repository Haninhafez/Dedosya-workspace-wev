import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Settings',
            subtitle: 'Manage your account and data',
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Change Password
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    label: 'New Password',
                    child: TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSoft,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                  ),
                  AppButton(
                    label: 'Update Password',
                    onTap: () async {
                      final p = _passCtrl.text.trim();
                      if (p.isEmpty) {
                        showToast(context, 'Enter a new password.');
                        return;
                      }
                      await context.read<AppProvider>().changePassword(p);
                      _passCtrl.clear();
                      if (context.mounted)
                        showToast(context, '✅ Password updated.');
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Divider(color: AppColors.border),
                  ),

                  // Backup
                  const Text(
                    'Data Backup',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton.ghost(
                    label: '⬇  Download Backup',
                    onTap: () => _downloadBackup(context),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'To restore: paste your backup JSON into the field below.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSoft),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Paste backup JSON here…',
                    ),
                    onSubmitted: (v) => _restoreBackup(context, v),
                  ),
                  const SizedBox(height: 10),
                  AppButton.ghost(
                    label: '⬆  Restore Backup',
                    onTap: () => _restoreBackup(context, ''),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Divider(color: AppColors.border),
                  ),

                  // Danger zone
                  const Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton.danger(
                    label: 'Reset All Data',
                    onTap: () {
                      _confirmReset(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadBackup(BuildContext context) {
    final json = context.read<AppProvider>().exportJson();
    // On Flutter Web we can trigger a download; on mobile we show a dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Backup Data'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _restoreBackup(BuildContext context, String raw) async {
    try {
      await context.read<AppProvider>().importJson(raw);
      if (context.mounted) showToast(context, '✅ Backup restored.');
    } catch (_) {
      if (context.mounted) showToast(context, 'Invalid backup data.');
    }
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Reset All Data',
          style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'This will permanently delete ALL data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () async {
              await context.read<AppProvider>().resetAllData();
              context.read<AppProvider>().changePage(0);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
