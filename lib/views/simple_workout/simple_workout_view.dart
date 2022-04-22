import 'package:entalpitrainer/constants.dart';
import 'package:entalpitrainer/widgets/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../tacx_trainer_control.dart';

class SimpleWorkoutView extends StatefulWidget {
  const SimpleWorkoutView({Key? key}) : super(key: key);

  @override
  State<SimpleWorkoutView> createState() => _SimpleWorkoutViewState();
}

class _SimpleWorkoutViewState extends State<SimpleWorkoutView> {
  int _currentValue = 200;
  late TacxTrainerControl trainer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
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
          ],
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}

//
// const Text("Set target power:"),
// Container(
// margin: const EdgeInsets.all(3.0),
// padding: const EdgeInsets.all(8.0),
// width: 400,
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(10),
// border: Border.all(color: Colors.blue, width: 2)),
// child: Row(children: <Widget>[
// Expanded(
// child: TextField(
// enabled: _connected,
// controller: _dataToSendText,
// decoration: const InputDecoration(
// border: InputBorder.none, hintText: 'Enter a number'),
// )),
// ElevatedButton(
// child: Icon(
// Icons.send,
// color: _connected ? Colors.white : Colors.blue,
// ),
// onPressed: _connected
// ? () {
// trainer.setTargetPower(
// int.parse(_dataToSendText.text));
// }
//     : () {}),
// ])),
