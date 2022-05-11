import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:collection/collection.dart';
import 'dart:typed_data';

final String tacxSmartMac = "C7:5C:17:EE:BD:02";
final String tacx2TMac = "DB:55:FA:90:69:9A";

class TacxTrainerControl {
  late FlutterReactiveBle _client;
  late QualifiedCharacteristic _rxCharacteristic;

  set rxCharacteristic(value) => _rxCharacteristic = value;

  get getRxCharacteristic => _rxCharacteristic;

  // Service id
  final Uuid tacxServiceID = Uuid.parse('6e40fec1-b5a3-f393-e0a9-e50e24dcca9e');

  // The GATT Characteristic used for receiving FE-C messages from Tacx trainer
  final Uuid tacxTxID = Uuid.parse('6e40fec2-b5a3-f393-e0a9-e50e24dcca9e');

  /// The GATT Characteristic used for sending FE-C messages to Tacx trainer
  final Uuid tacxRxID = Uuid.parse('6e40fec3-b5a3-f393-e0a9-e50e24dcca9e');

  get getTacxServiceID => tacxServiceID;

  get getTacxTxID => tacxTxID;

  get getTacxRxID => tacxRxID;

  TacxTrainerControl(client) {
    _client = client;
  }

  void setBasicResistance(resistance) async {
    if (resistance < 0 || resistance > 200) {
      throw Exception("Resistance must be between 0 and 200");
    }

    List<int> writeValue = [
      0xA4,
      0x09,
      0x4F,
      0x05,
      0x30,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF
    ];

    writeValue.add(((resistance / 200) * 200).toInt());

    sendFecCmd(writeValue);
  }

  void setTargetPower(targetPower) async {
    if (targetPower < 0 || targetPower > 1500) {
      throw Exception("Target power must be between 0 and 1500");
    }

    List<int> writeValue = [
      0xA4,
      0x09,
      0x4F,
      0x05,
      0x31,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF
    ];

    Uint8List int32bytes(int value) =>
        Uint8List(4)..buffer.asInt32List()[0] = value;

    var byteData =
        ByteData.sublistView(int32bytes((targetPower ~/ 0.25).toInt()));

    writeValue.add(byteData.getInt8(0));
    writeValue.add(byteData.getInt8(1));
    sendFecCmd(writeValue);
  }

  List<List<int>> fecDataHandler(data) {
    List<List<int>> returnData = [
      [-1, -1]
    ];
    int returnInt = -1;

    var messageLength = data[1];
    var messageType = data[2];
    var messageChannel = data[3];
    var messageData = data.sublist(4, 4 + messageLength - 1);
    var dataPageNumber = messageData[0];

    if (dataPageNumber == 16) {
      return returnData;
    } else if (dataPageNumber == 25) {
      returnData.add(specificTrainerDataHandler(messageData));
    } else if (dataPageNumber == 71) {
      return returnData;
    }
    return returnData;
  }

  String generalDataHandler(messageData) {
    return "not implemented";
  }

  List<int> specificTrainerDataHandler(messageData) {
    var eventCount = messageData[1];

    var instantaneousCadence = messageData[2];
    if (instantaneousCadence == 255) {
      instantaneousCadence = null;
    }

    var powerLsb = messageData[5];
    var powerMsb = messageData[6];

    var instantaneousPower = powerLsb + ((powerMsb & 0xf) << 8);

    return [instantaneousPower, instantaneousCadence];
  }

  String commandStatusDataHandler(messageData) {
    return "not implemented";
  }

  void sendFecCmd(fecBytes) async {
    /// Checksum sums [fec_bytes] without the first element
    /// and does a bitwise AND operation with 0xFF(255)

    var checksum =
        fecBytes.sublist(1, fecBytes.length).fold(0, (p, c) => p + c) & 0xFF;

    fecBytes.add(checksum);
    Uint8List bytes = Uint8List.fromList(fecBytes);
    await _client.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: bytes);
  }
}
