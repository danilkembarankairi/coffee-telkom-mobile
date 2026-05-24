import '../models/order_model.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // In-memory storage (untuk demo - nanti bisa diganti dengan database)
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  // Tambah order baru
  void addOrder(Order order) {
    _orders.insert(0, order); // Tambah di awal (terbaru dulu)
  }

  // ✅ LEBIH BAIK - Gunakan firstWhere dengan try-catch
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update status order
  void updateOrderStatus(String id, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      final order = _orders[index];
      _orders[index] = Order(
        id: order.id,
        orderDate: order.orderDate,
        orderType: order.orderType,
        tableNumber: order.tableNumber,
        pickupTime: order.pickupTime,
        paymentMethod: order.paymentMethod,
        items: order.items,
        subtotal: order.subtotal,
        tax: order.tax,
        total: order.total,
        status: newStatus,
      );
    }
  }

  // Hapus order (untuk testing)
  void removeOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
  }

  // Clear semua order (untuk testing)
  void clearOrders() {
    _orders.clear();
  }

  // Generate sample orders untuk demo
  void addSampleOrders() {
    if (_orders.isNotEmpty) return;

    addOrder(Order(
      id: 'CT-20241215-001',
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      orderType: 'Dine-in',
      tableNumber: 'Table 3',
      paymentMethod: 'QRIS',
      items: [
        OrderItem(
          id: 1,
          name: 'ICED LATTE',
          price: 30000,
          quantity: 2,
          image: 'assets/images/iced-latte.jpg',
          customization: 'Size: M • Sugar: 50%',
        ),
      ],
      subtotal: 60000,
      tax: 6600,
      total: 66600,
      status: 'Completed',
    ));

    addOrder(Order(
      id: 'CT-20241215-002',
      orderDate: DateTime.now().subtract(const Duration(minutes: 30)),
      orderType: 'Takeaway',
      pickupTime: '15:45',
      paymentMethod: 'GoPay',
      items: [
        OrderItem(
          id: 4,
          name: 'COLD BREW',
          price: 33000,
          quantity: 1,
          image: 'assets/images/coldbrew.jpeg',
          customization: 'Size: L • No ice',
        ),
        OrderItem(
          id: 3,
          name: 'MATCHA LATTE',
          price: 33000,
          quantity: 1,
          image: 'assets/images/matcha-latte.jpg',
        ),
      ],
      subtotal: 66000,
      tax: 7260,
      total: 73260,
      status: 'Preparing',
    ));
  }
}
