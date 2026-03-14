import 'package:flutter/material.dart';

class SimpleConsole {
  static final SimpleConsole _instance = SimpleConsole._internal();

  factory SimpleConsole() => _instance;

  SimpleConsole._internal();

  OverlayEntry? _entry;

  final ValueNotifier<List<String>> logs = ValueNotifier([]);

  void show(BuildContext context) {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (context) => _ConsoleWidget(logs: logs),
    );

    Overlay.of(context).insert(_entry!);
  }

  void log(String message) {
    final time = DateTime.now().toString().split(' ').last.substring(0, 8);
    logs.value = [...logs.value, "[$time] $message"];
    if (logs.value.length > 50) {
      logs.value = logs.value.sublist(logs.value.length - 50);
    }
  }

  void clear() => logs.value = [];
}

class _ConsoleWidget extends StatefulWidget {
  final ValueNotifier<List<String>> logs;

  const _ConsoleWidget({required this.logs});

  @override
  State<_ConsoleWidget> createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<_ConsoleWidget> {
  Offset offset = const Offset(20, 100);

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.logs.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    widget.logs.removeListener(_scrollToBottom);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => offset += details.delta),
        child: Material(
          elevation: 10,
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 250,
            height: 200,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: widget.logs,
                    builder: (context, list, _) {
                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: list.length,
                        itemBuilder: (context, i) => Text(
                          list[i],
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
