import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_ble_peripheral_central/flutter_ble_peripheral_central.dart';
import 'package:permission_handler/permission_handler.dart';

class BLEPeripheralWidget extends StatefulWidget {
  @override
  _BLEPeripheralWidgetState createState() => _BLEPeripheralWidgetState();
}

class _BLEPeripheralWidgetState extends State<BLEPeripheralWidget> {
  final _flutterBlePeripheralCentralPlugin = FlutterBlePeripheralCentral();

  List<String> _events = [];
  final _eventStreamController = StreamController<String>();

  final _bluetoothState = TextEditingController();
  final _advertisingText= TextEditingController();
  final _readableText= TextEditingController();
  final _indicateText= TextEditingController();
  final _writeableText= TextEditingController();

  bool _isSwitchOn = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _permissionCheck();
  }

  @override
  void dispose() {
    _eventStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text(
              'BLE Peripheral View',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          )
      ),
      body:  SingleChildScrollView(child: Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Bluetooth State",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.6,
                      height: 45,
                      child: TextField(
                        controller: _bluetoothState,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12,),
                        ),
                        enabled: false,
                      ),
                    ),
                  ),
                ],
              )
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Advertising data",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.75,
                            height: 45,
                            child: TextField(
                              controller: _advertisingText,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12,),
                              ),
                              enabled: Platform.isIOS ? true : false,
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                              width: MediaQuery.of(context).size.width*0.17,
                              height: 45,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Switch(
                                  value: _isSwitchOn,
                                  activeColor: CupertinoColors.activeBlue,
                                  onChanged: (value) {
                                    setState(() {
                                      _isSwitchOn = value;
                                    });

                                    if(_isSwitchOn) {
                                      _bleStartAdvertising(_advertisingText.text, _readableText.text);
                                    } else {
                                      _bleStopAdvertising();
                                    }
                                  },
                                ),
                              )
                          ),
                        ]),
                  ),
                ],
              )
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Readable characteristic",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.67,
                            height: 45,
                            child: TextField(
                              controller: _readableText,
                              decoration: InputDecoration(
                                // hintText: 'Input indicate value',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12,),
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            height: 45,
                            child:
                            ElevatedButton(
                              onPressed: () async {
                                _bleEditTextCharForRead(_readableText.text);
                              },
                              child: Text('Edit'),
                            ),
                          ),
                        ]
                    ),
                  ),
                ],
              )
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Indication",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.67,
                            height: 45,
                            child: TextField(
                              controller: _indicateText,
                              decoration: InputDecoration(
                                hintText: 'Input indicate value',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12,),
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            height: 45,
                            child:
                            ElevatedButton(
                              onPressed: () async {
                                _bleIndicate(_indicateText.text);
                              },
                              child: Text('Send'),
                            ),
                          ),
                        ]
                    ),
                  ),
                ],
              )
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Writeable characteristic",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.6,
                      height: 45,
                      child: TextField(
                        controller: _writeableText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12,),
                        ),
                        enabled: false,
                      ),
                    ),
                  ),
                ],
              )
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10,),
              child: Container(
                width: double.infinity,
                // height: double.infinity,
                height:  MediaQuery.of(context).size.height*0.32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child:
                ListView.builder(
                  controller: _scrollController,
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(
                            _events[index],
                          style: TextStyle(fontSize: 15,),
                        )
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  StreamSubscription<dynamic>? _eventSubscription;

  void _bleStartAdvertising(String advertisingText, String readableText) async {

    _clearLog();
    _eventStreamController.sink.add('Starting...');

    _eventSubscription = await _flutterBlePeripheralCentralPlugin
        .startBlePeripheralService(advertisingText, readableText)
        .listen((event) {

      _eventStreamController.sink.add('-> '+event);

      _addEvent(event);

      print('----------------------->event: ' + event);
    });
  }

  void _bleStopAdvertising() async {
    await _flutterBlePeripheralCentralPlugin.stopBlePeripheralService();
  }

  void _bleEditTextCharForRead(String readableText) async {
    await _flutterBlePeripheralCentralPlugin.editTextCharForRead(readableText);
  }

  void _bleIndicate(String sendData) async {
    await _flutterBlePeripheralCentralPlugin.sendIndicate(sendData);
  }

  // add the event
  void _addEvent(String event) {
    setState(() {
      _events.add(event);
    });

    Map<String, dynamic> responseMap = jsonDecode(event);

    if (responseMap.containsKey('message')) {
      String message = responseMap['message'];
      print('Message: $message');
    } else if(responseMap.containsKey('state')) {
      setState(() {
        _bluetoothState.text = responseMap['state'];
      });

      if (event == 'disconnected') {
        _eventSubscription?.cancel();
      }
    } else if(responseMap.containsKey('onCharacteristicWriteRequest')) {
      setState(() {
        _writeableText.text = responseMap['onCharacteristicWriteRequest'];
      });
    } else {
      print('Message key not found in the JSON response.');
    }

    // Scroll to the end of the list
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  // clear the log
  void _clearLog() {
    setState(() {
      _events.clear();
    });
  }
  void _permissionCheck() async {
    if (Platform.isAndroid) {
      var permission = await Permission.location.request();
      var bleScan = await Permission.bluetoothScan.request();
      var bleConnect = await Permission.bluetoothConnect.request();
      var bleAdvertise = await Permission.bluetoothAdvertise.request();
      var locationWhenInUse = await Permission.locationWhenInUse.request();

      print('location permission: ${permission.isGranted}');
      print('bleScan permission: ${bleScan.isGranted}');
      print('bleConnect permission: ${bleConnect.isGranted}');
      print('bleAdvertise permission: ${bleAdvertise.isGranted}');
      print('location locationWhenInUse: ${locationWhenInUse.isGranted}');
    }
  }
}
