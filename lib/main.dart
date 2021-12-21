import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Onmi Wheel Car Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
  int _counter = 0;
  String? cmd;
  BluetoothConnection? rpi;
  var _isGrabbing = true;

  void _sendToRpi(String text) async {
    rpi!.output.add(Uint8List.fromList(utf8.encode(text)));
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> _connectToRpi() async {
    List<BluetoothDevice> paired =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    for (BluetoothDevice device in paired) {
      if (device.name == 'raspberrypi') {
        cmd = device.name;
        rpi = await BluetoothConnection.toAddress(device.address);
      }
    }
    setState(() {
      _counter++;
    });
  }

  void _disconnectRpi() {
    rpi!.close();
    rpi!.dispose();
  }

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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('command return: $cmd'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(onPressed: _connectToRpi, child: Text('Connect')),
            TextButton(onPressed: _disconnectRpi, child: Text('Disconnect')),
            Center(
              child: Row(
                children: [
                  Spacer(),
                  IconButton(
                    onPressed: () => {_sendToRpi('l')},
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                    ),
                    iconSize: 60,
                  ),
                  Container(
                    width: 60,
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: 90 * math.pi / 180,
                          child: IconButton(
                              iconSize: 60,
                              onPressed: () => {_sendToRpi('f')},
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                              )),
                        ),
                        Spacer(
                          flex: 3,
                        ),
                        Transform.rotate(
                          angle: 90 * math.pi / 180,
                          child: IconButton(
                              iconSize: 60,
                              onPressed: () => {_sendToRpi('b')},
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                              )),
                        ),
                        Spacer(
                          flex: 1,
                        )
                      ],
                    ),
                  ),
                  IconButton(
                      iconSize: 60,
                      onPressed: () => {_sendToRpi('r')},
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                      )),
                  Spacer(),
                ],
              ),
            ),
            Center(
              child: Row(
                children: [
                  Spacer(),
                  GestureDetector(
                      onTapUp: (details) {
                        _sendToRpi('s');
                      },
                      onTapDown: (details) => {_sendToRpi('w')},
                      child: Icon(
                        Icons.rotate_left,
                        size: 60,
                      )),
                  GestureDetector(
                    onTapUp: (details) => _sendToRpi('s'),
                    onTapDown: (details) => {_sendToRpi('c')},
                    child: Icon(Icons.rotate_right, size: 60),
                  ),
                  Spacer()
                ],
              ),
            ),
            IconButton(
              onPressed: () => {
                _isGrabbing ? _sendToRpi('u') : _sendToRpi('d'),
                _isGrabbing = !_isGrabbing
              },
              icon: const Icon(Icons.sports_handball),
              iconSize: 60,
            )
          ],
        ),
      ),
    );
  }
}
