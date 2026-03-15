import 'package:flutter/material.dart';
import 'package:variable_width_scrollphysics/scroll_physics.dart';

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
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(index.toString()),
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
        FlexSlider(
          pageWidths: [width - 100, width],
          pageHeights: [140, 230],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              page(width: width - 100, color: Colors.red, itemCount: 8, crossAxisCount: 4),
              page(width: width, color: Colors.green, itemCount: 15, crossAxisCount: 5),
            ],
          ),
        ),
      ],
    );
  }
}
