import 'package:flutter/material.dart';
import 'package:variable_width_scrollphysics/variable_width_scrollphysics.dart';
import 'package:variable_width_scrollphysics/slider.dart';

class Demo1 extends StatelessWidget {
  const Demo1({super.key});

  static Widget page({required double width, required Color color, required int itemCount, required int crossAxisCount}) {
    return Container(
      color: color,
      width: width,
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(10),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: 10, crossAxisSpacing: 10),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              color: Colors.white24,
              alignment: Alignment.center,
              child: Text(index.toString(), style: TextStyle(color: Color(0xFF1E293B))), // 深石板灰文字
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Demo1'),
        FlexPageSlider(
          pageWidths: [width - 100, width],
          pageHeights: [160, 250],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              page(width: width - 100, color: Color(0xFF6366F1), itemCount: 8, crossAxisCount: 4), // 亮靛蓝
              page(width: width, color: Color(0xFF3B82F6), itemCount: 15, crossAxisCount: 5), // 亮蓝色
            ],
          ),
        ),
      ],
    );
  }
}
