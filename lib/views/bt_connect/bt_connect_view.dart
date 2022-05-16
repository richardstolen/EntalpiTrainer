import 'package:entalpitrainer/widgets/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';
import 'package:entalpitrainer/bt.dart';
import 'package:entalpitrainer/constants.dart';

import '../../constants.dart';
import '../../widgets/text_container_widget.dart';
import 'connection_widgets.dart';

// ignore: must_be_immutable
class BTConnectView extends StatefulWidget {
  BT bt;
  BTConnectView({Key? key, required this.bt}) : super(key: key);

  @override
  State<BTConnectView> createState() => BTConnectViewState();
}

class BTConnectViewState extends State<BTConnectView> {
  void refreshScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bt == null) {
      widget.bt = BT();
    }

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  height: 200,
                  child: ListView.builder(
                      itemCount: widget.bt.foundBleUARTDevices.length,
                      itemBuilder: (context, index) => Card(
                              child: ListTile(
                            dense: true,
                            enabled: !((!widget.bt.connected &&
                                    widget.bt.scanning) ||
                                (!widget.bt.scanning && widget.bt.connected)),
                            trailing: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if ((!widget.bt.connected &&
                                        widget.bt.scanning) ||
                                    (!widget.bt.scanning &&
                                        widget.bt.connected)) {
                                  () {};
                                } else {
                                  widget.bt.onConnectDevice(index);
                                  refreshScreen();
                                }
                              },
                              child: Container(
                                width: 100,
                                height: 48,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                alignment: Alignment.center,
                                child: const Icon(Icons.add_link),
                              ),
                            ),
                            leading: const Text(
                              "Devices found:",
                              style: TextStyle(color: EntalpiColors.white),
                            ),
                            subtitle:
                                Text(widget.bt.foundBleUARTDevices[index].id),
                            title: Text(
                                "$index: ${widget.bt.foundBleUARTDevices[index].name}"),
                          )))),
              TextContainerWidget(
                  data: [widget.bt.logTexts], text: "Status messages:"),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
                    style: buildButtonStyle(),
                    onPressed: () {
                      if (!widget.bt.scanning && !widget.bt.connected) {
                        widget.bt.startScan();
                        refreshScreen();
                      } else {
                        () {};
                      }
                    },
                    child: Icon(
                      Icons.play_arrow,
                      color: !widget.bt.scanning && !widget.bt.connected
                          ? EntalpiColors.offBlack
                          : EntalpiColors.offWhite54,
                    ),
                  ),
                  ElevatedButton(
                      style: buildButtonStyle(),
                      onPressed: () {
                        if (widget.bt.scanning) {
                          widget.bt.stopScan();
                          refreshScreen();
                        } else {
                          () {};
                        }
                      },
                      child: Icon(
                        Icons.stop,
                        color: widget.bt.scanning
                            ? EntalpiColors.offBlack
                            : EntalpiColors.offWhite54,
                      )),
                  ElevatedButton(
                      style: buildButtonStyle(),
                      onPressed: () {
                        if (widget.bt.connected) {
                          widget.bt.disconnect();
                          refreshScreen();
                        } else {
                          () {};
                        }
                      },
                      child: Icon(
                        Icons.cancel,
                        color: widget.bt.connected
                            ? EntalpiColors.offBlack
                            : EntalpiColors.offWhite54,
                      )),
                ],
              ),
              SizedBox(
                height: 35,
                child: ConectionStatusWidget(
                    scanning: widget.bt.scanning,
                    connected: widget.bt.connected),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        bt: widget.bt,
      ),
    );
  }
}
