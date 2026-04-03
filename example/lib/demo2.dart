import 'package:flutter/material.dart';
import 'package:variable_width_scrollphysics/slider.dart';

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
        FlexPageSlider(
          pageWidths: [width - 100, width, width],
          pageHeights: [160, 250, 250],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Demo1.page(width: width - 100, color: Color(0xFF6366F1), itemCount: 8, crossAxisCount: 4), // 亮靛蓝
              Demo1.page(width: width, color: Color(0xFF3B82F6), itemCount: 15, crossAxisCount: 5), // 亮蓝色
              Demo1.page(width: width, color: Color(0xFF8B5CF6), itemCount: 15, crossAxisCount: 5), // 亮紫色
            ],
          ),
        ),
      ],
    );
  }
}
