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