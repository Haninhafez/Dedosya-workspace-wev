import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _kKey = 'wsc_v2';
const _uuid = Uuid();

class AppProvider extends ChangeNotifier {
  // ── Auth ──────────────────────────────
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  void changePage(int index) {
    _currentPage = index;
    notifyListeners();
  }

  // ── Data ──────────────────────────────
  List<AppUser> _users = [AppUser(username: 'manager', password: 'admin')];
  List<Booking> _bookings = [];
  List<InventoryItem> _inventory = _defaultInventory();
  List<CafeOrder> _orders = [];
  List<Transaction> _transactions = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  List<CafeOrder> get orders => List.unmodifiable(_orders);
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Booking> get activeBookings => _bookings
      .where((b) => b.status == 'active' || b.status == 'overdue')
      .toList();

  // ── Init ──────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      _loadFromJson(jsonDecode(raw));
    }
    _refreshOverdueStatuses();
    notifyListeners();
  }

  void _loadFromJson(Map<String, dynamic> data) {
    _users = (data['users'] as List? ?? [])
        .map((e) => AppUser.fromJson(e))
        .toList();
    if (_users.isEmpty)
      _users = [AppUser(username: 'manager', password: 'admin')];

    _bookings = (data['bookings'] as List? ?? [])
        .map((e) => Booking.fromJson(e))
        .toList();

    _inventory = (data['inventory'] as List? ?? [])
        .map((e) => InventoryItem.fromJson(e))
        .toList();
    if (_inventory.isEmpty) _inventory = _defaultInventory();

    _orders = (data['orders'] as List? ?? [])
        .map((e) => CafeOrder.fromJson(e))
        .toList();

    _transactions = (data['transactions'] as List? ?? [])
        .map((e) => Transaction.fromJson(e))
        .toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'users': _users.map((u) => u.toJson()).toList(),
      'bookings': _bookings.map((b) => b.toJson()).toList(),
      'inventory': _inventory.map((i) => i.toJson()).toList(),
      'orders': _orders.map((o) => o.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
    };
    await prefs.setString(_kKey, jsonEncode(data));
  }

  void _refreshOverdueStatuses() {
    final now = DateTime.now();
    for (final b in _bookings) {
      if (b.status == 'active') {
        final checkin = DateTime.parse(b.checkinTime);
        final expected = checkin.add(
          Duration(minutes: (b.durationHours * 60).round()),
        );
        if (now.isAfter(expected)) b.status = 'overdue';
      }
    }
  }

  // ── Auth ──────────────────────────────
  bool login(String username, String password) {
    final user = _users.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () => AppUser(username: '', password: ''),
    );
    if (user.username.isNotEmpty) {
      _loggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }

  Future<void> changePassword(String newPass) async {
    _users[0].password = newPass;
    await _save();
    notifyListeners();
  }

  // ── Bookings ──────────────────────────
  Future<void> addBooking(Booking b) async {
    _bookings.insert(0, b);
    await _save();
    notifyListeners();
  }

  Future<void> checkOut(String id) async {
    final b = _bookings.firstWhere((x) => x.id == id);
    b.status = 'checked-out';
    b.checkoutTime = DateTime.now().toIso8601String();
    await _save();
    notifyListeners();
  }

  // ── Inventory ─────────────────────────
  Future<void> toggleAvailability(String id) async {
    final item = _inventory.firstWhere((i) => i.id == id);
    item.available = !item.available;
    await _save();
    notifyListeners();
  }

  Future<void> updateQuantity(String id, int qty) async {
    final item = _inventory.firstWhere((i) => i.id == id);
    item.quantity = qty;
    await _save();
    notifyListeners();
  }

  // ── Café Orders ───────────────────────
  Future<void> addCafeOrder({
    required String bookingId,
    required List<String> itemIds,
  }) async {
    for (final itemId in itemIds) {
      final item = _inventory.firstWhere((i) => i.id == itemId);
      if (item.available) {
        _orders.add(
          CafeOrder(
            id: _uuid.v4(),
            bookingId: bookingId,
            itemId: itemId,
            quantity: 1,
            priceAtOrder: item.price,
          ),
        );
      }
    }
    await _save();
    notifyListeners();
  }

  // ── Billing ───────────────────────────
  BillingSummary calculateBill(String bookingId, double discountPct) {
    _refreshOverdueStatuses();
    final b = _bookings.firstWhere((x) => x.id == bookingId);
    final checkin = DateTime.parse(b.checkinTime);
    final expected = checkin.add(
      Duration(minutes: (b.durationHours * 60).round()),
    );
    final now = DateTime.now();
    double extraH = 0;
    if (now.isAfter(expected)) {
      final mins = now.difference(expected).inMinutes;
      extraH = (mins / 30).ceil() * 0.5;
    }
    const rates = {'Regular Seat': 20.0, 'Private Office': 50.0, 'Room': 100.0};
    final rate = rates[b.workspaceType] ?? 20.0;
    final wsCharge = (b.durationHours + extraH) * rate;
    final orderList = _orders.where((o) => o.bookingId == bookingId).toList();
    final cafeTotal = orderList.fold(
      0.0,
      (s, o) => s + o.priceAtOrder * o.quantity,
    );
    final gross = wsCharge + cafeTotal;
    final net = gross * (1 - discountPct / 100);
    return BillingSummary(
      booking: b,
      wsCharge: wsCharge,
      extraH: extraH,
      rate: rate,
      cafeTotal: cafeTotal,
      gross: gross,
      net: net,
      cafeOrders: orderList,
    );
  }

  Future<void> processPayment({
    required String bookingId,
    required double total,
    required String method,
    required double discountPct,
  }) async {
    _transactions.add(
      Transaction(
        id: _uuid.v4(),
        bookingId: bookingId,
        total: total,
        paymentMethod: method,
        date: DateTime.now().toIso8601String(),
      ),
    );
    await checkOut(bookingId);
  }

  // ── Reports ───────────────────────────
  DailyReport getDailyReport() {
    _refreshOverdueStatuses();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final t = _transactions.where((x) => x.date.startsWith(today)).toList();
    final rev = t.fold(0.0, (s, x) => s + x.total);
    final methods = <String, double>{};
    for (final x in t) {
      methods[x.paymentMethod] = (methods[x.paymentMethod] ?? 0) + x.total;
    }
    final sessions = _bookings
        .where((b) => b.checkinTime.startsWith(today))
        .length;
    return DailyReport(
      date: today,
      revenue: rev,
      transactions: t,
      sessions: sessions,
      methods: methods,
    );
  }

  MonthlyReport getMonthlyReport() {
    final month = DateTime.now().toIso8601String().substring(0, 7);
    final t = _transactions.where((x) => x.date.startsWith(month)).toList();
    final rev = t.fold(0.0, (s, x) => s + x.total);
    final sessions = _bookings
        .where((b) => b.checkinTime.startsWith(month))
        .length;
    return MonthlyReport(
      month: month,
      revenue: rev,
      transactions: t,
      sessions: sessions,
    );
  }

  List<MapEntry<String, int>> getMostOrdered() {
    final counts = <String, int>{};
    for (final o in _orders) {
      final item = _inventory.firstWhere(
        (i) => i.id == o.itemId,
        orElse: () => InventoryItem(
          id: '',
          name: o.itemId,
          price: 0,
          quantity: 0,
          available: false,
          category: '',
        ),
      );
      final name = item.name;
      counts[name] = (counts[name] ?? 0) + o.quantity;
    }
    return counts.entries.toList()..sort((a, b) => b.value - a.value);
  }

  // ── Backup ────────────────────────────
  String exportJson() {
    final data = {
      'bookings': _bookings.map((b) => b.toJson()).toList(),
      'inventory': _inventory.map((i) => i.toJson()).toList(),
      'orders': _orders.map((o) => o.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
    };
    return jsonEncode(data);
  }

 Future<void> importJson(String raw) async {
  try {
    final decoded = jsonDecode(raw);
    _loadFromJson(decoded);
    await _save();
    notifyListeners();
  } catch (e) {
    print('Invalid JSON: $e');
  }
}

  Future<void> resetAllData() async {
    _bookings = [];
    _orders = [];
    _transactions = [];
    _inventory = _defaultInventory();
    _users = [AppUser(username: 'manager', password: 'admin')];
    await _save();
    logout();
  }

  // ── Workspace capacity ────────────────
  Map<String, Map<String, int>> get workspaceCapacity => {
    'Regular Seat': {
      'total': 10,
      'active': activeBookings
          .where((b) => b.workspaceType == 'Regular Seat')
          .length,
    },
    'Private Office': {
      'total': 4,
      'active': activeBookings
          .where((b) => b.workspaceType == 'Private Office')
          .length,
    },
    'Room': {
      'total': 2,
      'active': activeBookings.where((b) => b.workspaceType == 'Room').length,
    },
  };

  static List<InventoryItem> _defaultInventory() => [
    InventoryItem(
      id: 'i1',
      name: 'Espresso',
      price: 25,
      quantity: 40,
      available: true,
      category: 'Coffee',
    ),
    InventoryItem(
      id: 'i2',
      name: 'Cappuccino',
      price: 30,
      quantity: 25,
      available: true,
      category: 'Coffee',
    ),
    InventoryItem(
      id: 'i3',
      name: 'Latte',
      price: 35,
      quantity: 20,
      available: true,
      category: 'Coffee',
    ),
    InventoryItem(
      id: 'i4',
      name: 'Croissant',
      price: 40,
      quantity: 15,
      available: true,
      category: 'Pastry',
    ),
    InventoryItem(
      id: 'i5',
      name: 'Water Bottle',
      price: 10,
      quantity: 50,
      available: true,
      category: 'Drink',
    ),
    InventoryItem(
      id: 'i6',
      name: 'Americano',
      price: 28,
      quantity: 30,
      available: true,
      category: 'Coffee',
    ),
    InventoryItem(
      id: 'i7',
      name: 'Green Tea',
      price: 22,
      quantity: 20,
      available: true,
      category: 'Drink',
    ),
  ];
}

class BillingSummary {
  final Booking booking;
  final double wsCharge;
  final double extraH;
  final double rate;
  final double cafeTotal;
  final double gross;
  final double net;
  final List<CafeOrder> cafeOrders;

  BillingSummary({
    required this.booking,
    required this.wsCharge,
    required this.extraH,
    required this.rate,
    required this.cafeTotal,
    required this.gross,
    required this.net,
    required this.cafeOrders,
  });
}

class DailyReport {
  final String date;
  final double revenue;
  final List<Transaction> transactions;
  final int sessions;
  final Map<String, double> methods;

  DailyReport({
    required this.date,
    required this.revenue,
    required this.transactions,
    required this.sessions,
    required this.methods,
  });
}

class MonthlyReport {
  final String month;
  final double revenue;
  final List<Transaction> transactions;
  final int sessions;

  MonthlyReport({
    required this.month,
    required this.revenue,
    required this.transactions,
    required this.sessions,
  });
}
