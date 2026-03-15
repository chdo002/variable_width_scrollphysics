import 'package:flutter/material.dart';
import 'package:variable_width_scrollphysics/scroll_physics.dart';

import 'demo1.dart';

class Demo2 extends StatelessWidget {
  const Demo2({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Demo2'),
        FlexSlider(
          pageWidths: [width - 100, width, width],
          pageHeights: [140, 230, 230],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Demo1.page(width: width - 100, color: Colors.red, itemCount: 8, crossAxisCount: 4),
              Demo1.page(width: width, color: Colors.green, itemCount: 15, crossAxisCount: 5),
              Demo1.page(width: width, color: Colors.cyan, itemCount: 15, crossAxisCount: 5),
            ],
          ),
        ),
      ],
    );
  }
}
