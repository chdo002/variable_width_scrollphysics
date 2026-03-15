import 'package:variable_width_scrollphysics/simple_console.dart';
import 'package:flutter/material.dart';

import 'demo1.dart';
import 'demo2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              child: Text('Console')),
        ],
      ),
      body: Center(
          child: Column(
        children: [
          Demo1(),
          Divider(),
          Demo2(),
        ],
      )),
    );
  }
}
