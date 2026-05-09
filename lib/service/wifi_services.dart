import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/ecg_data.dart';

class WifiService {
  WebSocketChannel? _channel;

  final _dataController = StreamController<EcgData>.broadcast();
  final _stateController = StreamController<String>.broadcast();

  Stream<EcgData> get dataStream => _dataController.stream;
  Stream<String> get stateStream => _stateController.stream;

  bool get isConnected => _channel != null;

  // IP del hotspot del ESP32 (siempre es esta cuando el ESP32 crea el AP)
  static const String _ip = '192.168.4.1';
  static const int _port = 81;

  Future<void> connect() async {
    try {
      _stateController.add('Conectando...');
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$_ip:$_port'),
      );
      _stateController.add('Conectado ✓');

      _channel!.stream.listen(
        (data) => _onData(data.toString()),
        onDone: () {
          _stateController.add('Desconectado');
          _channel = null;
        },
        onError: (e) {
          _stateController.add('Error: $e');
          _channel = null;
        },
      );
    } catch (e) {
      _stateController.add('Error: $e');
    }
  }

  void _onData(String linea) {
    try {
      final partes = linea.trim().split(',');
      if (partes.length != 2) return;

      final ecgValue = int.parse(partes[0]);
      final bpm = int.parse(partes[1]);

      _dataController.add(EcgData(
        ecgValue: ecgValue,
        bpm: bpm,
        leadOff: false,
        timestamp: DateTime.now(),
      ));
    } catch (_) {}
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _stateController.add('Desconectado');
  }

  void dispose() {
    _dataController.close();
    _stateController.close();
  }
}
