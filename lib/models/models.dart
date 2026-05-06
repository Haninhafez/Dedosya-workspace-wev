class AppUser {
  String username;
  String password;

  AppUser({required this.username, required this.password});

  factory AppUser.fromJson(Map<String, dynamic> j) =>
      AppUser(username: j['username'], password: j['password']);

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class Booking {
  final String id;
  String clientName;
  String workspaceType;
  String checkinTime;
  double durationHours;
  String status; // active | overdue | checked-out
  String? checkoutTime;
  bool notifyBefore;
  String source; // walk-in | facebook

  Booking({
    required this.id,
    required this.clientName,
    required this.workspaceType,
    required this.checkinTime,
    required this.durationHours,
    required this.status,
    this.checkoutTime,
    this.notifyBefore = false,
    this.source = 'walk-in',
  });
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
    id: j['id'] ?? '',
    clientName: j['clientName'] ?? '',
    workspaceType: j['workspaceType'] ?? '',
    checkinTime: j['checkinTime'] ?? '',
    durationHours: (j['durationHours'] ?? 0).toDouble(),
    status: j['status'] ?? 'active',
    checkoutTime: j['checkoutTime'],
    notifyBefore: j['notifyBefore'] ?? false,
    source: j['source'] ?? 'walk-in',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientName': clientName,
    'workspaceType': workspaceType,
    'checkinTime': checkinTime,
    'durationHours': durationHours,
    'status': status,
    'checkoutTime': checkoutTime,
    'notifyBefore': notifyBefore,
    'source': source,
  };
}

class InventoryItem {
  final String id;
  String name;
  double price;
  int quantity;
  bool available;
  String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.available,
    required this.category,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
    id: j['id'],
    name: j['name'],
    price: (j['price'] as num).toDouble(),
    quantity: j['quantity'],
    available: j['available'],
    category: j['category'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'available': available,
    'category': category,
  };
}

class CafeOrder {
  final String id;
  final String bookingId;
  final String itemId;
  final int quantity;
  final double priceAtOrder;

  CafeOrder({
    required this.id,
    required this.bookingId,
    required this.itemId,
    required this.quantity,
    required this.priceAtOrder,
  });

  factory CafeOrder.fromJson(Map<String, dynamic> j) => CafeOrder(
    id: j['id'],
    bookingId: j['bookingId'],
    itemId: j['itemId'],
    quantity: j['quantity'],
    priceAtOrder: (j['price'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingId': bookingId,
    'itemId': itemId,
    'quantity': quantity,
    'priceAtOrder': priceAtOrder,
  };
}

class Transaction {
  final String id;
  final String bookingId;
  final double total;
  final String paymentMethod;
  final String date;

  Transaction({
    required this.id,
    required this.bookingId,
    required this.total,
    required this.paymentMethod,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
    id: j['id'],
    bookingId: j['bookingId'],
    total: (j['total'] as num).toDouble(),
    paymentMethod: j['paymentMethod'],
    date: j['date'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingId': bookingId,
    'total': total,
    'paymentMethod': paymentMethod,
    'date': date,
  };
}
