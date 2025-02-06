import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    fetchOrders(); // ✅ Fetch orders on initialization
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://10.0.0.218:5000/api/orders'));

      if (response.statusCode == 200) {
        _orders = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _orders.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (error) {
      print('❌ Error fetching orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
