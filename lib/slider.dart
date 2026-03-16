import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:variable_width_scrollphysics/scroll_physics.dart';

class FlexPageSlider extends StatefulWidget {
  final List<double> pageWidths;
  final List<double> pageHeights;
  final Widget child;
  final ScrollController? scrollController;

  const FlexPageSlider({super.key, required this.pageWidths, required this.child, required this.pageHeights, this.scrollController});

  @override
  State<FlexPageSlider> createState() => _FlexPageSliderState();
}

class _FlexPageSliderState extends State<FlexPageSlider> {
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  late ScrollController _controller;

  late double minHeight;
  late double maxHeight;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  @override
  void didUpdateWidget(covariant FlexPageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) {
        _controller.dispose();
      }
      _initState();
    }
    super.didUpdateWidget(oldWidget);
  }

  _initState() {
    _valueNotifier.value = widget.pageHeights.first;
    if (widget.scrollController != null) {
      _controller = widget.scrollController!;
    } else {
      _controller = ScrollController();
    }
    _controller.addListener(scrollDidScroll);

    minHeight = widget.pageHeights.first;
    maxHeight = widget.pageHeights.first;
    for (var h in widget.pageHeights) {
      if (h < minHeight) {
        minHeight = h;
      }
      if (h > maxHeight) {
        maxHeight = h;
      }
    }
  }

  @override
  dispose() {
    super.dispose();
    _controller.removeListener(scrollDidScroll);
  }

  scrollDidScroll() {
    var position = _controller.position;
    int index = 0;
    double p = widget.pageWidths[index];
    while (p <= position.pixels) {
      index += 1;
      p += widget.pageWidths[index];
    }
    var width1 = widget.pageWidths[index];
    var height1 = widget.pageHeights[index];
    var height2 = widget.pageHeights[min(index + 1, widget.pageHeights.length - 1)];

    if (height1 == height2) return;

    var deltaH = height2 - height1;
    var percent = position.pixels / width1;
    var target = deltaH * percent + height1;
    target = clampDouble(target, minHeight, maxHeight);

    if (maxHeight - target < 1) {
      _valueNotifier.value = maxHeight;
    } else {
      _valueNotifier.value = target;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const CupertinoScrollBehavior(),
      child: SingleChildScrollView(
        controller: _controller,
        physics: FlexPageScrollPhysics(widget.pageWidths),
        // physics: PageScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: ValueListenableBuilder(
            valueListenable: _valueNotifier,
            builder: (context, double v, _) {
              return SizedBox(height: v, child: widget.child);
            }),
      ),
    );
  }
}
