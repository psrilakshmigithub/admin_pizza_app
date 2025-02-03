import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';
import 'live_orders_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      // Wrapping the main content in a SingleChildScrollView prevents overflow.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order['_id'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'User ID: ${widget.order['userId'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Price: \$${widget.order['totalPrice'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...items.map<Widget>((item) {
              final Map<String, dynamic>? product = item['productId'];
              final String productName = (product != null && product.containsKey('name'))
                  ? product['name']
                  : 'Unknown Product';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item Name: $productName'),
                    Text('Size: ${item['size'] ?? 'N/A'}'),
                    if (item['wingsFlavor'] != null &&
                        (item['wingsFlavor'] as String).isNotEmpty)
                      Text('Wings Flavor: ${item['wingsFlavor']}'),
                    if (item['sides'] != null && (item['sides'] as List).isNotEmpty)
                      Text('Sides: ${(item['sides'] as List).join(', ')}'),
                    if (item['toppings'] != null && (item['toppings'] as List).isNotEmpty)
                      Text('Toppings: ${(item['toppings'] as List).join(', ')}'),
                    Text('Quantity: ${item['quantity'] ?? 'N/A'}'),
                    Text('Total Price: \$${item['totalPrice'] ?? 'N/A'}'),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Text(
              'Delivery Type: ${widget.order['deliveryType'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _showAcceptOrderDialog,
                  child: const Text('Accept Order'),
                ),
                ElevatedButton(
                  onPressed: _showDeclineOrderDialog,
                  child: const Text('Decline Order'),
                ),
              ],
            ),
          ],
        ),
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

  /// Confirm Accept Order
  void _confirmAcceptOrder(int preparationTime) async {
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

      final message =
          response.statusCode == 200 ? 'Order accepted successfully' : 'Failed to accept order';
      _showSnackbar(message);

      if (response.statusCode == 200) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pop(true);
        });
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
    setState(() => _isProcessing = true);
    Navigator.of(context).pop();

    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.218:5000/api/orders/decline'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': widget.order['_id'], 'reason': reason}),
      );

      final message =
          response.statusCode == 200 ? 'Order declined' : 'Failed to decline order';
      _showSnackbar(message);

      if (response.statusCode == 200) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
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
