import 'package:flutter/material.dart';
import 'package:flutter_simple_console/simple_console.dart';
import 'demo1.dart';
import 'demo2.dart';
import 'demo3.dart';
import 'demo4.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6366F1)),
        scaffoldBackgroundColor: Color(0xFFF8FAFC), // 浅灰蓝色背景
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6366F1), // 靛蓝色AppBar
        title: Text(widget.title, style: TextStyle(fontSize: 20)),
        actions: [
          MaterialButton(
              onPressed: () {
                if (SimpleConsole().isOpen) {
                  SimpleConsole().close();
                } else {
                  SimpleConsole().show(context);
                }
              },
              child: Text('Console', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Divider(),
            Demo1(),
            Divider(),
            Demo2(),
            Divider(),
            Demo3(),
            Divider(),
            Demo4(),
          ],
        ),
      ),
    );
  }
}
