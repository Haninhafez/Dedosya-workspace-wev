import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final cap = prov.workspaceCapacity;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Bookings',
            subtitle: 'Manage walk-ins and Facebook reservations',
            action: AppButton.teal(
              label: '+ Add Booking',
              onTap: () => showDialog(
                context: context,
                builder: (_) => const _AddBookingDialog(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Workspace capacity cards
          _WsCapacityRow(cap: cap),
          const SizedBox(height: 24),
          // Table
          _BookingsTable(bookings: prov.bookings),
        ],
      ),
    );
  }
}

class _WsCapacityRow extends StatelessWidget {
  final Map<String, Map<String, int>> cap;

  const _WsCapacityRow({required this.cap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth > 500 ? 3 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 2.2,
          children: cap.entries.map((e) {
            final active = e.value['active']!;
            final total = e.value['total']!;
            final free = total - active;
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e.key.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSoft,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '$free',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: free > 0 ? AppColors.green : AppColors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ $total free',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _BookingsTable extends StatelessWidget {
  final List<Booking> bookings;

  const _BookingsTable({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return AppCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No bookings yet.',
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.navy),
            headingTextStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
              letterSpacing: 1,
            ),
            dataTextStyle: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textMid,
            ),
            columns: const [
              DataColumn(label: Text('CLIENT')),
              DataColumn(label: Text('WORKSPACE')),
              DataColumn(label: Text('CHECK-IN')),
              DataColumn(label: Text('DURATION')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('ACTION')),
            ],
            rows: bookings.map((b) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      b.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  DataCell(Text(b.workspaceType)),
                  DataCell(Text(_fmtTime(b.checkinTime))),
                  DataCell(Text('${b.durationHours}h')),
                  DataCell(StatusBadge(b.status)),
                  DataCell(
                    b.status == 'active' || b.status == 'overdue'
                        ? AppButton.ghost(
                            label: 'Check Out',
                            small: true,
                            onTap: () => _confirmCheckout(context, b),
                          )
                        : Text(
                            b.checkoutTime != null
                                ? _fmtTime(b.checkoutTime!)
                                : '—',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSoft,
                            ),
                          ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _fmtTime(String iso) {
    try {
      return DateFormat('MMM d, HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  void _confirmCheckout(BuildContext context, Booking b) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Check Out',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text('Check out ${b.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
            onPressed: () {
              context.read<AppProvider>().changePage(3);
              Navigator.pop(context);
            },
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }
}

// ── Add Booking Dialog ────────────────────────────────────────────────────────
class _AddBookingDialog extends StatefulWidget {
  const _AddBookingDialog();

  @override
  State<_AddBookingDialog> createState() => _AddBookingDialogState();
}

class _AddBookingDialogState extends State<_AddBookingDialog> {
  final _nameCtrl = TextEditingController();
  String _wsType = 'Regular Seat';
  double _duration = 2;
  String _source = 'walk-in';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.warmWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Booking',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSoft),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              AppFormField(
                label: 'Client Name',
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(hintText: 'Full name'),
                ),
              ),
              AppFormField(
                label: 'Workspace Type',
                child: DropdownButtonFormField<String>(
                  value: _wsType,
                  decoration: const InputDecoration(),
                  items: ['Regular Seat', 'Private Office', 'Room']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _wsType = v!),
                ),
              ),
              AppFormField(
                label: 'Duration: ${_duration.toStringAsFixed(1)}h',
                child: Slider(
                  value: _duration,
                  min: 0.5,
                  max: 12,
                  divisions: 23,
                  activeColor: AppColors.teal,
                  onChanged: (v) =>
                      setState(() => _duration = (v * 2).round() / 2),
                ),
              ),
              AppFormField(
                label: 'Source',
                child: DropdownButtonFormField<String>(
                  value: _source,
                  decoration: const InputDecoration(),
                  items: ['walk-in', 'facebook']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _source = v!),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Check In',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toRadixString(36),
      clientName: _nameCtrl.text.trim(),
      workspaceType: _wsType,
      checkinTime: DateTime.now().toIso8601String(),
      durationHours: _duration,
      status: 'active',
      source: _source,
    );
    context.read<AppProvider>().addBooking(booking);
    Navigator.pop(context);
    showToast(context, '✅ ${booking.clientName} checked in!');
  }
}
