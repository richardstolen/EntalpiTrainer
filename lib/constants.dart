import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class EntalpiColors {
  static const Color deepPurple = Color(0xFF4A3383);
  static const Color green = Color(0xFFAAEB8F);
  static const Color lightGreen = Color(0xFFAAEFAF);
  static const Color error = Color(0xffb00020);
  static const Color offBlack = Color(0xFF181818);
  static const Color offWhite10 = Colors.white10;
  static const Color offWhite24 = Colors.white24;
  static const Color offWhite30 = Colors.white30;
  static const Color grey = Colors.white38;
  static const Color offWhite54 = Colors.white54;
  static const Color offWhite70 = Colors.white70;
  static const Color almostWhite = Color(0xEEFFFFFF);
  static const Color white = Colors.white;
}

final Uuid uartUUID = Uuid.parse('6e40fec1-b5a3-f393-e0a9-e50e24dcca9e');
final Uuid uartRX = Uuid.parse('6e40fec3-b5a3-f393-e0a9-e50e24dcca9e');
final Uuid uartTX = Uuid.parse('6e40fec2-b5a3-f393-e0a9-e50e24dcca9e');
