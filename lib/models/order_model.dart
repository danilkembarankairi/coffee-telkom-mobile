class OrderItem {
  final int id;
  final String name;
  final int price;
  final int quantity;
  final String image;
  final String? customization;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    this.customization,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': image,
        'customization': customization,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
      id: 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      image: 'assets/images/coffee.png',
      customization: json['sugarLevel'],
    );
}

class Order {
  static String _mapStatus(String? status) {
  switch (status) {
    case 'processing':
      return 'Processing';
    case 'preparing':
      return 'Preparing';
    case 'ready':
      return 'Ready';
    case 'completed':
      return 'Completed';
    case 'cancelled':
      return 'Cancelled';
    default:
      return 'Processing';
  }
}

  final String id;
  final DateTime orderDate;
  final String orderType; // 'Dine-in' or 'Takeaway'
  final String? tableNumber;
  final String? pickupTime;
  final String paymentMethod;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String
      status; // 'Processing', 'Preparing', 'Ready', 'Completed', 'Cancelled'

  Order({
    required this.id,
    required this.orderDate,
    required this.orderType,
    this.tableNumber,
    this.pickupTime,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
  });

  String get formattedDate {
    return '${orderDate.day}/${orderDate.month}/${orderDate.year} '
        '${orderDate.hour.toString().padLeft(2, '0')}:${orderDate.minute.toString().padLeft(2, '0')}';
  }

  String get statusColor {
    switch (status) {
      case 'Processing':
        return '#FFB300';
      case 'Preparing':
        return '#64B5F6';
      case 'Ready':
        return '#81C784';
      case 'Completed':
        return '#6B5B4F';
      case 'Cancelled':
        return '#E57373';
      default:
        return '#9E9E9E';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderDate': orderDate.toIso8601String(),
        'orderType': orderType,
        'tableNumber': tableNumber,
        'pickupTime': pickupTime,
        'paymentMethod': paymentMethod,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'status': status,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
  final totalAmount =
    (json['totalAmount'] ?? json['total'] ?? 0).toDouble();

final tax =
    (json['tax'] ?? 0).toDouble();

  return Order(
    id: json['_id'] ?? '',
    orderDate: DateTime.parse(
  json['createdAt'] ?? json['orderDate'],
),
    orderType: json['orderType'] ?? 'dine-in',
    tableNumber: json['tableNumber'],
    pickupTime: null,
    paymentMethod: json['paymentMethod'] ?? 'cash',

    items: (json['items'] as List)
        .map((i) => OrderItem.fromJson(i))
        .toList(),

    subtotal: totalAmount - tax,
    tax: tax,
    total: totalAmount,

    status: _mapStatus(json['status']),
  );
}
}

