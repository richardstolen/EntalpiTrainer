import 'package:entalpitrainer/views/bt_connect/bt_connection.dart';
import 'package:entalpitrainer/widgets/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class BTConnectView extends StatefulWidget {
  const BTConnectView({Key? key}) : super(key: key);

  @override
  State<BTConnectView> createState() => _BTConnectViewState();
}

class _BTConnectViewState extends State<BTConnectView> {
  @override
  Widget build(BuildContext context) {
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
            children: const [
              BTConnection(title: 'Richard the Great'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
