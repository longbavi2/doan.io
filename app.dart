import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';
void ShowToask(String message)
{
  Fluttertoast.showToast(
      msg: '$message',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
void main()
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeApp(),
    );
  }
}

class HomeApp extends StatefulWidget
{
  @override
  AppState createState()=> AppState();
}

class AppState extends State<HomeApp> {
  // khai báo biến

  String nhietdo = "0";
  String doam = "0";
  String trangthaiden = "OFF";
  String trangthaiquat = "OFF";
  String DataMQTT = "Null";
  String clientIdentifier =  Random().toString();

  String mqtt_server = "ngoinhaiot.com";

  int mqtt_port = 	1111;

  String mqtt_user = "doanlong28012000asdasd";

  String mqtt_pass = "	3F405128F5C349A9";

  String topicpub = "doanlong28012000asdasd/quat";

  String topicsub = "doanlong28012000asdasd/maylanh";

  String imgden = "assets/off.jpg";
  String imgquat = "assets/off.jpg";

  late mqtt.MqttClient client;
  late mqtt.MqttConnectionState connectionState;
  // CHẠY 1 LẦN DUY NHẤT hay dùng để kết nối server hoặc khởi tạo hàm timer để lấy dữ liệu
  @override
  void initState() {
    super.initState();
    ShowToask("WELCOME TO APP IOT");
    ConnectMQTT();
  }

  @override
  Widget build(BuildContext context) {
    // TẠO GIAO DIỆN trong Scaffold
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Image(image:AssetImage('assets/10.jpg',),),
            Text("HELLO APP IOT - MQTT"),
            SizedBox(width: 8.0,),
            Image(image:AssetImage('assets/12.jpg',),),
          ],
        ),
      ),
     body:Container(
       padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
       constraints: BoxConstraints.expand(),
       color: Colors.white,
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children :<Widget>[

           RaisedButton(
             padding: const EdgeInsets.all(20),
             textColor: Colors.white,
             color: Colors.green,
             onPressed: DK_DEN,
             child: Text('ĐÈN'),
           ),

           SizedBox(height: 20.0,),

           RaisedButton(
             padding: const EdgeInsets.all(20),
             textColor: Colors.white,
             color: Colors.green,
             onPressed: DK_QUAT,
             child: Text('QUẠT'),
           ),

           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[

               Text(
                 "Nhiệt Độ:",
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.redAccent,
                 ),
               ),

               SizedBox(width: 8.0,),

               Text(
                 nhietdo,
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.redAccent,
                 ),
               ),

               Image(
                 image: AssetImage('assets/8.jpg',),
                 height: 50,
                 width: 50,
               ),


             ],
           ),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[

               Text(
                 "Độ ẩm:",
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.redAccent,
                 ),
               ),

               SizedBox(width: 8.0,),

               Text(
                 doam,
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.redAccent,
                 ),
               ),

               Image(
                 image: AssetImage('assets/9.jpg',),
                 height: 50,
                 width: 50,
               ),


             ],
           ),
           SizedBox(height: 20.0,),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[

               Text(
                 "Trạng Thái Đèn:",
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.redAccent,
                 ),
               ),

               SizedBox(width: 8.0,),

               Text(
                 trangthaiden,
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.blueAccent,
                 ),
               ),
             ],
           ),

           SizedBox(height: 20.0,),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[

               Text(
                 "Trạng Thái quạt:",
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.redAccent,
                 ),
               ),

               SizedBox(width: 8.0,),

               Text(
                 trangthaiquat,
                 style: TextStyle(
                   fontSize: 20,
                   color: Colors.blueAccent,
                 ),
               ),
             ],
           ),
         ],

       ),
       ),
     );
  }
  void DK_DEN()
  {
    print("Điều khiển đèn");
    String TX = "";
    if(imgden.toString() == "assets/off.jpg")
    {
      trangthaiden = "ON";
      TX = "{\"TB1\":\"1\"}";

      Clientpublish(TX);
    }
    else if(imgden.toString() == "assets/on.jpg")
    {
      trangthaiden = "OFF";
      TX = "{\"TB1\":\"0\"}";

      Clientpublish(TX);
    }
  }
  void DK_QUAT()
  {
    print("Điều khiển quạt");
    String TX = "";
    if(imgquat.toString() == "assets/off.jpg")
    {
      trangthaiquat = "ON";
      TX = "{\"TB2\":\"1\"}";

      Clientpublish(TX);
    }
    else if(imgquat.toString() == "assets/on.jpg")
    {
      trangthaiquat = "OFF";
      TX = "{\"TB2\":\"0\"}";

      Clientpublish(TX);
    }
  }
  void ConnectMQTT() async
  {
    client = mqtt.MqttClient(mqtt_server, '');
    client.port = mqtt_port;
    client.logging(on: true);
    client.keepAlivePeriod = 30;
    client.onDisconnected = _onDisconnected;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .keepAliveFor(30)
        .withWillTopic('DisconnectMQTT')
        .withWillMessage('DisconnectMQTT')
        .withWillQos(mqtt.MqttQos.atMostOnce);
    client.connectionMessage = connMess;
    try
    {
      await client.connect(mqtt_user, mqtt_pass);
    }
    catch (e)
    {
      print(e);
    }

    if(client.connectionState == mqtt.MqttConnectionState.connected)
    {
      // đăng kí 1 gói tin nhận dữ liệu của ESP
      connectionState = client.connectionState;
      client.subscribe(topicsub, mqtt.MqttQos.exactlyOnce); // 0 1 2
      print("Connect mqtt.ngoinhaiot.com");
    }
    else
    {
      print("NOT Connect mqtt.ngoinhaiot.com");
    }


    client.updates.listen(MessageMQTT);

  }

  void _onDisconnected()
  {
    print('Disconnect Broker MQTT');
  }
  void _disconnect() {
    client.disconnect();
    print('Disconnect Broker MQTT');
  }

  void MessageMQTT(List<mqtt.MqttReceivedMessage> event)
  {
    final mqtt.MqttPublishMessage recMess = event[0].payload as mqtt.MqttPublishMessage;
    final String message =  mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print('Data MQTT: ${message}');

    var data = message;

    var DataJsonObject = json.decode(data);


    setState(() {
      DataMQTT = message;
      nhietdo = DataJsonObject['ND'];
      doam = DataJsonObject['DA'];

      if(DataJsonObject['TB1'] == '0')
      {

        imgden = "assets/off.jpg";
      }
      else if(DataJsonObject['TB1'] == '1')
      {

        imgden = "assets/on.jpg";
      }

      if(DataJsonObject['TB2'] == '0')
      {

        imgquat = "assets/off.jpg";
      }
      else if(DataJsonObject['TB2'] == '1')
      {

        imgquat  = "assets/on.jpg";
      }
    });
  }

  void  Clientpublish(String message)
  {
    if (connectionState == mqtt.MqttConnectionState.connected)
    {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topicpub, MqttQos.exactlyOnce, builder.payload);
      print('Data send:  ${message}');
    }
  }
}
