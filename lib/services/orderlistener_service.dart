import 'dart:convert';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:admin_pizza_app/screens/order_details_screen.dart';

class OrderListenerService {
  WebSocketChannel? _channel;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late BuildContext _context;
  VoidCallback? onOrderUpdated; 
  int _reconnectAttempts = 0;
  
  Timer? _reconnectTimer;
  Timer? _watchdogTimer; // Timer to check for server inactivity
  Timer? _missedOrdersCheckTimer; // Timer to periodically check for missed orders
  bool _isConnected = false; // Track connection status

  // Tracks the last time a message was received.
  DateTime? _lastMessageReceivedTime;

  // Set the BuildContext so that we can show dialogs or snackbars.
  void setContext(BuildContext context) {
    _context = context;
  }

  void connect() {
    if (_isConnected) return; // Prevent duplicate connections
    print('🟢 Connecting to WebSocket...');

    try {
      
      _channel = WebSocketChannel.connect(Uri.parse('wss://16b9-64-229-43-36.ngrok-free.app'));
      
      _isConnected = true;
    } catch (e) {
      print('❌ Error establishing WebSocket connection: $e');
      _handleReconnect();
      return;
    }

    // Reset the last message time and start the watchdog timer.
    _lastMessageReceivedTime = DateTime.now();
    _startWatchdogTimer();

    // Start the periodic missed orders check timer.
    _startMissedOrdersCheckTimer();

    // Identify this client as an admin
    _channel!.sink.add(jsonEncode({
      'type': 'identify',
      'clientType': 'admin',
      'adminId': 'admin_001'
    }));

    _channel!.stream.listen(
      (message) {
        print('🔔 New order received: $message');
        // Update the timestamp on every message
        _lastMessageReceivedTime = DateTime.now();
        _playAlarmLoop();
        _showOrderPopup(message);
        _reconnectAttempts = 0; // Reset reconnection attempts after a successful message
      },
      onDone: () {
        print('ℹ️ WebSocket connection closed.');
        _handleReconnect();
      },
      onError: (error) {
        print('⚠️ WebSocket Error: $error');
        _handleReconnect();
      },
    );
  }

  // Starts (or restarts) a periodic watchdog timer.
  void _startWatchdogTimer() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_lastMessageReceivedTime != null) {
        final difference = DateTime.now().difference(_lastMessageReceivedTime!);
        if (difference.inSeconds > 60) {
          print(
              '🔄 No orders received for ${difference.inSeconds} seconds. Assuming server communication failure.');
          _fetchMissedOrders();
          // Reset the timer to avoid fetching repeatedly.
          _lastMessageReceivedTime = DateTime.now();
        }
      }
    });
  }

  // Starts a periodic timer to check for missed orders.
  void _startMissedOrdersCheckTimer() {
    _missedOrdersCheckTimer?.cancel();
    // Check for missed orders every 5 minutes (adjust as needed).
    _missedOrdersCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      print('🔄 Periodically checking for missed orders...');
      _fetchMissedOrders();
    });
  }

  void _handleReconnect() {
    _isConnected = false;
    // Cancel the watchdog timer while reconnecting.
    _watchdogTimer?.cancel();

    // Notify the admin that the connection was lost.
    if (_context.mounted) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Connection lost. Attempting to reconnect...')),
      );
    }

    if (_reconnectAttempts < 10) {
      _reconnectAttempts++;
      // Exponential backoff delay: for example, 2, 4, 6, … seconds.
      final delay = Duration(seconds: _reconnectAttempts * 2);
      print('♻️ Reconnecting in ${delay.inSeconds} seconds (Attempt $_reconnectAttempts)...');
      _reconnectTimer = Timer(delay, connect);
    } else {
      print('🚨 Max reconnect attempts reached. Fetching missed orders...');
      _fetchMissedOrders();
      _reconnectAttempts = 0; // Reset attempts for future reconnection cycles
      // Try reconnecting after a fixed delay even after fetching missed orders.
      _reconnectTimer = Timer(const Duration(seconds: 10), connect);
    }
  }

  Future<void> _fetchMissedOrders() async {
    try {
      print('🔄 Fetching missed orders from the server...');
      final response = await http.get(Uri.parse('http://10.0.0.218:5000/api/orders/missed'));
      if (response.statusCode == 200) {
         print('🔄 Fetching missed orders from the server... ${jsonDecode(response.body)}');
        final List<dynamic> missedOrders = jsonDecode(response.body);
        for (var order in missedOrders) {
          _showOrderPopup(jsonEncode(order));
        }
      } else {
        print('⚠️ Failed to fetch missed orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching missed orders: $e');
    }
  }

  Future<void> _playAlarmLoop() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      // Ensure the asset path is correct and that the user has interacted with the app before playing sound.
      await _audioPlayer.play(AssetSource('alarm.mp3'));
    } catch (e) {
      print('❌ Error playing alarm sound: $e');
    }
  }

  void _showOrderPopup(String message) {
    if (!_context.mounted) return; // Prevent showing the dialog if context is invalid

    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Order Received'),
          content: const Text('Status: New Order'),
          actions: <Widget>[
            TextButton(
              child: const Text('View Order Details'),
              onPressed: () {
                stopAlarm();
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderDetailsScreen(order: jsonDecode(message),onOrderUpdated: onOrderUpdated ?? () {},),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void stopAlarm() {
    _audioPlayer.stop();
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _watchdogTimer?.cancel();
    _missedOrdersCheckTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
  }
}