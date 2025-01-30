import 'package:flutter/material.dart';
import 'package:admin_pizza_app/models/order.dart';
import 'package:admin_pizza_app/services/order_service.dart';

class LiveOrdersScreen extends StatefulWidget {
  const LiveOrdersScreen({Key? key}) : super(key: key);

  @override
  _LiveOrdersScreenState createState() => _LiveOrdersScreenState();
}

class _LiveOrdersScreenState extends State<LiveOrdersScreen> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      var ordersList = await OrderService().getOrders();
      setState(() {
        orders = ordersList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Orders'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Order ID: ${orders[index].id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${orders[index].userId}'),
                          Text('Delivery Type: ${orders[index].deliveryType}'),
                          Text('Status: ${orders[index].status}'),
                          Text('Total Price: \$${orders[index].totalPrice}'),
                          Text('Items:'),
                          ...orders[index].items.map((item) => Text(
                                'Product ID: ${item.productId}, Quantity: ${item.quantity}, Total Price: \$${item.totalPrice}',
                              )),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}