import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:variable_width_scrollphysics/simple_console.dart';

class FlexScrollPhysics extends ScrollPhysics {
  const FlexScrollPhysics(this.pageWidths, {super.parent});

  final List<double> pageWidths;

  @override
  FlexScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FlexScrollPhysics(pageWidths, parent: buildParent(ancestor));
  }

  double _getPage(ScrollMetrics position) {
    int index = 0;
    double p = pageWidths[index];
    var offsetX = position.pixels;
    var d = offsetX - p;
    while (d > -0.0000000000001 && index < pageWidths.length - 1) {
      p += pageWidths[index];
      index += 1;
    }
    return index.toDouble();
  }

  double _getPixels(ScrollMetrics position, double page) {
    double p = 0;
    int index = 0;
    while (index < page) {
      p += pageWidths[index];
      index += 1;
    }
    return p;
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  show(String str) {
    SimpleConsole().log(str);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    var res = (velocity == 0 && (position.pixels < position.maxScrollExtent) && position.pixels > 0);
    if (res) {
      var leftForScreen1 = position.maxScrollExtent - position.pixels;
      var screen2OffsetX = position.viewportDimension - leftForScreen1;
      var per = screen2OffsetX / position.viewportDimension;
      final Tolerance tolerance = toleranceFor(position);
      show('''
        res: $res
        per: $per
        position.pixels : ${position.pixels}
        position.maxScrollExtent: ${position.maxScrollExtent}
        1
    ''');
      if (per > 0.4) {
        return ScrollSpringSimulation(spring, position.pixels, position.maxScrollExtent, velocity, tolerance: tolerance);
      } else {
        return ScrollSpringSimulation(spring, position.pixels, 0, velocity, tolerance: tolerance);
      }
    }

    // 超出滚动范围的bounce 默认动画
    if ((velocity < 0.0 && position.pixels <= position.minScrollExtent) || (velocity > 0.0 && position.pixels >= position.maxScrollExtent)) {
      final Tolerance tolerance = toleranceFor(position);
      final double target = _getTargetPixels(position, tolerance, velocity);

      show('''
          res: $res
          velocity : $velocity
          target: $target
          position.pixels : ${position.pixels}
          position.maxScrollExtent: ${position.maxScrollExtent}
      2
      ''');
      if (position.pixels < 0) {
        return super.createBallisticSimulation(position, velocity);
      }
      return ScrollSpringSimulation(spring, max(0, position.pixels), max(0, target - position.viewportDimension), velocity, tolerance: tolerance);
    }

    // 在滚动范围内时，滚动手势
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    var delta = target - position.pixels;
    if (delta.abs() > 0.1) {
      show('''
          target:$target
          delta: $delta
          velocity: $velocity
          tolerance.velocity: ${tolerance.velocity}
          3
      ''');
      return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
    }
    show('''
        target:$target
        delta: $delta
        velocity: $velocity
        tolerance.velocity: ${tolerance.velocity}
        4
    ''');
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class FlexSlider extends StatefulWidget {
  final List<double> pageWidths;
  final List<double> pageHeights;
  final Widget child;
  final ScrollController? scrollController;

  const FlexSlider({super.key, required this.pageWidths, required this.child, required this.pageHeights, this.scrollController});

  @override
  State<FlexSlider> createState() => _FlexSliderState();
}

class _FlexSliderState extends State<FlexSlider> {
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  late ScrollController _controller;

  late double minHeight;
  late double maxHeight;

  @override
  void initState() {
    super.initState();
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

    // 这是通用代码，但是有问题
    // var offset = position.pixels;
    // var offsetNum = index;
    // while (offsetNum > 0) {
    //   offset -= widget.pageWidths[offsetNum];
    //   offsetNum -= 1;
    // }
    // var percent = offset / width1;
    // // print('percent:$percent,offset:$offset, width1: $width1 ');
    // var delta = (height2 - height1) * percent;
    // _valueNotifier.value = max(delta + height1, minHeight).ceilToDouble();

    var deltaH = height2 - height1;
    var percent = position.pixels / width1;
    var target = deltaH * percent + height1;
    target = clampDouble(target, minHeight, maxHeight);

    if (maxHeight - target < 1) {
      _valueNotifier.value = maxHeight;
    } else {
      _valueNotifier.value = target;
    }
    // var str = '''
    // minHeight: $minHeight, maxHeight: $maxHeight
    //  target :$target
    //  percent: $percent
    // ''';
    // DebugInfo.update(str);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const CupertinoScrollBehavior(),
      child: SingleChildScrollView(
        controller: _controller,
        physics: FlexScrollPhysics(widget.pageWidths),
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
