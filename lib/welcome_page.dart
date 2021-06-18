import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify.dart';
import 'package:test_final/drive_record_page.dart';


class WelcomePage extends StatefulWidget {
  // 1
  final VoidCallback shouldLogOut;

  WelcomePage({Key? key,required this.shouldLogOut})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

List<SensorData> sensorDataFromJson(String str) => List<SensorData>.from(json.decode(str).map((x) => SensorData.fromJson(x)));
class SensorData{

  SensorData({
        required this.camera,
        required this.heart_beat_sensor,
        required this.three_axis_sensor,
        required this.gas_sensor,
        required this.welcome
    });
    String welcome;
    String camera;
    String heart_beat_sensor;
    String three_axis_sensor;
    String gas_sensor;

    factory SensorData.fromJson(Map<String, dynamic> json){ return SensorData(
        camera: json["camera"],
        heart_beat_sensor: json["heart_beat_sensor"],
        three_axis_sensor: json["three_axis_sensor"],
        gas_sensor: json["gas_sensor"],
        welcome : json["welcome"]
      );
    }

     Map<String, dynamic> toJson() => {
        "camera": camera,
        "heart_beat_sensor": heart_beat_sensor,
        "three_axis_sensor": three_axis_sensor,
        "gas_sensor": gas_sensor,
        "welcome": welcome
    };
}
class _WelcomePageState extends State<WelcomePage> {
  

  String username = '';

  
  _WelcomePageState(){
     _getUsername().then((value) => setState((){
        username = value;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            bottomOpacity: 0.0,
            elevation: 0.0,
            title: Text(
              'Safe Driving',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.right,
            ),
            leading: IconButton(onPressed:(){}, icon: Icon(Icons.menu), color: Colors.black,iconSize: 30),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child:
                    GestureDetector(child: Icon(Icons.logout,color: Colors.black,), onTap: widget.shouldLogOut),
              )
            ],
          ),
      body : SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [ 
          Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[        
                Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                     ListTile(
                        leading: Image(
                            image: AssetImage('icon/car.png'),
                          ),
                        title: Text('Hello, $username'),
                        subtitle: Text('Your current sensor states are  '),
                    ), 
                    Container(
                      alignment: Alignment.center,
                      child: FutureBuilder<Widget>(
                        future:  _getSeneorState(),
                        builder: (context,snapshot) {
                          if (snapshot.hasData) {
                            //return Text('LOADING...');
                            return snapshot.requireData;
                          } else {
                            return Text('LOADING...');
                          }
                        },
                      ),
                )]),     
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      children: [IconButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>DriveRecordPage()),
                          );}, 
                        icon: Icon(Icons.video_library_outlined)),
                        Text('Driving Record')
                      ]),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[IconButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>DriveRecordPage()),
                          );}, 
                        icon: Icon(Icons.movie_outlined)),
                        Text('Violation Record',textScaleFactor: 1,)
                      ]),
                    Column(
                      children:[IconButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>DriveRecordPage()),
                          );}, 
                        icon: Icon(Icons.smart_toy_outlined)),
                        Text('Lex Bot')
                    ])
                  ],
                )
            ]),
      ]))
    );
  }

   Future<String> _getUsername() async {

      final awsUser = await Amplify.Auth.getCurrentUser();
      String name = 'error';
      name = awsUser.username;
      print(name);
      return name;
  }

   Future<Widget> _getSeneorState() async{
    
    final Completer<Widget> completer = Completer();
    Uri uri = Uri.parse('https://7up3g5sst4.execute-api.us-east-1.amazonaws.com/final/getsensorstate?');
    final response = await http.get(uri);
   
    if(response.statusCode == 200){
      Map<String, dynamic> result = json.decode(response.body);

      completer.complete(
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Camera Status: ' + result['message']['camera'])),
              Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Heart Beat Rate: ' + result['message']['heart_beat_sensor'])),
              Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Gas Sensor: ' + result['message']['gas_sensor'])),
              Padding(padding: EdgeInsets.only(bottom: 10) ,child: Text('Three_axis_sensor: ' + result['message']['three_axis_sensor'])),
            ]
          ))
      );
     }
     else{
        completer.complete(
        Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Text('LOADING...')
        )
      );
     }
     return completer.future;
  }
}

