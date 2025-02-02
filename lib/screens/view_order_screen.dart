import 'package:flutter/material.dart';

class ViewOrderScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const ViewOrderScreen({Key? key, required this.order}) : super(key: key);

  void _printOrder() {
    print('Printing Order: ${order['_id']}');
    // Implement actual printing logic using `printing` package
  }

  @override
  Widget build(BuildContext context) {
    final items = order['items'] ?? [];
    final status = order['status'] ?? 'Unknown';
    final statusColor = status == 'pending' ? Colors.orange : status == 'accepted' ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Order Summary**
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ID: ${order['_id']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('User ID: ${order['userId']}'),
                    Text('Total Price: \$${order['totalPrice']}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                          child: Text(status, style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    if (order['deliveryType'] != null) Text('Delivery Type: ${order['deliveryType']}'),
                    if (order['scheduleTime'] != null) Text('Schedule Time: ${order['scheduleTime']}'),
                    if (order['instructions'] != null) Text('Instructions: ${order['instructions']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            /// **Order Items**
            const Text('Order Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (items.isEmpty) const Text('No items available.'),
            ...items.map<Widget>((item) {
              final product = item['productId'];
              final productName = (product is Map<String, dynamic>) ? product['name'] ?? 'Unknown Product' : 'Unknown Product';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item['size'] != null) Text('Size: ${item['size']}'),
                      if (item['wingsFlavor'] != null && item['wingsFlavor'].isNotEmpty)
                        Text('Wings Flavor: ${item['wingsFlavor']}'),
                      if (item['sides'] != null && item['sides'].isNotEmpty)
                        Text('Sides: ${item['sides'].join(', ')}'),
                      if (item['toppings'] != null && item['toppings'].isNotEmpty)
                        Text('Toppings: ${item['toppings'].join(', ')}'),
                      Text('Quantity: ${item['quantity']}'),
                      Text('Total Price: \$${item['totalPrice']}'),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),

            /// **Print Button**
            Center(
              child: ElevatedButton.icon(
                onPressed: _printOrder,
                icon: const Icon(Icons.print),
                label: const Text('Print Order'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),

            /// **Back to Live Orders**
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Orders'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
