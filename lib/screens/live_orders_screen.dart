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

  /// Refreshes the orders list manually
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
        // Sort orders by date and time (assuming 'createdAt' is available)
        _orders.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
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
      refresh(); // Refresh the list if order was updated
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
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          title: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Order #${order['_id'].toString().substring(0, 6)}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Customer: ${order['user']['name'] ?? 'Unknown'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: order['paymentStatus'] == 'paid' ?  Colors.green : Colors.orange,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    order['paymentStatus'] ?? 'Unknown',
                                    style: TextStyle(color: Colors.white),
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
                                      ? Icon(Icons.delivery_dining, color: Colors.blue)
                                      : Icon(Icons.store_mall_directory, color: Colors.orange),
                                  SizedBox(width: 10),
                                  Text('Total: \$${order['totalPrice'].toStringAsFixed(2)}'),
                                ],
                              ),
                              Text('Order Time: ${order['createdAt']}'),
                              Text('Delivery Type: ${order['deliveryType']}'),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onTap: () => _navigateToOrderDetails(order),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
