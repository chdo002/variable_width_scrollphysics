import 'package:flutter/material.dart';
import 'package:variable_width_scrollphysics/slider.dart';

class Demo4 extends StatelessWidget {
  const Demo4({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Demo4'),
        SizedBox(
          height: 300,
          child: FlexSliverSlider(
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: width,
                  color: [Color(0xFFEC4899), Color(0xFFF59E0B), Color(0xFF10B981)][index], // 粉红、琥珀、翡翠渐变
                );
              }),
        )
      ],
    );
  }
}
