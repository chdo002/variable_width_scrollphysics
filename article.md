# 从需求到实现：Flutter可变宽度滑动器的探索之路

> 本文将分享我在Flutter项目中实现类似闲鱼、美团首页那种变宽变高滑动效果的完整历程，从踩坑到最终解决方案的全过程。

## 需求背景

作为一个Flutter开发者，最近有个"看似简单"的需求：

**"我们要做一个像闲鱼、美团首页那样的滑动效果，每个页面宽度不一样，滑动的时候高度还要跟着变，最好能像PageView那样有吸附效果。"**

听完我第一反应：这不就是PageView加个高度动画吗？应该不难吧？

然而，真正动手后才发现，这个需求远没有想象中那么简单...

## 第一次尝试：PageView的滑铁卢

### PageView的基本使用

我首先想到的就是Flutter自带的PageView，毕竟它天生支持页面切换和吸附效果：

```dart
PageView.builder(
  itemCount: pages.length,
  itemBuilder: (context, index) {
    return Container(
      width: pageWidths[index], // 每个页面不同宽度
      height: pageHeights[index], // 每个页面不同高度
      child: pages[index],
    );
  },
)
```

### 遇到的问题

运行后发现几个问题：

1. **PageView强制全屏宽度**：PageView的设计初衷就是全屏滑动，每个page都会被强制撑满父容器宽度
2. **高度无法动态调整**：PageView的高度是固定的，无法根据当前页面内容高度变化
3. **滑动体验不一致**：PageView的滑动计算基于等宽页面，无法处理变宽场景

### 尝试改造PageView

我开始尝试各种PageView的改造方案：

```dart
// 尝试设置不同的viewportFraction
PageView.builder(
  controller: PageController(viewportFraction: 0.8),
  // ...
)
```

```dart
// 尝试自定义PageScrollPhysics
class CustomPageScrollPhysics extends PageScrollPhysics {
  // 重写各种方法...
}
```

结果都不理想，PageView的架构就是基于等宽页面设计的，改造起来非常痛苦。

## 第二次尝试：SingleChildScrollView + 自定义Physics

### 换个思路

既然PageView不行，那我能不能用SingleChildScrollView + Row来实现呢？这样我就可以完全控制每个页面的宽度和布局了。

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: List.generate(pages.length, (index) {
      return Container(
        width: pageWidths[index],
        height: currentHeight, // 需要动态计算
        child: pages[index],
      );
    }),
  ),
)
```

### 实现吸附效果

现在的问题是如何实现类似PageView的吸附效果。这就需要自定义ScrollPhysics了。

### ScrollPhysics的工作原理

在深入实现前，我先研究了ScrollPhysics的工作原理：

1. **createBallisticSimulation**：创建滚动动画模拟
2. **createBallisticSimulation**：计算滚动停止时的目标位置
3. **shouldAcceptUserOffset**：决定是否接受用户滚动

### 实现VariableWidthScrollPhysics

```dart
class FlexPageScrollPhysics extends ScrollPhysics {
  const FlexPageScrollPhysics(this.pageWidths, {super.parent});

  final List<double> pageWidths;

  @override
  FlexPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FlexPageScrollPhysics(pageWidths, parent: buildParent(ancestor));
  }

  // 关键：计算当前滚动位置对应的页面
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

  // 关键：计算页面对应的滚动位置
  double _getPixels(ScrollMetrics position, double page) {
    var pixels = 0.0;
    for (var i = 0; i < pageWidths.length && i < page; i++) {
      pixels += pageWidths[i];
    }
    return pixels;
  }

  // 关键：计算滚动停止时的目标位置
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
}
```

### 关键点解析

1. **页面计算**：`_getPage`方法根据当前滚动位置计算所在的页面索引
2. **位置计算**：`_getPixels`方法根据页面索引计算对应的滚动位置
3. **目标位置**：`_getTargetPixels`方法根据滚动速度决定吸附到哪个页面
4. **动画模拟**：使用ScrollSpringSimulation创建平滑的滚动动画

## 第三次尝试：动态高度调整

### 高度变化的挑战

解决了吸附问题后，现在需要处理高度动态变化。需求是：
- 滚动过程中，容器高度要根据当前页面和滚动进度平滑变化
- 不能出现跳跃，要流畅过渡

### 实现方案

我使用了ValueNotifier来监听滚动位置，然后计算当前应该显示的高度：

```dart
class FlexPageSlider extends StatefulWidget {
  final List<double> pageWidths;
  final List<double> pageHeights;
  final Widget child;

  const FlexPageSlider({
    super.key,
    required this.pageWidths,
    required this.pageHeights,
    required this.child,
  });

  @override
  State<FlexPageSlider> createState() => _FlexPageSliderState();
}

class _FlexPageSliderState extends State<FlexPageSlider> {
  final ValueNotifier<double> _heightNotifier = ValueNotifier(0);
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_updateHeight);
    _heightNotifier.value = widget.pageHeights.first;
  }

  void _updateHeight() {
    var position = _controller.position;
    int index = 0;
    double p = widget.pageWidths[index];

    // 找到当前所在的页面
    while (p <= position.pixels && index < widget.pageWidths.length - 1) {
      index += 1;
      p += widget.pageWidths[index];
    }

    // 计算滚动进度
    var width1 = widget.pageWidths[index];
    var height1 = widget.pageHeights[index];
    var height2 = widget.pageHeights[min(index + 1, widget.pageHeights.length - 1)];

    if (height1 == height2) return;

    var deltaH = height2 - height1;
    var percent = (position.pixels - (p - width1)) / width1;
    var target = deltaH * percent + height1;

    _heightNotifier.value = target;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      physics: FlexPageScrollPhysics(widget.pageWidths),
      scrollDirection: Axis.horizontal,
      child: ValueListenableBuilder(
        valueListenable: _heightNotifier,
        builder: (context, double height, _) {
          return SizedBox(
            height: height,
            child: widget.child,
          );
        },
      ),
    );
  }
}
```

### 性能优化

使用ValueNotifier而不是setState，避免不必要的rebuild，提高性能。

## 第四次尝试：Sliver实现

### 新的需求

随着项目发展，需要支持大量数据的场景，普通的Row实现性能堪忧。于是我开始研究Sliver实现。

### Sliver的挑战

Sliver的实现比普通Widget复杂得多，需要：
1. 动态计算每个item的宽度
2. 处理Sliver的layout协议
3. 支持懒加载

### 最终实现

```dart
class FlexSliverSlider extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const FlexSliverSlider({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  State<FlexSliverSlider> createState() => _FlexSliverSliderState();
}

class _FlexSliverSliderState extends State<FlexSliverSlider> {
  Map<int, GlobalKey> _keys = {};
  FlexPageScrollPhysics _physics = FlexPageScrollPhysics([]);

  void _getWidgetSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<double> widths = [];
      for (GlobalKey key in _keys.values) {
        final renderObject = key.currentContext?.findRenderObject();
        if (renderObject is RenderBox) {
          widths.add(renderObject.size.width);
        }
      }
      setState(() {
        _physics = FlexPageScrollPhysics(widths);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: _physics,
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              var key = _keys[index] ??= GlobalKey();
              _getWidgetSize();

              return KeyedSubtree(
                key: key,
                child: widget.itemBuilder(context, index),
              );
            },
            childCount: widget.itemCount,
          ),
        )
      ],
    );
  }
}
```

## 总结与心得

### 技术要点

1. **ScrollPhysics定制**：理解ScrollPhysics的工作原理是关键，特别是createBallisticSimulation方法
2. **性能优化**：使用ValueNotifier而不是setState，避免不必要的rebuild
3. **Sliver协议**：对于大量数据，使用Sliver实现可以获得更好的性能
4. **动画平滑**：使用ScrollSpringSimulation创建自然的滚动动画

### 踩坑记录

1. **PageView不适合变宽场景**：PageView是为等宽页面设计的，强行改造会很难受
2. **Row+ScrollView更灵活**：对于变宽需求，使用Row+SingleChildScrollView更灵活
3. **高度计算要精确**：滚动过程中的高度计算要考虑边界情况，避免数组越界
4. **Sliver的异步布局**：Sliver的layout是异步的，需要addPostFrameCallback获取尺寸

### 最终效果

经过几轮迭代，最终实现了：
- ✅ 可变宽度的页面滑动
- ✅ 平滑的高度过渡动画
- ✅ 自然的吸附效果
- ✅ 支持大量数据的高性能实现

### 源码地址

完整的代码已经开源，欢迎大家star和提issue：
[GitHub 仓库](https://github.com/chdo002/variable_width_scrollphysics)

---

**如果这篇文章对你有帮助，欢迎点赞、收藏、转发！有任何问题也可以在评论区交流～**