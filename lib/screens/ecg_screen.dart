import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/ecg_data.dart';
import '../services/wifi_service.dart'; // <-- cambio

class EcgScreen extends StatefulWidget {
  const EcgScreen({super.key});
  @override
  State<EcgScreen> createState() => _EcgScreenState();
}

class _EcgScreenState extends State<EcgScreen> {
  final WifiService _ble = WifiService(); // <-- cambio
  final List<FlSpot> _points = [];
  double _x = 0;
  int _bpm = 0;
  bool _leadOff = false;
  String _status = 'Desconectado';
  bool _connected = false;

  int _age = 25;
  String _sex = 'Masculino';

  static const int _maxPoints = 200;

  @override
  void initState() {
    super.initState();
    _ble.stateStream.listen((s) => setState(() => _status = s));
    _ble.dataStream.listen(_onData);
  }

  void _onData(EcgData data) {
    setState(() {
      _bpm = data.bpm;
      _leadOff = data.leadOff;
      _connected = true;
      if (!data.leadOff) {
        _points.add(FlSpot(_x++, data.ecgValue.toDouble()));
        if (_points.length > _maxPoints) _points.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _ble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _StatusBar(
                status: _status,
                connected: _connected,
                onConnect: () => _ble.connect(),
                onDisconnect: () {
                  _ble.disconnect();
                  setState(() {
                    _connected = false;
                    _points.clear();
                  });
                },
              ),
              const SizedBox(height: 20),
              _BpmCard(bpm: _bpm, leadOff: _leadOff),
              const SizedBox(height: 20),
              _EcgChart(points: List.from(_points), leadOff: _leadOff),
              const SizedBox(height: 20),
              _InterpretationCard(bpm: _bpm, age: _age, sex: _sex),
              const SizedBox(height: 20),
              _DemographicCard(
                age: _age,
                sex: _sex,
                onAgeChanged: (v) => setState(() => _age = v),
                onSexChanged: (v) => setState(() => _sex = v),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── StatusBar ───────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final String status;
  final bool connected;
  final VoidCallback onConnect, onDisconnect;
  const _StatusBar({
    required this.status,
    required this.connected,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: connected ? const Color(0xFF43E97B) : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        GestureDetector(
          onTap: connected ? onDisconnect : onConnect,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: connected
                    ? [const Color(0xFFFF5F6D), const Color(0xFFFFC371)]
                    : [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
              ),
            ),
            child: Text(
              connected ? 'Desconectar' : 'Conectar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── BpmCard ─────────────────────────────────────────────────

class _BpmCard extends StatelessWidget {
  final int bpm;
  final bool leadOff;
  const _BpmCard({required this.bpm, required this.leadOff});

  @override
  Widget build(BuildContext context) {
    final color = colorForBpm(bpm);
    final icon = iconForBpm(bpm);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            '❤️ Frecuencia Cardíaca',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          leadOff
              ? const Text(
                  'Electrodos desconectados',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      bpm == 0 ? '--' : '$bpm',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                        'BPM',
                        style: TextStyle(fontSize: 18, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

// ─── EcgChart ────────────────────────────────────────────────

class _EcgChart extends StatelessWidget {
  final List<FlSpot> points;
  final bool leadOff;
  const _EcgChart({required this.points, required this.leadOff});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF43E97B).withOpacity(0.3),
        ),
      ),
      child: leadOff || points.isEmpty
          ? Center(
              child: Text(
                leadOff ? '⚠️ Coloca los electrodos' : 'Esperando señal...',
                style: const TextStyle(color: Colors.white38),
              ),
            )
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: 4095, // ESP32: ADC 12 bits (0-4095)
                minX: points.first.x,
                maxX: points.last.x,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1024,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: const Color(0xFF43E97B).withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: false,
                    color: const Color(0xFF43E97B),
                    barWidth: 1.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF43E97B).withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── InterpretationCard ──────────────────────────────────────

class _InterpretationCard extends StatelessWidget {
  final int bpm;
  final int age;
  final String sex;
  const _InterpretationCard({
    required this.bpm,
    required this.age,
    required this.sex,
  });

  @override
  Widget build(BuildContext context) {
    final label = interpretBpm(bpm);
    final color = colorForBpm(bpm);
    final icon = iconForBpm(bpm);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Interpretación',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            recommendationFor(bpm, age, sex),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── DemographicCard ─────────────────────────────────────────

class _DemographicCard extends StatelessWidget {
  final int age;
  final String sex;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<String> onSexChanged;

  const _DemographicCard({
    required this.age,
    required this.sex,
    required this.onAgeChanged,
    required this.onSexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👤 Datos demográficos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Edad: ',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Expanded(
                child: Slider(
                  value: age.toDouble(),
                  min: 10,
                  max: 90,
                  divisions: 80,
                  activeColor: const Color(0xFFFF4E6A),
                  onChanged: (v) => onAgeChanged(v.round()),
                ),
              ),
              Text(
                '$age años',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Sexo: ',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 12),
              ...['Masculino', 'Femenino', 'Otro'].map(
                (s) => GestureDetector(
                  onTap: () => onSexChanged(s),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: sex == s
                          ? const Color(0xFFFF4E6A)
                          : const Color(0xFF1A1A2E),
                      border: Border.all(
                        color:
                            sex == s ? const Color(0xFFFF4E6A) : Colors.white24,
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12,
                        color: sex == s ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}