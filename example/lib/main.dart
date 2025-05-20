import 'package:example/expanedwidget.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker_dynamic/numberpicker_dynamic.dart';

import 'global.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeHandler.addListener(() {
      setState(() {
        debugPrint("Theme change triggered");
      });
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Number Picker',
      themeMode: themeHandler.currentTheme(),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
      ),
      home: const MyHomePage(title: 'Dynamic Number Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  num _value = 123;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              themeHandler.switchTheme();
            },
            icon: Icon(Icons.sunny),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Callback value:",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    _value.toString(),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: NumberPickerDynamic(
                    height: 190,
                    initValue: _value,
                    onValueChange: (value) {
                      debugPrint("Value is $value");
                      setState(() {
                        _value = value;
                      });
                    },
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Value by setState()",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _value++;
                  });
                },
                child: Text("Increase the value higher (+1)"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _value--;
                    if (_value < 0) _value = 0;
                  });
                },
                child: Text("Decrease the value lower (-1)"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _value += 0.1;
                  });
                },
                child: Text("Increase decimal (+0.1)"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _value -= 0.1;
                    if (_value < 0) _value = 0;
                  });
                },
                child: Text("Decrease decimal (-0.1)"),
              ),
              Divider(),
              Center(
                child: Text(
                  "Example of build-in widget",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ExpandedNumberPicker(
                onExpanded: () {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    //Scroll to the end
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 250),
                      curve: Curves.ease,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
