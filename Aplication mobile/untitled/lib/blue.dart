import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart ';
import 'package:untitled/notification.dart';


Uuid _UART_UUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid _UART_RX   = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid _UART_TX   = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

void main() {
  runApp(MyAppp());
}

class MyAppp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth LE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Bluetooth LE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
   MyHomePage({ Key? key,  required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> _foundBleUARTDevices = [];
  late StreamSubscription<DiscoveredDevice> _scanStream ;
  late Stream<ConnectionStateUpdate> _currentConnectionStream;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late QualifiedCharacteristic _txCharacteristic  ;
  late QualifiedCharacteristic _rxCharacteristic;
  late Stream<List<int>> _receivedDataStream;
  late TextEditingController _dataToSendText;
  late TextEditingController _data_ageToSendText;
  bool _scanning = false;
  bool _connected = false;
  String _logTexts = "";
  List<String> _receivedData = [];
  int _numberOfMessagesReceived = 0;

  void initState() {
    super.initState();
    _dataToSendText = TextEditingController();
    _data_ageToSendText = TextEditingController();

  }

  void refreshScreen() {
    setState(() {});
  }

  void _sendData() async {
    await flutterReactiveBle.writeCharacteristicWithResponse(_rxCharacteristic, value: _dataToSendText.text.codeUnits);
    _dataToSendText.clear();
  }
  void _sendData_age() async {
    await flutterReactiveBle.writeCharacteristicWithResponse(_rxCharacteristic, value: _data_ageToSendText.text.codeUnits);
    _data_ageToSendText.clear();
  }

  void onNewReceivedData(List<int> data) {
    _numberOfMessagesReceived += 1;
    if (String.fromCharCodes(data)[0]=="M") {
      _showNotification();
    }
    _receivedData.add( "$_numberOfMessagesReceived: ${String.fromCharCodes(data)}");

    if (_receivedData.length > 5) {
      _receivedData.removeAt(0);
    }
    refreshScreen();

  }

  void _disconnect() async {
    await _connection.cancel();
    _connected = false;
    refreshScreen();
  }

  void _stopScan() async {
    await _scanStream.cancel();
    _scanning = false;
    refreshScreen();
  }

  Future<void> showNoPermissionDialog() async => showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) => AlertDialog(
      title: const Text('No location permission '),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text('No location permission granted.'),
            const Text('Location permission is required for BLE to function.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Acknowledge'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );

  void _startScan() async {
    bool goForIt=false;
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted)
        goForIt=true;
    } else if (Platform.isIOS) {
      goForIt=true;
    }
    if (goForIt) { //TODO replace True with permission == PermissionStatus.granted is for IOS test
      _foundBleUARTDevices = [];
      _scanning = true;
      refreshScreen();
      _scanStream =
          flutterReactiveBle.scanForDevices(withServices: [_UART_UUID]).listen((
              device) {
            if (_foundBleUARTDevices.every((element) =>
            element.id != device.id)) {
              _foundBleUARTDevices.add(device);
              refreshScreen();
            }
          }, onError: (Object error) {
            _logTexts =
            "${_logTexts}ERROR while scanning:$error \n";
            refreshScreen();
          }
          );
    }
    else {
      await showNoPermissionDialog();
    }
  }

  void onConnectDevice(index) {
    _currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id:_foundBleUARTDevices[index].id,
      prescanDuration: Duration(seconds: 1),
      withServices: [_UART_UUID, _UART_RX, _UART_TX],
    );
    _logTexts = "";
    refreshScreen();
    _connection = _currentConnectionStream.listen((event) {
      var id = event.deviceId.toString();
      switch(event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            _logTexts = "${_logTexts}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            _connected = true;
            _logTexts = "${_logTexts}Connected to $id\n";
            _numberOfMessagesReceived = 0;
            _receivedData = [];
            _txCharacteristic = QualifiedCharacteristic(serviceId: _UART_UUID, characteristicId: _UART_TX, deviceId: event.deviceId);
            _receivedDataStream = flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);
            _receivedDataStream.listen((data) {
              onNewReceivedData(data);

            }, onError: (dynamic error) {
              _logTexts = "${_logTexts}Error:$error$id\n";
            });
            _rxCharacteristic = QualifiedCharacteristic(serviceId: _UART_UUID, characteristicId: _UART_RX, deviceId: event.deviceId);
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            _connected = false;
            _logTexts = "${_logTexts}Disconnecting from $id\n";
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            _logTexts = "${_logTexts}Disconnected from $id\n";
            break;
          }
      }
      refreshScreen();
    });
  }
  //////////////////////////////////////////notification////////////////////////////////////////////
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();
  @override
  void initStatee(){
    super.initState();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future _showNotification() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Notification',
      'you are sitting with a bad posture',
      platformChannelSpecifics,
      payload: 'please sit well',
    );
  }

  Future<dynamic> onSelectNotification(payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Your Notification Detail"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }


  ////////////////////////////////////////////////////////////////////////////////////////////hh


  @override
  Widget build(BuildContext context) => Scaffold(
    //backgroundColor: Colors.lightGreen[100],
    appBar: null,

    body: SingleChildScrollView(


  child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[


          Container(
            margin: EdgeInsets.only(top: 20,bottom:20),
            child :Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Bluetooth',style: TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 40 ,fontWeight: FontWeight.bold ,
            ),),
              //  Icon(Icons.bluetooth,color: Colors.blue,size :40),

              ],
            )
          ),
        //IconButton(icon: Icon(Icons.circle_notifications_sharp ,size: 40, color: Colors.grey),onPressed: (){_showNotification();}),

          Text("BLE UART Devices found :",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold, color: Colors.blueGrey[900],)),
          Container(
              margin: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Color(0xFFBBDEFB),
                      width:2
                  )
              ),
              height: 100,
              child: ListView.builder(
                  itemCount: _foundBleUARTDevices.length,
                  itemBuilder: (context, index) => Card(

                      child: ListTile(
                        dense: true,
                        enabled: !((!_connected && _scanning) || (!_scanning && _connected)),
                        trailing: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            (!_connected && _scanning) || (!_scanning && _connected)? (){}: onConnectDevice(index);
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            alignment: Alignment.center,
                            child: const Icon(Icons.add_link),
                          ),
                        ),
                        subtitle: Text(_foundBleUARTDevices[index].id),
                        title: Text("$index: ${_foundBleUARTDevices[index].name}"),
                      ))
              )
          ),

          Text("Status messages :",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold ,color: Colors.blueGrey[900], )),
          Container(
              margin: const EdgeInsets.all(3.0),
              width:1400,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      //color: Colors.blueGrey,
                      color: Color(0xFFBBDEFB),
                      width:2
                  )
              ),
              height: 90,
              child: Scrollbar(

                  child: SingleChildScrollView(
                      child: Text(_logTexts)
                  )
              )
          ),

          Text("Gender :",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold ,color: Colors.blueGrey[900],)),
          Container(

              margin: const EdgeInsets.all(3.0),
              padding: const EdgeInsets.all(8.0),

              decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      //color: Colors.blueGrey,
                      color: Color(0xFFBBDEFB),
                      width:2
                  )
              ),
              child: Row(
                  children: <Widget> [
                    Expanded(

                        child: TextField(
                          enabled: _connected,
                          controller: _dataToSendText,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter F or M '
                          ),
                        )
                    ),
                    RaisedButton(
                        color: Colors.blue[50],
                        child: Icon(
                          Icons.send,
                          color:_connected ? Colors.blue : Colors.blueGrey,
                        ),
                        onPressed: _connected ? _sendData: (){}

                    ),
                  ]
              )),

           Text("Age :",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.blueGrey[900], )),
          Container(
              margin: const EdgeInsets.all(3.0),

              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      //color: Colors.blueGrey,
                      color: Color(0xFFBBDEFB),
                      width:2
                  )
              ),
              child: Row(
                  children: <Widget> [
                    Expanded(
                        child: TextField(
                          enabled: _connected,
                          controller: _data_ageToSendText,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your age'
                          ),
                        )
                    ),
                    RaisedButton(
                        color: Colors.blue[50],
                        child: Icon(
                          Icons.send,
                          color:_connected ? Colors.blue : Colors.blueGrey,
                        ),
                        onPressed: _connected ? _sendData_age: (){}
                    ),
                  ]
              )),
           Text("Received data :",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold, color: Colors.blueGrey[900], )),
          Container(
              margin: const EdgeInsets.all(3.0),
              width:1400,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      //color: Colors.blueGrey,
                      color: Color(0xFFBBDEFB),
                      width:2
                  )
              ),
              height: 90,
              child: Text(_receivedData.join("\n"))

          ),

        ],
      ),
    ),
    persistentFooterButtons: [
      Container(
        height: 40,
        width: 400,
        child: Column(
          children: [
            if (_scanning) const Text("Scanning: Scanning" ,style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.blueGrey,)) else const Text("Scanning: Idle",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.blueGrey,)),
            if (_connected) const Text("Connected" ,style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.green,)) else const Text("disconnected.",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.red,)),
          ],
        ) ,
      ),
  ListTile(

  title: Row(

  children: <Widget>[

    ButtonTheme(
    minWidth: 100.0,
    child:
      RaisedButton(
        color: Colors.blue[50],
        onPressed: !_scanning && !_connected ? _startScan : (){},
        child: Icon(
          Icons.play_arrow,
          color: !_scanning && !_connected ? Colors.lightBlue: Colors.blueGrey,
        ),
      ),
    ),
    ButtonTheme(
      minWidth: 100.0,
      child:
      RaisedButton(
          color: Colors.blue[50],

          onPressed: _scanning ? _stopScan: (){},
          child: Icon(
            Icons.stop,
            color:_scanning ? Colors.lightBlue: Colors.blueGrey,
          )
      ),
    ),
    ButtonTheme(
      minWidth: 100.0,
      child:
      RaisedButton(
          color: Colors.blue[50],
          onPressed: _connected ? _disconnect: (){},
          child: Icon(
            Icons.cancel,
            color:_connected ? Colors.lightBlue:Colors.blueGrey,
          )
      ),
    ),
  ],
  ),
  )
    ],
  );
}
