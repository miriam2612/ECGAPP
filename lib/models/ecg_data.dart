import 'package:flutter/material.dart';

class EcgData {
  final int ecgValue;
  final int bpm;
  final bool leadOff;
  final DateTime timestamp;

  EcgData({
    required this.ecgValue,
    required this.bpm,
    required this.leadOff,
    required this.timestamp,
  });
}

String interpretBpm(int bpm) {
  if (bpm == 0) return 'Sin señal';
  if (bpm < 60) return 'Bradicardia';
  if (bpm <= 100) return 'Ritmo normal';
  if (bpm <= 150) return 'Taquicardia leve';
  return 'Taquicardia severa';
}

String recommendationFor(int bpm, int age, String sex) {
  if (bpm == 0) return 'Conecta el sensor para obtener una lectura.';

  final int minNormal = age > 60 ? 55 : 60;
  final int maxNormal = age > 60 ? 90 : 100;

  if (bpm < minNormal) {
    return 'Tu ritmo cardíaco es más lento de lo esperado. Si te sientes mareado o con fatiga, consulta a un médico.';
  }

  if (bpm <= maxNormal) {
    return 'Tu corazón late dentro de un rango esperado. Mantén buenos hábitos e hidratación.';
  }

  if (bpm <= 150) {
    return 'Ritmo elevado. Descansa unos minutos, hidrátate y evita esfuerzo físico.';
  }

  return 'Ritmo muy elevado. Si no baja pronto o tienes síntomas, busca atención médica.';
}

Color colorForBpm(int bpm) {
  if (bpm == 0) return Colors.grey;
  if (bpm < 60) return const Color(0xFF4FACFE);
  if (bpm <= 100) return const Color(0xFF00E5A0);
  if (bpm <= 150) return const Color(0xFFFFC107);
  return const Color(0xFFFF4E6A);
}

IconData iconForBpm(int bpm) {
  if (bpm == 0) return Icons.bluetooth_searching_rounded;
  if (bpm < 60) return Icons.arrow_downward_rounded;
  if (bpm <= 100) return Icons.favorite_rounded;
  if (bpm <= 150) return Icons.warning_amber_rounded;
  return Icons.emergency_rounded;
}