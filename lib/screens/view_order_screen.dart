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
    final statusColor = status == 'pending'
        ? Colors.orange
        : status == 'accepted'
            ? Colors.green
            : Colors.red;

    final user = order['user'] ?? {};
    final paymentStatus = order['paymentStatus'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
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
                    _buildInfoRow(Icons.receipt, 'Order ID:', order['_id'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.attach_money, 'Total Price:', '\$${order['totalPrice'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.payment, 'Payment Status:', paymentStatus),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 16, color: Colors.blue),
                        const SizedBox(width: 10),
                        const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (order['deliveryType'] != null)
                      _buildInfoRow(Icons.delivery_dining, 'Delivery Type:', order['deliveryType']),
                    if (order['scheduleTime'] != null)
                      _buildInfoRow(Icons.schedule, 'Schedule Time:', order['scheduleTime']),
                    if (order['instructions'] != null)
                      _buildInfoRow(Icons.note, 'Instructions:', order['instructions']),
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
            if (items.isEmpty) const Text('No items available.'),
            ...items.map<Widget>((item) {
              final product = item['productId'];
              final productName = (product is Map<String, dynamic>)
                  ? product['name'] ?? 'Unknown Product'
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
                      if (item['wingsFlavor'] != null && item['wingsFlavor'].isNotEmpty)
                        _buildItemDetail('Wings Flavor:', item['wingsFlavor']),
                      if (item['sides'] != null && item['sides'].isNotEmpty)
                        _buildItemDetail('Sides:', item['sides'].join(', ')),
                       if (item['drinks'] != null && (item['drinks'] as List).isNotEmpty)
                          _buildItemDetail(
                            'Drinks:',
                            (item['drinks'] as List)
                                .map((drink) => drink['name'])
                                .join(', '),
                          ),
                      if (item['toppings'] != null && item['toppings'].isNotEmpty)
                        _buildToppingsList('Toppings:', item['toppings']),
                      _buildItemDetail('Quantity:', item['quantity'].toString()),
                      _buildItemDetail('Total Price:', '\$${item['totalPrice']}'),
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
                icon: const Icon(Icons.print, size: 20),
                label: const Text('Print Order'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// **Back to Live Orders**
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Back to Orders'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
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
}