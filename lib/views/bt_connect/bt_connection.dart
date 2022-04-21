import 'dart:async';

import 'package:entalpitrainer/constants.dart';
import 'package:entalpitrainer/views/bt_connect/connection_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../tacx_trainer_control.dart';
import '../../widgets/text_container_widget.dart';

class BTConnection extends StatefulWidget {
  const BTConnection({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _BTConnectionState createState() => _BTConnectionState();
}

class _BTConnectionState extends State<BTConnection> {
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> _foundBleUARTDevices = [];
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late Stream<ConnectionStateUpdate> _currentConnectionStream;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late QualifiedCharacteristic _txCharacteristic;
  late QualifiedCharacteristic _rxCharacteristic;
  late Stream<List<int>> _receivedDataStream;
  List<String> dataLog = [];
  bool _scanning = false;
  bool _connected = false;
  String _logTexts = "";
  List<String> _receivedData = [];
  int _numberOfMessagesReceived = 0;

  late TacxTrainerControl trainer;

  void refreshScreen() {
    setState(() {});
  }

  void onNewReceivedData(List<int> data) {
    _numberOfMessagesReceived += 1;
    var stringData = trainer.fecDataHandler(data);
    _receivedData.add("$_numberOfMessagesReceived: , $stringData");

    if (_receivedData.length > 5) {
      _receivedData.removeAt(0);
    }
    refreshScreen();
  }

  void onConnectDevice(index) {
    _currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id: _foundBleUARTDevices[index].id,
      prescanDuration: const Duration(seconds: 1),
      withServices: [uartUUID, uartRX, uartTX],
    );
    _logTexts = "";
    refreshScreen();
    _connection = _currentConnectionStream.listen((event) {
      var id = event.deviceId.toString();
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            _logTexts = "${_logTexts}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            _connected = true;
            _logTexts = "${_logTexts}Connected to $id\n";
            _numberOfMessagesReceived = 0;
            _receivedData = [];
            _txCharacteristic = QualifiedCharacteristic(
                serviceId: uartUUID,
                characteristicId: uartTX,
                deviceId: event.deviceId);
            _receivedDataStream =
                flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);
            _receivedDataStream.listen((data) {
              onNewReceivedData(data);
            }, onError: (dynamic error) {
              _logTexts = "${_logTexts}Error:$error$id\n";
            });
            _rxCharacteristic = QualifiedCharacteristic(
                serviceId: uartUUID,
                characteristicId: uartRX,
                deviceId: event.deviceId);
            trainer = TacxTrainerControl(flutterReactiveBle);
            trainer.rxCharacteristic = _rxCharacteristic;
            print(trainer.getRxCharacteristic);
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            _connected = false;
            _logTexts = "${_logTexts}Disconnecting from $id\n";
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            _logTexts = "${_logTexts}Disconnected from $id\n";
            break;
          }
      }
      refreshScreen();
    });
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("Devices found:"),
            Container(
                margin: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: EntalpiColors.offBlack,
                  borderRadius: BorderRadius.circular(4),
                ),
                height: 100,
                child: ListView.builder(
                    itemCount: _foundBleUARTDevices.length,
                    itemBuilder: (context, index) => Card(
                            child: ListTile(
                          dense: true,
                          enabled: !((!_connected && _scanning) ||
                              (!_scanning && _connected)),
                          trailing: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              (!_connected && _scanning) ||
                                      (!_scanning && _connected)
                                  ? () {}
                                  : onConnectDevice(index);
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              alignment: Alignment.center,
                              child: const Icon(Icons.add_link),
                            ),
                          ),
                          subtitle: Text(_foundBleUARTDevices[index].id),
                          title: Text(
                              "$index: ${_foundBleUARTDevices[index].name}"),
                        )))),
            TextContainerWidget(data: [_logTexts], text: "Status messages:"),
            TextContainerWidget(text: "Received data:", data: _receivedData),
            const ConnectionButtons()
          ],
        ),
      );
}
