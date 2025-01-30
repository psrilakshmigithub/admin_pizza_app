// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'live_orders_screen.dart';

// class OrderDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> order;

//   const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

//   @override
//   _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
// }

// class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final items = widget.order['items'] ?? [];

//     return Scaffold(
//       appBar: AppBar(title: const Text('Order Details')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Order ID: ${widget.order['_id'] ?? 'N/A'}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'User ID: ${widget.order['userId'] ?? 'N/A'}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Total Price: \$${widget.order['totalPrice'] ?? 'N/A'}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Items:',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),

//             if (items.isEmpty)
//               const Text('No items available.'), // Handle empty list
//             ...items.map<Widget>((item) {
//               final product = item['productId'];
//               final productName = (product is Map<String, dynamic>) ? product['name'] ?? 'Unknown Product' : 'Unknown Product';

//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Product Name: $productName'),
//                     Text('Size: ${item['size'] ?? 'N/A'}'),
//                     if (item['wingsFlavor'] != null && item['wingsFlavor'].isNotEmpty)
//                       Text('Wings Flavor: ${item['wingsFlavor']}'),
//                     if (item['sides'] != null && item['sides'].isNotEmpty)
//                       Text('Sides: ${item['sides'].join(', ')}'),
//                     if (item['toppings'] != null && item['toppings'].isNotEmpty)
//                       Text('Toppings: ${item['toppings'].join(', ')}'),
//                     Text('Quantity: ${item['quantity'] ?? 'N/A'}'),
//                     Text('Total Price: \$${item['totalPrice'] ?? 'N/A'}'),
//                   ],
//                 ),
//               );
//             }).toList(),

//             const SizedBox(height: 20),
//             Text(
//               'Delivery Type: ${widget.order['deliveryType'] ?? 'N/A'}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => _showAcceptOrderDialog(context),
//                   child: const Text('Accept Order'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _showDeclineOrderDialog(context),
//                   child: const Text('Decline Order'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAcceptOrderDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Accept Order'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Select preparation time:'),
//               DropdownButton<int>(
//                 items: [10, 20, 40, 60, 120].map((int value) {
//                   return DropdownMenuItem<int>(
//                     value: value,
//                     child: Text('$value minutes'),
//                   );
//                 }).toList(),
//                 onChanged: (int? value) {
//                   if (value != null) {
//                     _confirmAcceptOrder(context, value);
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//  void _confirmAcceptOrder(BuildContext context, int preparationTime) async {
//   if (!mounted) return; // Prevent running if widget is unmounted

//   Navigator.of(context).pop(); // Close the dialog immediately

//   try {
//     final response = await http.post(
//       Uri.parse('http://10.0.0.218:5000/api/orders/accept'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'orderId': widget.order['_id'],
//         'preparationTime': preparationTime,
//       }),
//     );

//     if (!mounted) return; // Prevent accessing context after unmount

//     final message = response.statusCode == 200
//         ? 'Order accepted successfully'
//         : 'Failed to accept order';

//     // Delay UI updates slightly to prevent "Looking up a deactivated widget" error
//     Future.delayed(Duration.zero, () {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//       }
//     });

//     if (response.statusCode == 200) {
//       Future.delayed(Duration.zero, () {
//         if (mounted) {
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const LiveOrdersScreen()),
//             (Route<dynamic> route) => false,
//           );
//         }
//       });
//     }
//   } catch (e) {
//     if (!mounted) return;
    
//     Future.delayed(Duration.zero, () {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     });
//   }
// }
//   void _showDeclineOrderDialog(BuildContext context) {
//     String? selectedReason;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Decline Order'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Select reason for declining:'),
//               DropdownButton<String>(
//                 items: ['Busy', 'Closed'].map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: (String? value) {
//                   selectedReason = value;
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (selectedReason != null) {
//                   Navigator.of(context).pop();
//                   _confirmDeclineOrder(context, selectedReason!);
//                 }
//               },
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );
//   }

// void _confirmDeclineOrder(BuildContext context, String reason) async {
//   if (!mounted) return; // Prevent running if widget is unmounted

//   try {
//     final response = await http.post(
//       Uri.parse('http://10.0.0.218:5000/api/orders/decline'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'orderId': widget.order['_id'],
//         'reason': reason,
//       }),
//     );

//     if (!mounted) return; // Prevent accessing context after unmount

//     final message = response.statusCode == 200
//         ? 'Order declined successfully'
//         : 'Failed to decline order';

//     // Delay UI updates slightly to prevent "Looking up a deactivated widget" error
//     Future.delayed(Duration.zero, () {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//       }
//     });

//     if (response.statusCode == 200) {
//       Future.delayed(Duration.zero, () {
//         if (mounted) {
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const LiveOrdersScreen()),
//             (Route<dynamic> route) => false,
//           );
//         }
//       });
//     }
//   } catch (e) {
//     if (!mounted) return;

//     Future.delayed(Duration.zero, () {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     });
//   }
// }

// }
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
  @override
  Widget build(BuildContext context) {
    final items = widget.order['items'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Padding(
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
            Text(
              'Items:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (items.isEmpty)
              const Text('No items available.'),
            ...items.map<Widget>((item) {
              final product = item['productId'];
              final productName =
                  (product is Map<String, dynamic>) ? product['name'] ?? 'Unknown Product' : 'Unknown Product';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Name: $productName'),
                    Text('Size: ${item['size'] ?? 'N/A'}'),
                    if (item['wingsFlavor'] != null && item['wingsFlavor'].isNotEmpty)
                      Text('Wings Flavor: ${item['wingsFlavor']}'),
                    if (item['sides'] != null && item['sides'].isNotEmpty)
                      Text('Sides: ${item['sides'].join(', ')}'),
                    if (item['toppings'] != null && item['toppings'].isNotEmpty)
                      Text('Toppings: ${item['toppings'].join(', ')}'),
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
                  onPressed: () => _showAcceptOrderDialog(context),
                  child: const Text('Accept Order'),
                ),
                ElevatedButton(
                  onPressed: () => _showDeclineOrderDialog(context),
                  child: const Text('Decline Order'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select preparation time:'),
              DropdownButton<int>(
                items: [10, 20, 40, 60, 120].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value minutes'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  if (value != null) {
                    _confirmAcceptOrder(value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmAcceptOrder(int preparationTime) async {
    if (!mounted) return;

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

      if (!mounted) return;

      final message = response.statusCode == 200 ? 'Order accepted successfully' : 'Failed to accept order';

      // ✅ Safely update UI
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          if (response.statusCode == 200) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LiveOrdersScreen()),
              (Route<dynamic> route) => false,
            );
          }
        }
      });
    } catch (e) {
      if (!mounted) return;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      });
    }
  }

  void _showDeclineOrderDialog(BuildContext context) {
    String? selectedReason;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Decline Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select reason for declining:'),
              DropdownButton<String>(
                items: ['Busy', 'Closed'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  selectedReason = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedReason != null) {
                  Navigator.of(context).pop();
                  _confirmDeclineOrder(selectedReason!);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeclineOrder(String reason) async {
    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.218:5000/api/orders/decline'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': widget.order['_id'],
          'reason': reason,
        }),
      );

      if (!mounted) return;

      final message = response.statusCode == 200 ? 'Order declined successfully' : 'Failed to decline order';

      // ✅ Safely update UI
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          if (response.statusCode == 200) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LiveOrdersScreen()),
              (Route<dynamic> route) => false,
            );
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      });
    }
  }
}
