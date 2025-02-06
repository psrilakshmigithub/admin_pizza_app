import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_pizza_app/services/order_provider.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:admin_pizza_app/screens/live_orders_screen.dart';
import 'package:admin_pizza_app/screens/menu_management_screen.dart';
import 'package:admin_pizza_app/services/orderlistener_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final OrderListenerService _listenerService = OrderListenerService();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()), // ✅ Added Provider here
      ],
      child: const RootApp(),
    ),
    
  ); 
}

class RootApp extends StatelessWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Pizza App',
      theme: ThemeData(fontFamily: 'NotoSans'),
      home: const AdminDashboard(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _storeOpen = true; // Store status flag
  final String apiUrl = "http://localhost:5000/api/store"; // Backend API URL

  final List<Widget> _screens = [
    const LiveOrdersScreen(),
    const MenuManagementScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenerService.setContext(context);
    Future.delayed(Duration.zero, () => _listenerService.connect());
    fetchStoreStatus();
  }

  @override
  void dispose() {
    _listenerService.disconnect();
    super.dispose();
  }

  Future<void> fetchStoreStatus() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/status"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _storeOpen = data['storeOpen'];
        });
      } else {
        print("Error fetching store status: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> toggleStoreStatus(bool newStatus) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/toggle"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"storeOpen": newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _storeOpen = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? "✅ Store Opened" : "❌ Store Closed"),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print("Error updating store status: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  void _onSelectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer after selecting an item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), centerTitle: true),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text(
                "Admin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text("admin@pizzaapp.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Live Orders'),
              onTap: () => _onSelectScreen(0),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Menu Management'),
              onTap: () => _onSelectScreen(1),
            ),
            const Divider(),
            // Store Open/Close Toggle
            SwitchListTile(
              title: const Text(
                "Store Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_storeOpen ? "🟢 Store is Open" : "🔴 Store is Closed"),
              value: _storeOpen,
              onChanged: (newStatus) {
                toggleStoreStatus(newStatus);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                // Implement logout logic
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Live Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menu Management"),
        ],
      ),
    );
  }
}
