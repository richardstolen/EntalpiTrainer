import 'package:flutter/material.dart';

import '../constants.dart';

class TextContainerWidget extends StatelessWidget {
  const TextContainerWidget({
    Key? key,
    required List<String> data,
    required this.text,
  })  : _receivedData = data,
        super(key: key);

  final List<String> _receivedData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: EntalpiColors.offBlack,
        ),
        height: 90,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Scrollbar(
                child: SingleChildScrollView(
              child: Text(
                text + _receivedData.join("\n"),
                textAlign: TextAlign.left,
              ),
            ))));
  }
}
