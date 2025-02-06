import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_pizza_app/services/order_provider.dart'; 
import 'package:http/http.dart' as http;
import 'live_orders_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;


 final VoidCallback onOrderUpdated; // Receive callback function

  const OrderDetailsScreen({Key? key, required this.order, required this.onOrderUpdated})
      : super(key: key);
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isProcessing = false; // Prevents multiple requests
  int? selectedTime;
  String? selectedReason;

  @override
  Widget build(BuildContext context) {
    final items = widget.order['items'] ?? [];
    final user = widget.order['user'] ?? {};
    final paymentStatus = widget.order['paymentStatus'] ?? 'Unknown';

    return Scaffold(      
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
        actions: [
          ElevatedButton.icon(
            onPressed: _showAcceptOrderDialog,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _showDeclineOrderDialog,
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text('Decline'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **User Details**
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person, 'Name:', user['name'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.email, 'Email:', user['email'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.phone, 'Phone:', user['phone'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.location_on, 'Delivery Address:', user['address'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// **Order Summary**
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.receipt, 'Order ID:', widget.order['_id'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.attach_money, 'Total Price:', '\$${widget.order['totalPrice'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.payment, 'Payment Status:', paymentStatus),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.delivery_dining, 'Delivery Type:', widget.order['deliveryType'] ?? 'N/A'),
                    if (widget.order['scheduleTime'] != null)
                      _buildInfoRow(Icons.schedule, 'Schedule Time:', widget.order['scheduleTime']),
                    if (widget.order['instructions'] != null)
                      _buildInfoRow(Icons.note, 'Instructions:', widget.order['instructions']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// **Order Items**
            const Text(
              'Order Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...items.map<Widget>((item) {
              final Map<String, dynamic>? product = item['productId'];
              final String productName = (product != null && product.containsKey('name'))
                  ? product['name']
                  : 'Unknown Product';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildItemDetail('Item Name:', productName),
                      if (item['size'] != null) _buildItemDetail('Size:', item['size']),
                      if (item['wingsFlavor'] != null && (item['wingsFlavor'] as String).isNotEmpty)
                        _buildItemDetail('Wings Flavor:', item['wingsFlavor']),
                      if (item['drinks'] != null && (item['drinks'] as List).isNotEmpty)
                        _buildItemDetail(
                          'Drinks:',
                          (item['drinks'] as List).map((drink) => drink['name']).join(', '),
                        ),
                      if (item['sides'] != null && (item['sides'] as List).isNotEmpty)
                        _buildItemDetail('Sides:', (item['sides'] as List).join(', ')),
                      if (item['toppings'] != null && (item['toppings'] as List).isNotEmpty)
                        _buildItemDetail('Toppings:', (item['toppings'] as List).join(', ')),
                      _buildItemDetail('Quantity:', item['quantity']?.toString() ?? 'N/A'),
                      _buildItemDetail('Total Price:', '\$${item['totalPrice'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildItemDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToppingsList(String label, List<dynamic> toppings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          ...toppings.map<Widget>((topping) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                '- $topping',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Accept Order Dialog
  void _showAcceptOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Accept Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select preparation time:'),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: selectedTime,
                    hint: const Text("Choose time"),
                    items: [10, 20, 40, 60, 120].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value minutes'),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setDialogState(() {
                        selectedTime = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: selectedTime != null
                      ? () => _confirmAcceptOrder(selectedTime!)
                      : null,
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

void _confirmAcceptOrder(int preparationTime) async {
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);
  setState(() => _isProcessing = true);
  Navigator.of(context).pop();

  try {
    final response = await http.post(
      Uri.parse('http://10.0.0.218:5000/api/orders/accept'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'orderId': widget.order['_id'],
        'preparationTime': preparationTime,
      }),
    );

    if (response.statusCode == 200) {
      await orderProvider.fetchOrders(); // Refresh the orders list
      Navigator.of(context).pop(true);
    } else {
      _showSnackbar('Failed to accept order: ${response.body}');
    }
  } catch (e) {
    _showSnackbar('Error: $e');
  } finally {
    setState(() => _isProcessing = false);
  }
}

  /// Decline Order Dialog
  void _showDeclineOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Decline Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select reason for declining:'),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedReason,
                    hint: const Text("Choose reason"),
                    items: ['Busy', 'Closed'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setDialogState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: selectedReason != null
                      ? () => _confirmDeclineOrder(selectedReason!)
                      : null,
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Confirm Decline Order
void _confirmDeclineOrder(String reason) async {
   final orderProvider = Provider.of<OrderProvider>(context, listen: false);
  setState(() => _isProcessing = true);
  Navigator.of(context).pop(); // Close Dialog

  try {
    final response = await http.post(
      Uri.parse('http://10.0.0.218:5000/api/orders/decline'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': widget.order['_id'], 'reason': reason}),
    );

    final message = response.statusCode == 200 ? 'Order declined' : 'Failed to decline order';
    _showSnackbar(message);

    if (response.statusCode == 200) {
      await orderProvider.fetchOrders(); // Refresh the orders list
      Navigator.of(context).pop(true);
    } else {
      _showSnackbar('Failed to accept order: ${response.body}');
    }
  } catch (e) {
    _showSnackbar('Error: $e');
  } finally {
    setState(() => _isProcessing = false);
  }
}

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToOrdersScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LiveOrdersScreen()),
      (Route<dynamic> route) => false,
    );
  }
}