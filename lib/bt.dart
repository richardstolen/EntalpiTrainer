import 'dart:async';
import 'package:entalpitrainer/tacx_trainer_control.dart';
import 'package:entalpitrainer/views/bt_connect/bt_connect_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'constants.dart';

class BT {
  String text = "asdf";

  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> foundBleUARTDevices = [];
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late Stream<ConnectionStateUpdate> _currentConnectionStream;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late QualifiedCharacteristic txCharacteristic;
  late QualifiedCharacteristic _rxCharacteristic;

  StreamController<List<int>> controller =
      StreamController<List<int>>.broadcast();
  late Stream<List<int>> receivedDataStream;

  List<String> dataLog = [];
  bool scanning = false;
  bool connected = false;

  String logTexts = "";
  List<String> receivedData = [];
  int _numberOfMessagesReceived = 0;

  late TacxTrainerControl trainer;

  void startScan() {
    foundBleUARTDevices = [];
    scanning = true;
    _scanStream = flutterReactiveBle
        .scanForDevices(withServices: [uartUUID]).listen((device) {
      if (foundBleUARTDevices.every((element) => element.id != device.id)) {
        foundBleUARTDevices.add(device);
      }
    }, onError: (Object error) {
      logTexts = "${logTexts}ERROR while scanning:$error \n";
    });
  }

  void stopScan() async {
    await _scanStream.cancel();
    scanning = false;
  }

  void disconnect() async {
    await _connection.cancel();
    connected = false;
  }

  void onNewReceivedData(List<int> data) {
    _numberOfMessagesReceived += 1;
    var stringData = trainer.fecDataHandler(data);
    receivedData.add(stringData);

    if (receivedData.length > 5) {
      receivedData.removeAt(0);
    }
  }

  void onConnectDevice(index) {
    _currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id: foundBleUARTDevices[index].id,
      prescanDuration: const Duration(seconds: 1),
      withServices: [uartUUID, uartRX, uartTX],
    );
    logTexts = "";
    _connection = _currentConnectionStream.listen((event) {
      var id = event.deviceId.toString();
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            logTexts = "${logTexts}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            connected = true;
            logTexts = "${logTexts}Connected to $id\n";
            _numberOfMessagesReceived = 0;
            receivedData = [];
            txCharacteristic = QualifiedCharacteristic(
                serviceId: uartUUID,
                characteristicId: uartTX,
                deviceId: event.deviceId);
            receivedDataStream =
                flutterReactiveBle.subscribeToCharacteristic(txCharacteristic);
            controller.addStream(receivedDataStream);
            /*
            receivedDataStream.listen((data) {
              onNewReceivedData(data);
            }, onError: (dynamic error) {
              logTexts = "${logTexts}Error:$error$id\n";
            });
            */
            _rxCharacteristic = QualifiedCharacteristic(
                serviceId: uartUUID,
                characteristicId: uartRX,
                deviceId: event.deviceId);
            trainer = TacxTrainerControl(flutterReactiveBle);
            trainer.rxCharacteristic = _rxCharacteristic;
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            connected = false;
            logTexts = "${logTexts}Disconnecting from $id\n";
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            logTexts = "${logTexts}Disconnected from $id\n";
            break;
          }
      }
    });
  }
}
