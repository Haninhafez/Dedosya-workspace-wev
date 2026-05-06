import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _reportType;

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Reports', subtitle: 'Revenue and analytics'),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(label: "Today's Revenue", onTap: () => setState(() => _reportType = 'daily')),
              AppButton.ghost(label: 'Monthly Summary', onTap: () => setState(() => _reportType = 'monthly')),
              AppButton.ghost(label: 'Top Café Items Monthly', onTap: () => setState(() => _reportType = 'cafe')),
            ],
          ),
          if (_reportType != null) ...[
            const SizedBox(height: 24),
            _buildReport(prov),
          ],
        ],
      ),
    );
  }

  Widget _buildReport(AppProvider prov) {
    switch (_reportType) {
      case 'daily':
        return _DailyReportCard(report: prov.getDailyReport());
      case 'monthly':
        return _MonthlyReportCard(report: prov.getMonthlyReport());
      case 'cafe':
        return _CafeReportCard(items: prov.getMostOrdered());
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DailyReportCard extends StatelessWidget {
  final DailyReport report;
  const _DailyReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('📅  Daily Report — ${report.date}'),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          _row('Revenue', '${report.revenue.toStringAsFixed(0)} EGP'),
          _row('Transactions', '${report.transactions.length}'),
          _row('Sessions', '${report.sessions}'),
          if (report.methods.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Payment breakdown',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMid)),
            const SizedBox(height: 8),
            ...report.methods.entries.map((e) =>
                _row('  ${e.key}', '${e.value.toStringAsFixed(0)} EGP')),
          ],
        ],
      ),
    );
  }
}

class _MonthlyReportCard extends StatelessWidget {
  final MonthlyReport report;
  const _MonthlyReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('📆  Monthly Report — ${report.month}'),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          _row('Revenue', '${report.revenue.toStringAsFixed(0)} EGP'),
          _row('Transactions', '${report.transactions.length}'),
          _row('Sessions', '${report.sessions}'),
        ],
      ),
    );
  }
}

class _CafeReportCard extends StatelessWidget {
  final List<MapEntry<String, int>> items;
  const _CafeReportCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('☕  Most Ordered Items in Month'),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('No café orders yet.', style: TextStyle(color: AppColors.textSoft))
          else
            ...items.asMap().entries.map(
                  (e) => _row('${e.key + 1}. ${e.value.key}', '${e.value.value} orders'),
                ),
        ],
      ),
    );
  }
}

Widget _header(String text) => Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
    );

Widget _row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.textMid)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13.5, color: AppColors.textDark, fontFamily: 'monospace')),
        ],
      ),
    );
