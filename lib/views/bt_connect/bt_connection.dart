import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:entalpitrainer/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../tacx_trainer_control.dart';
import '../../widgets/text_container_widget.dart';
import 'connection_widgets.dart';

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

  int targetPower = 0;
  int cadence = 0;
  int _numberOfMessagesReceived = 0;

  late TacxTrainerControl trainer;

  void refreshScreen() {
    setState(() {});
  }

  Future<void> showNoPermissionDialog() async => showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => AlertDialog(
          title: const Text('No location permission '),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('No location permission granted.'),
                Text('Location permission is required for BLE to function.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Acknowledge'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  void _startScan() async {
    bool goForIt = false;
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) goForIt = true;
    } else if (Platform.isIOS) {
      goForIt = true;
    }
    if (goForIt) {
      //TODO replace True with permission == PermissionStatus.granted is for IOS test
      _foundBleUARTDevices = [];
      _scanning = true;
      refreshScreen();
      _scanStream = flutterReactiveBle
          .scanForDevices(withServices: [uartUUID]).listen((device) {
        if (_foundBleUARTDevices.every((element) => element.id != device.id)) {
          _foundBleUARTDevices.add(device);
          refreshScreen();
        }
      }, onError: (Object error) {
        _logTexts = "${_logTexts}ERROR while scanning:$error \n";
        refreshScreen();
      });
    } else {
      await showNoPermissionDialog();
    }
  }

  void _disconnect() async {
    await _connection.cancel();
    _connected = false;
    refreshScreen();
  }

  void _stopScan() async {
    await _scanStream.cancel();
    _scanning = false;
    refreshScreen();
  }

  void onNewReceivedData(List<int> data) {
    _numberOfMessagesReceived += 1;
    var stringData = trainer.fecDataHandler(data);
    print(stringData.last[1]);
    if (stringData.last[0] != -1) {
      targetPower = stringData.last[0];
      cadence = stringData.last[1];
    }
    print('target power: $targetPower');
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

  int _currentValue = 200;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
                            width: 100,
                            height: 48,
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            alignment: Alignment.center,
                            child: const Icon(Icons.add_link),
                          ),
                        ),
                        leading: const Text(
                          "Devices found:",
                          style: TextStyle(color: EntalpiColors.white),
                        ),
                        subtitle: Text(_foundBleUARTDevices[index].id),
                        title:
                            Text("$index: ${_foundBleUARTDevices[index].name}"),
                      )))),
          TextContainerWidget(data: [_logTexts], text: "Status messages:"),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                style: buildButtonStyle(),
                onPressed: !_scanning && !_connected ? _startScan : () {},
                child: Icon(
                  Icons.play_arrow,
                  color: !_scanning && !_connected
                      ? EntalpiColors.offBlack
                      : EntalpiColors.offWhite54,
                ),
              ),
              ElevatedButton(
                  style: buildButtonStyle(),
                  onPressed: _scanning ? _stopScan : () {},
                  child: Icon(
                    Icons.stop,
                    color: _scanning
                        ? EntalpiColors.offBlack
                        : EntalpiColors.offWhite54,
                  )),
              ElevatedButton(
                  style: buildButtonStyle(),
                  onPressed: _connected ? _disconnect : () {},
                  child: Icon(
                    Icons.cancel,
                    color: _connected
                        ? EntalpiColors.offBlack
                        : EntalpiColors.offWhite54,
                  )),
            ],
          ),
          SizedBox(
            child: ConectionStatusWidget(
                scanning: _scanning, connected: _connected),
          ),
          NumberPicker(
            minValue: 0,
            maxValue: 1500,
            axis: Axis.horizontal,
            step: 2,
            value: _currentValue,
            selectedTextStyle:
                const TextStyle(color: EntalpiColors.green, fontSize: 18),
            onChanged: (value) => setState(() {
              _currentValue = value;
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() {
                  final newValue = _currentValue - 100;
                  _currentValue = newValue;
                }),
                child: const Text(
                  '-100',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: EntalpiColors.offBlack),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(EntalpiColors.green),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              //power set to: $_currentValue'
              TextButton(
                onPressed: () => setState(() {
                  trainer.setTargetPower(_currentValue);
                }),
                child: const Text(
                  "Set target power",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: EntalpiColors.offBlack),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(EntalpiColors.green),
                ),
              ),

              const SizedBox(
                width: 20,
              ),
              TextButton(
                onPressed: () => setState(() {
                  final newValue = _currentValue + 100;
                  _currentValue = newValue;
                }),
                child: const Text(
                  '+100',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: EntalpiColors.offBlack),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(EntalpiColors.green),
                ), //'Target,
              ),
              //'Target power set to: $_currentValue'
            ],
          ),
          Text(
            '\nCurrent power: \n           $targetPower',
            style: TextStyle(fontSize: 25),
          ),
          Text(
            '\nCurrent cadence: \n             $cadence',
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
    );
  }
}
