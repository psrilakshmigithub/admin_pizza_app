import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'order_details_screen.dart';
import 'view_order_screen.dart';

class LiveOrdersScreen extends StatefulWidget {
  const LiveOrdersScreen({Key? key}) : super(key: key);

  @override
  _LiveOrdersScreenState createState() => _LiveOrdersScreenState();
}

class _LiveOrdersScreenState extends State<LiveOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

 /// ✅ Refreshes the orders list manually
  Future<void> refresh() async {
    await _fetchOrders();
  }
  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final response = await http.get(Uri.parse('http://10.0.0.218:5000/api/orders'));

    if (response.statusCode == 200) {
      setState(() {
        _orders = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch orders')),
      );
    }
  }

  void _navigateToOrderDetails(Map<String, dynamic>? order) async {
    if (order == null || !order.containsKey('_id') || !order.containsKey('status')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Invalid order data')),
      );
      return;
    }

    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => order['status'] == 'pending'
            ? OrderDetailsScreen(order: order)
            : ViewOrderScreen(order: order),
      ),
    );

    if (updated == true) {
      refresh(); // ✅ Refresh the list if order was updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Orders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No live orders available.'))
              : RefreshIndicator(
                  onRefresh: _fetchOrders,
                  child: ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text('Order ID: ${order['_id'] ?? 'N/A'}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Price: \$${order['totalPrice'] ?? '0.00'}'),
                              Text('Status: ${order['status'] ?? 'Unknown'}'),
                              Text('Delivery Type: ${order['deliveryType'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _navigateToOrderDetails(order),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
