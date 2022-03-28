import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:currency/widget/currency_listview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _netConnectionController = NetConnectionController();
  final _connectivity = MyConnectivity.instance;
  final currencyListView = CurrencyListView();
  Map _source = {ConnectivityResult.none: false};

  @override
  Widget build(BuildContext context) {
    _connectivity.initialise();
    _connectivity.myStream.listen((event) {
      _source = event;
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.none:
          _netConnectionController.updateColor(false);
          currencyListView.dispose();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Disconnected"),
            backgroundColor: Colors.red,
          ));
          break;
        case ConnectivityResult.mobile:
            _netConnectionController.updateColor(true);
            currencyListView.retryConnect(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Connected"),
              backgroundColor: Colors.green,
            ));
          break;
        case ConnectivityResult.wifi:
            _netConnectionController.updateColor(true);
            currencyListView.retryConnect(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Connected"),
              backgroundColor: Colors.green,
            ));
          break;
      }
    });
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _netConnectionController.color.value,
          title: Text(widget.title),
        ),
        body: currencyListView,
      );
    });
  }
}

class NetConnectionController extends GetxController {
  var color = Colors.blue.obs;

  updateColor(bool connection) {
    color(connection ? Colors.blue : Colors.red);
  }
}

class MyConnectivity {
  MyConnectivity._internal();
  static final MyConnectivity _instance = MyConnectivity._internal();
  static MyConnectivity get instance => _instance;
  Connectivity connectivity = Connectivity();
  StreamController controller = StreamController.broadcast();
  Stream get myStream => controller.stream;

  void initialise() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isOnline = true;
      } else {
        isOnline = false;
      }
    } on SocketException catch (_) {
      isOnline = false;
    }
    controller.sink.add({result: isOnline});
  }

  void disposeStream() => controller.close();
}
