import 'package:flutter/material.dart';

class SimpleConsole {
  static final SimpleConsole _instance = SimpleConsole._internal();

  factory SimpleConsole() => _instance;

  SimpleConsole._internal();

  OverlayEntry? _entry;
  final ValueNotifier<List<String>> _logs = ValueNotifier([]);

  void show(BuildContext context) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (context) => _ConsoleWidget(
        logs: _logs,
        onClose: () {
          _entry?.remove();
          _entry = null;
        },
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void close() {
    _entry?.remove();
    _entry = null;
  }

  bool get isOpen => _entry != null;

  void log(String message) {
    final time = DateTime.now().toString().split(' ').last.substring(0, 8);
    _logs.value = [..._logs.value, "[$time] $message"];
    if (_logs.value.length > 50) _logs.value = _logs.value.sublist(1);
  }
}

class _ConsoleWidget extends StatefulWidget {
  final ValueNotifier<List<String>> logs;
  final VoidCallback onClose;

  const _ConsoleWidget({required this.logs, required this.onClose});

  @override
  State<_ConsoleWidget> createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<_ConsoleWidget> {
  Offset offset = const Offset(20, 400);
  double width = 280.0;
  double height = 200.0;
  double fontSize = 11;
  bool isMinimized = false; // 是否最小化

  final padding = 20.0;
  final minimizedWidth = 180.0;
  final minimizedHeight = 40.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.logs.addListener(_scrollToBottom);
    // 确保初始位置在屏幕内
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensureWindowInBounds();
      }
    });
  }

  // 确保窗口在屏幕边界内
  void _ensureWindowInBounds() {
    if (!mounted) return;

    // 计算新的偏移量
    double newDx = offset.dx;
    double newDy = offset.dy;

    if (newDx < padding) {
      newDx = padding;
    }
    if (newDx + width > MediaQuery.of(context).size.width - padding) {
      newDx = MediaQuery.of(context).size.width - padding - width;
    }
    // 状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    if (newDy < statusBarHeight) {
      newDy = statusBarHeight;
    }
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    if (newDy + height > MediaQuery.of(context).size.height - bottomPadding) {
      newDy = MediaQuery.of(context).size.height - height - bottomPadding;
    }

    // 如果位置有变化，更新状态
    if (newDx != offset.dx || newDy != offset.dy) {
      setState(() {
        offset = Offset(newDx, newDy);
      });
    }
  }

  void _scrollToBottom() {
    if (isMinimized) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 最小化时的尺寸逻辑
    final currentWidth = isMinimized ? minimizedWidth : width;
    final currentHeight = isMinimized ? minimizedHeight : height;

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Material(
        elevation: 12,
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: currentWidth,
          height: currentHeight,
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 0.5), borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              // 主体内容
              Column(
                children: [
                  _buildMacHeader(), // macOS 风格顶部栏
                  if (!isMinimized) ...[
                    const Divider(color: Colors.white10, height: 1),
                    Expanded(child: _buildLogList()),
                  ],
                ],
              ),
              // 右下角缩放手柄 (最小化时不显示)
              if (!isMinimized)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final screenHeight = MediaQuery.of(context).size.height;
                        width = (width + details.delta.dx).clamp(minimizedWidth, screenWidth - padding - offset.dx);
                        height = (height + details.delta.dy).clamp(minimizedHeight, screenHeight - padding - offset.dy);
                      });
                    },
                    onPanEnd: (details) {
                      // 缩放结束后确保窗口在屏幕内
                      _ensureWindowInBounds();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.bottomRight,
                      color: Colors.transparent,
                      // 透明背景，增大触发区域
                      child: const Icon(Icons.south_east, size: 14, color: Colors.white38),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. macOS 风格红绿灯 Header
  Widget _buildMacHeader() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          offset += details.delta;
        });
      },
      onPanEnd: (details) {
        // 拖动结束后确保窗口在屏幕内
        _ensureWindowInBounds();
      },
      // onDoubleTap: () => setState(() => isMinimized = !isMinimized),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        color: Colors.white.withValues(alpha: 0.1),
        child: Row(
          children: [
            // 左侧红绿灯
            _trafficLight(Colors.redAccent, widget.onClose), // 关闭按钮
            _trafficLight(Colors.amber, () {
              setState(() => isMinimized = true);
            }), // 最小化
            _trafficLight(Colors.green, () {
              setState(() => isMinimized = false);
            }), // 还原

            const Spacer(),

            if (!isMinimized)
              GestureDetector(
                onTap: () {
                  setState(() {
                    fontSize += 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: const Icon(Icons.add, color: Colors.white70, size: 20),
                ),
              ),

            if (!isMinimized)
              GestureDetector(
                onTap: () {
                  setState(() {
                    fontSize -= 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: const Icon(Icons.remove, color: Colors.white70, size: 20),
                ),
              ),

            // 右上角清空按钮
            if (!isMinimized)
              GestureDetector(
                onTap: () => widget.logs.value = [],
                child: const Icon(Icons.delete_outline, color: Colors.white70, size: 20),
              ),

            // 最小化状态下的文字提示
            if (isMinimized) const Text(" Logs", style: TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // 2. 抽取红绿灯组件
  Widget _trafficLight(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 20,
        height: 20,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  // Parse log entry into timestamp and message parts
  List<String> _parseLogEntry(String entry) {
    final timestamp = entry.substring(0, 10);
    return [timestamp, entry.substring(11)];
  }

  Widget _buildLogList() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: widget.logs,
      builder: (context, list, _) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final List<String> parts = _parseLogEntry(list[i]);
            final String timestamp = parts[0];
            final String message = parts[1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RichText(
                text: TextSpan(
                  children: [
                    if (timestamp.isNotEmpty)
                      TextSpan(
                        text: timestamp,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: fontSize,
                        ),
                      ),
                    TextSpan(
                      text: ' ' + message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    widget.logs.removeListener(_scrollToBottom);
    _scrollController.dispose();
    super.dispose();
  }
}
