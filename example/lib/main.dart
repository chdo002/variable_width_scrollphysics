import 'package:flutter/material.dart';
import 'package:variable_width_scrollphysics/scroll_physics.dart';

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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        children: [
          Text('Hello World!'),
          SizedBox(
            width: width,
            child: FlexSlider(
              pageWidths: [width, width],
              pageHeights: [100, 200],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.red,
                    width: width,
                    height: 300,
                  ),
                  Container(
                    color: Colors.cyan,
                    width: width,
                    height: 500,
                  ),
                ],
              ),
            ),
          ),
          Text('Hello World!'),
        ],
      )),
    );
  }
}
