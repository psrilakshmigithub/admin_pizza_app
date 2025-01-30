import 'dart:convert';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
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

  void setContext(BuildContext context) {
    _context = context;
  }

  void connect() {
    print('Connecting to WebSocket...');
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.0.218:5000'),
    );
// Identify this client as an admin with an adminId
  _channel!.sink.add(jsonEncode({
    'type': 'identify',
    'clientType': 'admin',
    'adminId': 'admin_001' // You can dynamically set this
  }));

    _channel!.stream.listen(
      (message) {
        print('New order received: $message');
        _playAlarmLoop(); // Start alarm immediately
        _showOrderPopup(message);
        _reconnectAttempts = 0; // Reset reconnection attempts on success
      },
      onDone: _handleReconnect,
      onError: (error) {
        print('WebSocket Error: $error');
        _handleReconnect();
      },
    );
  }

  void _handleReconnect() {
    print('WebSocket disconnected. Attempting to reconnect...');
    if (_reconnectAttempts >= 5) {
      print('Max reconnection attempts reached. Stopping reconnection.');
      return;
    }

    _reconnectAttempts++;
    int delay = _reconnectAttempts * 2; // Exponential backoff (2s, 4s, 6s...)
    _reconnectTimer = Timer(Duration(seconds: delay), connect);
  }

  Future<void> _playAlarmLoop() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('alarm.mp3')); // Ensure correct asset path
    } catch (e) {
      print('Error playing alarm sound: $e');
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
  }
}
