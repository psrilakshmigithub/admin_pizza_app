import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_pizza_app/models/order.dart';

  class OrderService {
  final String baseUrl = 'http://localhost:5000/api';

  Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));

      // Ensure the status code is successful
      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        // Ensure the response is a List
        if (body is List) {
          return body.map((item) => Order.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching orders: $error');
      rethrow;
    }
  }

 Future<void> insertOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

}

 

