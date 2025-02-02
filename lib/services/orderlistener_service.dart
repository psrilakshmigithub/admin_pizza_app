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
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _isConnected = false; // ✅ Track connection status

  void setContext(BuildContext context) {
    _context = context;
  }

  void connect() {
    if (_isConnected) return; // ✅ Prevent duplicate connections
    print('🟢 Connecting to WebSocket...');

    _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.0.218:5000'));
    _isConnected = true;

    // Identify this client as an admin
    _channel!.sink.add(jsonEncode({
      'type': 'identify',
      'clientType': 'admin',
      'adminId': 'admin_001'
    }));

    _channel!.stream.listen(
      (message) {
        print('🔔 New order received: $message');
        _playAlarmLoop();
        _showOrderPopup(message);
        _reconnectAttempts = 0; // ✅ Reset reconnection attempts
      },
      onDone: _handleReconnect,
      onError: (error) {
        print('⚠️ WebSocket Error: $error');
        _handleReconnect();
      },
    );
  }

  void _handleReconnect() {
    _isConnected = false;
    if (_reconnectAttempts < 10) { // ✅ Increase reconnection attempts
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);
      print('♻️ Reconnecting in ${delay.inSeconds} seconds...');
      _reconnectTimer = Timer(delay, connect);
    } else {
      print('🚨 Max reconnect attempts reached. Fetching missed orders...');
      _fetchMissedOrders();
      _reconnectAttempts = 0; // ✅ Reset and try connecting again
      Timer(const Duration(seconds: 10), connect);
    }
  }

  Future<void> _fetchMissedOrders() async {
    try {
      print('🔄 Fetching missed orders...');
      final response = await http.get(Uri.parse('http://10.0.0.218:5000/api/orders/missed'));
      if (response.statusCode == 200) {
        final List<dynamic> missedOrders = jsonDecode(response.body);
        for (var order in missedOrders) {
          _showOrderPopup(jsonEncode(order));
        }
      } else {
        print('⚠️ Failed to fetch missed orders.');
      }
    } catch (e) {
      print('❌ Error fetching missed orders: $e');
    }
  }

  Future<void> _playAlarmLoop() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('alarm.mp3')); // Ensure correct asset path
    } catch (e) {
      print('❌ Error playing alarm sound: $e');
    }
  }

  void _showOrderPopup(String message) {
    if (!_context.mounted) return; // ✅ Prevent showing the dialog if context is invalid  

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
                    builder: (context) => OrderDetailsScreen(order: jsonDecode(message)),
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
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
  }
}
