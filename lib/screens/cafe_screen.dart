import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class CafeScreen extends StatelessWidget {
  const CafeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Café & Inventory',
            subtitle: 'Add items to active sessions',
            action: AppButton.teal(
              label: '+ Add to Session',
              onTap: () {
                final active = context.read<AppProvider>().activeBookings;
                if (active.isEmpty) {
                  showToast(context, 'No active sessions right now.');
                  return;
                }
                showDialog(context: context, builder: (_) => const _CafeOrderDialog());
              },
            ),
          ),
          const SectionLabel('Inventory'),
          _InventoryTable(),
        ],
      ),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = context.watch<AppProvider>().inventory;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.navy),
            headingTextStyle: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white60, letterSpacing: 1),
            dataTextStyle: const TextStyle(fontSize: 13.5, color: AppColors.textMid),
            columns: const [
              DataColumn(label: Text('ITEM')),
              DataColumn(label: Text('CATEGORY')),
              DataColumn(label: Text('PRICE')),
              DataColumn(label: Text('QTY')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('ACTIONS')),
            ],
            rows: items.map((item) {
              return DataRow(cells: [
                DataCell(Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textDark))),
                DataCell(Text(item.category)),
                DataCell(Text('${item.price.toStringAsFixed(0)} EGP')),
                DataCell(Text('${item.quantity}')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.available ? AppColors.greenPale : AppColors.redPale,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.available ? 'Available' : 'Out of Stock',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: item.available ? AppColors.green : AppColors.red),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _chip(
                        item.available ? 'Disable' : 'Enable',
                        () => context.read<AppProvider>().toggleAvailability(item.id),
                      ),
                      const SizedBox(width: 6),
                      _chip('Set Qty', () => _setQty(context, item)),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap) => Material(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMid)),
          ),
        ),
      );

  void _setQty(BuildContext context, InventoryItem item) async {
    final ctrl = TextEditingController(text: '${item.quantity}');
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Set Qty — ${item.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter quantity'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text) ?? item.quantity),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      context.read<AppProvider>().updateQuantity(item.id, result);
      showToast(context, 'Quantity updated.');
    }
  }
}

// ── Café Order Dialog ─────────────────────────────────────────────────────────
class _CafeOrderDialog extends StatefulWidget {
  const _CafeOrderDialog();

  @override
  State<_CafeOrderDialog> createState() => _CafeOrderDialogState();
}

class _CafeOrderDialogState extends State<_CafeOrderDialog> {
  late String _selectedBookingId;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _selectedBookingId = context.read<AppProvider>().activeBookings.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final active = prov.activeBookings;
    final inventory = prov.inventory;

    return Dialog(
      backgroundColor: AppColors.warmWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Items to Session',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.textSoft)),
                ],
              ),
              const SizedBox(height: 16),
              AppFormField(
                label: 'Select Client',
                child: DropdownButtonFormField<String>(
                  value: _selectedBookingId,
                  decoration: const InputDecoration(),
                  items: active
                      .map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text('${b.clientName} — ${b.workspaceType}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBookingId = v!),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: inventory.map((item) {
                    final unavailAlts = !item.available
                        ? inventory
                            .where((i) => i.available && i.category == item.category)
                            .map((i) => i.name)
                            .join(', ')
                        : '';
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.border))),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selected.contains(item.id),
                            activeColor: AppColors.teal,
                            onChanged: item.available
                                ? (v) => setState(() {
                                      if (v!) _selected.add(item.id);
                                      else _selected.remove(item.id);
                                    })
                                : null,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        color: item.available ? AppColors.textDark : AppColors.textSoft)),
                                if (!item.available)
                                  Text(
                                    'Out of stock${unavailAlts.isNotEmpty ? ' • Try: $unavailAlts' : ''}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.red),
                                  ),
                              ],
                            ),
                          ),
                          Text('${item.price.toStringAsFixed(0)} EGP',
                              style: const TextStyle(
                                  fontSize: 12.5, color: AppColors.textSoft, fontFamily: 'monospace')),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, padding: const EdgeInsets.symmetric(vertical: 13)),
                  child: const Text('Add to Bill'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_selected.isEmpty) {
      showToast(context, 'Select at least one item.');
      return;
    }
    context.read<AppProvider>().addCafeOrder(
          bookingId: _selectedBookingId,
          itemIds: _selected.toList(),
        );
    Navigator.pop(context);
    showToast(context, '✅ Items added to session.');
  }
}
