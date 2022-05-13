import 'dart:async';

import 'package:entalpitrainer/constants.dart';
import 'package:entalpitrainer/widgets/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../bt.dart';
import '../../widgets/text_container_widget.dart';

class SimpleWorkoutView extends StatefulWidget {
  BT bt;
  SimpleWorkoutView({Key? key, required this.bt}) : super(key: key);

  @override
  State<SimpleWorkoutView> createState() => _SimpleWorkoutViewState();
}

class _SimpleWorkoutViewState extends State<SimpleWorkoutView> {
  int _currentValue = 200;

  @override
  Widget build(BuildContext context) {
    /*
    CHANGE !widget.bt.connected TO widget.bt.connected
    in IF statement
    */
    if (widget.bt.connected) {
      widget.bt.controller.stream.listen((data) {
        widget.bt.onNewReceivedData(data);
        setState(() {});
      });
      return Scaffold(
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [EntalpiColors.green, EntalpiColors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                NumberPicker(
                  itemHeight: 100,
                  minValue: 0,
                  maxValue: 1500,
                  axis: Axis.horizontal,
                  step: 2,
                  value: _currentValue,
                  selectedTextStyle: const TextStyle(
                      color: EntalpiColors.offBlack, fontSize: 30),
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
                      height: 20,
                    ),
                    //power set to: $_currentValue'
                    TextButton(
                      onPressed: () => setState(() {
                        widget.bt.trainer.setTargetPower(_currentValue);
                      }),
                      child: const Text(
                        "Set target power",
                        style: TextStyle(
                            fontSize: 18,
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
                      height: 20,
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
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(20)),
                Column(
                  children: [
                    const Text("Intervall duraton:"),
                    Text('${widget.bt.trainer.intervalTime.elapsed.inSeconds}',
                        style: const TextStyle(fontSize: 50)),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(50)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text("Target power:"),
                          Text('${widget.bt.trainer.currentTargetPower}',
                              style: const TextStyle(fontSize: 50)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Cadence:"),
                          Text('${widget.bt.trainer.currentCadence}',
                              style: const TextStyle(fontSize: 50)),
                        ],
                      )
                    ]),
                const Padding(padding: EdgeInsets.all(40)),
                Column(
                  children: [
                    const Text("Elapsed time:"),
                    Text('${widget.bt.trainer.elapsedTime.elapsed.inSeconds}',
                        style: const TextStyle(fontSize: 50)),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          bt: widget.bt,
        ),
      );
    } else {
      return Scaffold(
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [EntalpiColors.green, EntalpiColors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(children: [
              const Padding(padding: EdgeInsets.all(40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You are not connected to a bike",
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              )
            ]),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          bt: widget.bt,
        ),
      );
    }
  }
}
