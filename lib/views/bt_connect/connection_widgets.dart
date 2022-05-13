import 'package:flutter/material.dart';

import '../../constants.dart';

class ConectionStatusWidget extends StatelessWidget {
  const ConectionStatusWidget({
    Key? key,
    required bool scanning,
    required bool connected,
  })  : _scanning = scanning,
        _connected = connected,
        super(key: key);

  final bool _scanning;
  final bool _connected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }
}

ButtonStyle buildButtonStyle() {
  return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(EntalpiColors.green));
}
