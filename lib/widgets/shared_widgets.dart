import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// ── Stat Card ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color accentColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.accentColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSoft,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                    fontFamily: 'monospace',
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSoft)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'active':
        bg = AppColors.greenPale; fg = AppColors.green; label = 'Active';
        break;
      case 'overdue':
        bg = AppColors.redPale; fg = AppColors.red; label = 'Overdue';
        break;
      default:
        bg = const Color(0xFFF0EEE9); fg = AppColors.textSoft; label = 'Done';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: fg)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.8,
            color: AppColors.textSoft,
          ),
        ),
      );
}

// ── App Button ────────────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bgColor;
  final Color fgColor;
  final bool outlined;
  final bool small;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.bgColor = AppColors.navy,
    this.fgColor = Colors.white,
    this.outlined = false,
    this.small = false,
    this.icon,
  });

  const AppButton.teal({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.small = false,
    this.icon,
  })  : bgColor = AppColors.teal,
        fgColor = Colors.white;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onTap,
    this.small = false,
    this.icon,
  })  : bgColor = Colors.transparent,
        fgColor = AppColors.textMid,
        outlined = true;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onTap,
    this.small = false,
    this.icon,
  })  : bgColor = AppColors.red,
        fgColor = Colors.white,
        outlined = false;

  @override
  Widget build(BuildContext context) {
    final px = small ? 12.0 : 18.0;
    final py = small ? 6.0 : 10.0;
    final fs = small ? 12.5 : 13.5;

    return Material(
      color: outlined ? Colors.transparent : bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
          decoration: outlined
              ? BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 6)],
              Text(label,
                  style: TextStyle(
                      fontSize: fs, fontWeight: FontWeight.w500, color: fgColor)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card Container ────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      );
}

// ── Form Field Wrapper ────────────────────────────────────────────────────────
class AppFormField extends StatelessWidget {
  final String label;
  final Widget child;

  const AppFormField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.9,
                color: AppColors.textMid,
              ),
            ),
            const SizedBox(height: 7),
            child,
          ],
        ),
      );
}

// ── Page Header ───────────────────────────────────────────────────────────────
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const PageHeader({super.key, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.4)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSoft)),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      );
}

// ── Toast ─────────────────────────────────────────────────────────────────────
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.navy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.teal, width: 3),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
