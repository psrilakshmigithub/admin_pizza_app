import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:admin_pizza_app/services/order_provider.dart'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'order_details_screen.dart';
import 'view_order_screen.dart';

class LiveOrdersScreen extends StatelessWidget {
  const LiveOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Live Orders')),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
              ? const Center(child: Text('No live orders available.'))
              : RefreshIndicator(
                  onRefresh: () => orderProvider.fetchOrders(),
                  child: ListView(
                    children: _groupOrdersByDate(orderProvider.orders).entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(entry.key), // Date header
                          ...entry.value.map((order) => _buildOrderCard(order, context, orderProvider)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  /// **Groups orders by date**
  Map<String, List<Map<String, dynamic>>> _groupOrdersByDate(List<Map<String, dynamic>> orders) {
    final Map<String, List<Map<String, dynamic>>> groupedOrders = {};

    for (var order in orders) {
      String formattedDate = _formatDate(order['createdAt']);
      if (!groupedOrders.containsKey(formattedDate)) {
        groupedOrders[formattedDate] = [];
      }
      groupedOrders[formattedDate]!.add(order);
    }

    return groupedOrders;
  }

  /// **Builds the date header**
  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        date,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  /// **Formats `createdAt` timestamp to a readable format**
  String _formatDate(String createdAt) {
    DateTime dateTime = DateTime.parse(createdAt);
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime); // Example: Monday, Feb 5, 2024
  }

  /// **Formats time from `createdAt`**
  String _formatTime(String createdAt) {
    DateTime dateTime = DateTime.parse(createdAt);
    return DateFormat('hh:mm a').format(dateTime); // Example: 02:30 PM
  }

  /// **Builds the Order Card**
  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context, OrderProvider orderProvider) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Order #${order['_id'].toString().substring(0, 6)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Customer: ${order['user']['name'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: order['paymentStatus'] == 'paid' ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  order['paymentStatus'] ?? 'Unknown',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                order['deliveryType'] == 'delivery'
                    ? const Icon(Icons.delivery_dining, color: Colors.blue)
                    : const Icon(Icons.store_mall_directory, color: Colors.orange),
                const SizedBox(width: 10),
                Text('Total: \$${order['totalPrice'].toStringAsFixed(2)}'),
              ],
            ),
            Text('Order Time: ${_formatTime(order['createdAt'])}'),
            Text('Delivery Type: ${order['deliveryType']}'),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => order['status'] == 'pending'
                  ? OrderDetailsScreen(
                      order: order,
                      onOrderUpdated: () {
                        orderProvider.fetchOrders(); // Refresh orders on update
                      },
                    )
                  : ViewOrderScreen(order: order),
            ),
          );
        },
      ),
    );
  }
}
