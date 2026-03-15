import 'package:variable_width_scrollphysics/simple_console.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SimpleConsole().show(context);
    });
  }

  Widget _page({required double width, required Color color, required int itemCount, required int crossAxisCount}) {
    return Container(
      color: color,
      width: width,
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(10),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: 10, crossAxisSpacing: 10),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(index.toString()),
            );
          }),
    );
  }

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
              pageWidths: [width - 100, width],
              pageHeights: [140, 230],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _page(width: width - 100, color: Colors.red, itemCount: 8, crossAxisCount: 4),
                  _page(width: width, color: Colors.green, itemCount: 15, crossAxisCount: 5),
                ],
              ),
            ),
          ),
          Text('Hello World!'),
          ElevatedButton(onPressed: () {
            SimpleConsole().log('Hello World! ${DateTime.now()}');
          }, child: Text('Log'))
        ],
      )),
    );
  }
}
