import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class FlexPageScrollPhysics extends ScrollPhysics {
  const FlexPageScrollPhysics(this.pageWidths, {super.parent});

  final List<double> pageWidths;

  @override
  FlexPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FlexPageScrollPhysics(pageWidths, parent: buildParent(ancestor));
  }

  double _getPage(ScrollMetrics position) {
    var pixels = position.pixels;
    for (var i = 0; i < pageWidths.length; i++) {
      if (pixels < pageWidths[i]) {
        return i + pixels / pageWidths[i];
      }
      pixels -= pageWidths[i];
    }
    return 0;
  }

  double _getPixels(ScrollMetrics position, double page) {
    var pixels = 0.0;
    for (var i = 0; i < pageWidths.length && i < page; i++) {
      pixels += pageWidths[i];
    }
    return pixels;
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

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
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
    _initState();
  }

  @override
  void didUpdateWidget(covariant FlexSlider oldWidget) {
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
