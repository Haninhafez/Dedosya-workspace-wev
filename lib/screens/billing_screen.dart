import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  String? _selectedId;
  double _discount = 0;
  String _discountReason = 'None';

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final active = prov.activeBookings;

    if (_selectedId == null && active.isNotEmpty) {
      _selectedId = active.first.id;
    }

    final bill = _selectedId != null
        ? prov.calculateBill(_selectedId!, _discount)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Billing & Payment',
            subtitle: 'Checkout active sessions',
          ),
          const SizedBox(height: 24),
          // Session selector
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: AppFormField(
              label: 'Active Session',
              child: DropdownButtonFormField<String>(
                value: active.any((b) => b.id == _selectedId) ? _selectedId : null,
                hint: const Text('No active sessions'),
                decoration: const InputDecoration(),
                items: active
                    .map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text('${b.clientName} — ${b.workspaceType}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedId = v;
                  _discount = 0;
                }),
              ),
            ),
          ),
          // Bill details
          if (bill != null) ...[
            _BillingCard(
              bill: bill,
              discount: _discount,
              discountReason: _discountReason,
              onDiscountChanged: (v) => setState(() => _discount = v),
              onReasonChanged: (v) => setState(() => _discountReason = v),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                AppButton(label: '💵  Cash', onTap: () => _pay(context, prov, bill, 'Cash')),
                AppButton.teal(label: '📱  InstaPay', onTap: () => _pay(context, prov, bill, 'InstaPay')),
                AppButton.ghost(label: '📲  Vodafone Cash', onTap: () => _pay(context, prov, bill, 'Vodafone Cash')),
              ],
            ),
          ] else if (active.isEmpty) ...[
            const SizedBox(height: 24),
            AppCard(
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No active sessions to bill.', style: TextStyle(color: AppColors.textSoft, fontSize: 14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _pay(BuildContext context, AppProvider prov, BillingSummary bill, String method) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Confirm Payment', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text(
            'Collect ${bill.net.toStringAsFixed(0)} EGP from ${bill.booking.clientName} via $method?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
            onPressed: () async {
              await prov.processPayment(
                bookingId: bill.booking.id,
                total: bill.net,
                method: method,
                discountPct: _discount,
              );
              if (context.mounted) {
                Navigator.pop(context);
                setState(() { _selectedId = null; _discount = 0; });
                showToast(context, '✅ Paid ${bill.net.toStringAsFixed(0)} EGP via $method');
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _BillingCard extends StatelessWidget {
  final BillingSummary bill;
  final double discount;
  final String discountReason;
  final ValueChanged<double> onDiscountChanged;
  final ValueChanged<String> onReasonChanged;

  const _BillingCard({
    required this.bill,
    required this.discount,
    required this.discountReason,
    required this.onDiscountChanged,
    required this.onReasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bill.booking.clientName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 14),
            _row('Workspace — ${bill.booking.workspaceType}', '${bill.booking.durationHours}h booked'),
            if (bill.extraH > 0)
              _row('Extra time', '+${bill.extraH}h', isRed: true),
            _row('Rate', '${bill.rate.toStringAsFixed(0)} EGP/hr'),
            _row('Workspace subtotal', '${bill.wsCharge.toStringAsFixed(0)} EGP'),
            if (bill.cafeOrders.isNotEmpty)
              _row('Café orders (${bill.cafeOrders.length} items)', '${bill.cafeTotal.toStringAsFixed(0)} EGP'),
            const SizedBox(height: 10),
            // Discount
            Row(children: [
              const Text('Discount:', style: TextStyle(fontSize: 13.5, color: AppColors.textMid)),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: '%', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  onChanged: (v) => onDiscountChanged(double.tryParse(v)?.clamp(0, 100) ?? 0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: discountReason,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: ['None', 'Loyalty', 'Seasonal Offer', 'Staff / Family', 'Other']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => onReasonChanged(v!),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Container(height: 2, color: AppColors.border),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text(
                  '${bill.net.toStringAsFixed(0)} EGP',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'monospace'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isRed = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13.5, color: isRed ? AppColors.red : AppColors.textMid)),
            Text(value,
                style: TextStyle(
                    fontSize: 13.5,
                    color: isRed ? AppColors.red : AppColors.textMid,
                    fontFamily: 'monospace')),
          ],
        ),
      );
}
