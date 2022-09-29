import 'package:flutter_local_notifications/flutter_local_notifications.dart ';
import 'package:flutter/material.dart';

class LocalNotification extends StatefulWidget{

 @override
 State<StatefulWidget> createState() {
  return _LocalNotification();
 }
}


class _LocalNotification extends State<LocalNotification>{

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();
@override
void initState(){
  super.initState();
  var initializationSettingsAndroid =
  new AndroidInitializationSettings("@mipmap/ic_launcher");
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
}




//void selectNotification(String ){

//  print('hello');
 // return null;
//}



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
    'Flutter is awesome',
    platformChannelSpecifics,
    payload: 'This is notification detail Text...',
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: new Center(child: Column(children: <Widget>[
          RaisedButton(child: new Text('Show Notification'), onPressed: () {_showNotification();})
        ]))


    );
  }

}