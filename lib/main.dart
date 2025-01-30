import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:admin_pizza_app/screens/live_orders_screen.dart';
import 'package:admin_pizza_app/screens/menu_management_screen.dart';
import 'package:admin_pizza_app/services/orderlistener_service.dart';

final OrderListenerService _listenerService = OrderListenerService();

void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Pizza App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSans',
      ),
      home: const AdminDashboard(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
      ],
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

  final List<Widget> _screens = [
    const LiveOrdersScreen(),
    const MenuManagementScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenerService.setContext(context);
    _listenerService.connect();
  }

  @override
  void dispose() {
    _listenerService.disconnect();
    super.dispose();
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
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
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
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
