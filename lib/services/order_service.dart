import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<Order> _orders = [];
  String? _currentUserId;

  List<Order> get orders => List.unmodifiable(_orders);

  // Load orders milik user yang sedang login
  Future<void> loadOrdersForUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      _currentUserId = prefs.getString('userEmail') ?? 'guest';
    }
    if (_currentUserId == null || _currentUserId == 'guest') {
      _orders.clear();
      return;
    }
    final key = 'orders_$_currentUserId';
    final raw = prefs.getString(key);
    _orders.clear();
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _orders.addAll(decoded.map((e) => Order.fromJson(e)));
    }
  }

  // Simpan orders ke SharedPreferences
  Future<void> _saveOrders() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'orders_$_currentUserId';
    final encoded = jsonEncode(_orders.map((o) => o.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  // Tambah order baru
  Future<void> addOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      // Fallback: pakai email sebagai key jika userId kosong
      _currentUserId = prefs.getString('userEmail') ?? 'guest';
    }
    _orders.insert(0, order);
    await _saveOrders();
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update status order
  Future<void> updateOrderStatus(String id, String newStatus) async {
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
      await _saveOrders();
    }
  }

  void clearOrders() {
    _orders.clear();
  }
}