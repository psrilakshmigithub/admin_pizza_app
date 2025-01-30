import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<dynamic> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    final response = await http.get(Uri.parse('http://10.0.0.218:5000/api/products'));
    if (response.statusCode == 200) {
      setState(() {
        _menuItems = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load menu items')),
      );
    }
  }

  Future<void> _toggleSoldOut(String productId, bool isSoldOut) async {
    final response = await http.put(
      Uri.parse('http://10.0.0.218:5000/api/products/$productId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isSoldOut': isSoldOut}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _menuItems = _menuItems.map((item) {
          if (item['_id'] == productId) {
            item['isSoldOut'] = isSoldOut;
          }
          return item;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isSoldOut ? 'Marked as Sold Out' : 'Available again')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management')),
      body: _menuItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Price: \$${item['price']}'),
                  trailing: Switch(
                    value: item['isSoldOut'] ?? false,
                    onChanged: (bool value) => _toggleSoldOut(item['_id'], value),
                  ),
                );
              },
            ),
    );
  }
}
