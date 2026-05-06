import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final active = prov.activeBookings;
    final today = prov.getDailyReport();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Dashboard',
            subtitle: DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
            action: AppButton.teal(
              label: '+ New Booking',
              onTap: () => _openAddBooking(context),
            ),
          ),
          const SizedBox(height: 28),
          // Stat grid
          _StatGrid(
            active: active,
            todayRev: today.revenue,
            sessions: today.sessions,
          ),
          const SizedBox(height: 28),
          // Quick actions
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(label: '☕  Café Order', onTap: () => _goTo(context, 2)),
              AppButton(
                label: '💳  Checkout & Bill',
                onTap: () => _goTo(context, 3),
              ),
              AppButton.ghost(
                label: '📊  Daily Report',
                onTap: () => _goTo(context, 4),
              ),
            ],
          ),
          const SectionLabel('Recent Bookings'),
          _RecentBookingsTable(bookings: prov.bookings.take(8).toList()),
        ],
      ),
    );
  }

  void _goTo(BuildContext context, int idx) {
    context.read<AppProvider>().changePage(idx);
  }

  void _openAddBooking(BuildContext context) {
    showDialog(context: context, builder: (_) => const _AddBookingDialog());
  }
}

class _StatGrid extends StatelessWidget {
  final List<Booking> active;
  final double todayRev;
  final int sessions;

  const _StatGrid({
    required this.active,
    required this.todayRev,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = active.where((b) => b.status == 'overdue').length;
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth > 700 ? 4 : (c.maxWidth > 400 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.7,
          children: [
            StatCard(
              label: 'Active Sessions',
              value: '${active.length}',
              subtitle: '$overdue overdue',
            ),
            StatCard(
              label: "Today's Revenue",
              value: '${todayRev.toStringAsFixed(0)} EGP',
              accentColor: AppColors.gold,
            ),
            StatCard(
              label: "Today's Sessions",
              value: '$sessions',
              subtitle: 'check-ins',
              accentColor: AppColors.sky,
            ),
            StatCard(
              label: 'Café Orders',
              value: context.watch<AppProvider>().orders.length.toString(),
              subtitle: 'total orders',
              accentColor: AppColors.green,
            ),
          ],
        );
      },
    );
  }
}

class _RecentBookingsTable extends StatelessWidget {
  final List<Booking> bookings;

  const _RecentBookingsTable({required this.bookings});

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
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.2),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: AppColors.navy),
              children: ['Client', 'Type', 'Check-in', 'Status']
                  .map(
                    (h) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      child: Text(
                        h,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            ...bookings.map(
              (b) => TableRow(
                decoration: const BoxDecoration(color: Colors.transparent),
                children: [
                  _cell(b.clientName),
                  _cell(b.workspaceType),
                  _cell(_fmtTime(b.checkinTime)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: StatusBadge(b.status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13.5, color: AppColors.textMid),
    ),
  );

  String _fmtTime(String iso) {
    try {
      return DateFormat('MMM d, HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
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
        child: Padding(
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
                label: 'Duration (hours): ${_duration.toStringAsFixed(1)}h',
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
      id:
          DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
          DateTime.now().microsecond.toRadixString(36),
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
