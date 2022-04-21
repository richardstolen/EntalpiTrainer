import 'dart:async';
import 'dart:io';

import 'package:entalpitrainer/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';

class ConnectionButtons extends StatefulWidget {
  const ConnectionButtons({Key? key}) : super(key: key);

  @override
  State<ConnectionButtons> createState() => _ConnectionButtonsState();
}

class _ConnectionButtonsState extends State<ConnectionButtons> {
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> _foundBleUARTDevices = [];
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  List<String> dataLog = [];
  bool _scanning = false;
  bool _connected = false;
  String _logTexts = "";

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

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      children: [
        Container(
          height: 35,
          child: Column(
            children: [
              if (_scanning)
                const Text("Scanning: Scanning")
              else
                const Text("Scanning: Idle"),
              if (_connected)
                const Text("Connected")
              else
                const Text("disconnected."),
            ],
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(EntalpiColors.green)),
          onPressed: !_scanning && !_connected ? _startScan : () {},
          child: Icon(
            Icons.play_arrow,
            color: !_scanning && !_connected
                ? EntalpiColors.offBlack
                : EntalpiColors.offWhite54,
          ),
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(EntalpiColors.green)),
            onPressed: _scanning ? _stopScan : () {},
            child: Icon(
              Icons.stop,
              color:
                  _scanning ? EntalpiColors.offBlack : EntalpiColors.offWhite54,
            )),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(EntalpiColors.green)),
            onPressed: _connected ? _disconnect : () {},
            child: Icon(
              Icons.cancel,
              color: _connected
                  ? EntalpiColors.offBlack
                  : EntalpiColors.offWhite54,
            ))
      ],
    );
  }
}
