import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class SimpleWorkoutView extends StatefulWidget {
  const SimpleWorkoutView({Key? key}) : super(key: key);

  @override
  State<SimpleWorkoutView> createState() => _SimpleWorkoutViewState();
}

class _SimpleWorkoutViewState extends State<SimpleWorkoutView> {
  @override
  Widget build(BuildContext context) {
    int _currentValue = 200;
    return Scaffold(
      body: Column(
        children: [
          NumberPicker(
            minValue: 0,
            maxValue: 1500,
            axis: Axis.horizontal,
            step: 10,
            value: _currentValue,
            onChanged: (value) => setState(() {
              _currentValue = value;
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  final newValue = _currentValue - 100;
                  _currentValue = newValue;
                }),
                icon: const Icon(Icons.remove),
              ),
              Text('Target power set to: $_currentValue'),
              IconButton(
                onPressed: () => setState(() {
                  final newValue = _currentValue + 100;
                  _currentValue = newValue;
                }),
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ],
      ),
    );
  }
}
