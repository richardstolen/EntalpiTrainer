import 'package:flutter/material.dart';

import '../constants.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20.0,
          left: 12,
          right: 12,
          bottom: 20.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  onPressed: () => Navigator.of(context).pushNamed('/'),
                  icon: Column(
                    children: const [
                      Icon(
                        Icons.bluetooth,
                        size: 24,
                        color: EntalpiColors.offWhite54,
                      ),
                      Text(
                        'connect',
                        style: TextStyle(
                            color: EntalpiColors.offWhite54, fontSize: 12),
                      ),
                    ],
                  )),
            ),
            Expanded(
              child: IconButton(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  onPressed: () => Navigator.of(context).pushNamed('/workout'),
                  icon: Column(
                    children: const [
                      Icon(
                        Icons.directions_bike,
                        semanticLabel: 'workout',
                        size: 24,
                        color: EntalpiColors.offWhite54,
                      ),
                      Text(
                        'workout',
                        style: TextStyle(
                            color: EntalpiColors.offWhite70, fontSize: 12),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
