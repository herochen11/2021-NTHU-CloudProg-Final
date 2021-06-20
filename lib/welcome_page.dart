import 'dart:convert';
import 'dart:async';
import 'dart:ffi';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify.dart';
import 'package:test_final/drive_record_page.dart';
import 'package:test_final/violation_record.dart';


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
  Timer? timer;
  late num bpm;
  late String camera;
  late num axis_sensor;  

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getSeneorState());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  
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
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 30),
                  child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                     ListTile(
                        leading: Image(
                            image: AssetImage('icon/car.png'),
                            width:50,
                            height: 50
                          ),
                        title: Text('Hello, $username',style: TextStyle(fontSize: 18),),
                        subtitle: Text('Your current sensor states are  ',style: TextStyle(fontSize: 15)),
                        dense: true,
                    ), 
                    Container(
                      alignment: Alignment.center,
                      child: FutureBuilder<String>(
                        future:  _getSeneorState(),
                        builder: (context,snapshot){
                            if (snapshot.hasData) {
                              //return Text('LOADING...');
                              
                              return Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children:[
                                          Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Camera Status: ' + camera,style: TextStyle(fontSize: 18))),
                                          bpm.compareTo(0.0) == 1?
                                            Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Heart Beat Rate: ' + bpm.toInt().toString() + " bpm" ,style: TextStyle(fontSize: 18))): 
                                            Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Heart Beat Rate: Abnormal' ,style: TextStyle(fontSize: 18,color: Colors.red))),
                                          
                                          //Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Gas Sensor: ' + result['message']['gas_sensor'],style: TextStyle(fontSize: 18))),
                                          axis_sensor.compareTo(180.0) == -1?
                                            Padding(padding: EdgeInsets.only(bottom: 10) ,child: Text('Three_axis_sensor: ' + axis_sensor.toString() ,style: TextStyle(fontSize: 18))):
                                            Padding(padding: EdgeInsets.only(bottom: 10) ,child: Text('Three_axis_sensor: Abnormal ',style: TextStyle(fontSize: 18,color: Colors.red))),
                                        ]
                                      ));
                            } else {
                              return Text('LOADING...');
                            }                        
                        },
                      ),
                    )]),     
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [IconButton(onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=>DriveRecordPage()),
                            );}, 
                          icon: Icon(Icons.video_library_outlined)),
                          Text('Driving Record')
                        ]),
                      ),
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[IconButton(onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=>ViolationRecordPage()),
                            );}, 
                          icon: Icon(Icons.movie_outlined)),
                          Text('Violation Record',textScaleFactor: 1,)
                        ]),
                    )
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

   Future<String> _getSeneorState() async{
    final Completer<Widget> completer = Completer();
    Uri uri = Uri.parse('https://f47jfxjyc0.execute-api.us-east-1.amazonaws.com/final/getsensor');
    final response = await http.get(uri);
    //print(response.body);
    if(response.statusCode == 200){
      Map<String, dynamic> result = json.decode(response.body);

      setState(() {
        bpm = result['message']['BPM'];
        camera = result['message']['Camera'];
        axis_sensor = result['message']['Bearing'];
      });
      print(camera);
      print(bpm);
      print(axis_sensor);
      /*completer.complete(
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Camera Status: ' + camera,style: TextStyle(fontSize: 18))),
              int.parse(bpm)>0?
                Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Heart Beat Rate: ' + bpm ,style: TextStyle(fontSize: 18))): 
                Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Heart Beat Rate: Abnoemal' ,style: TextStyle(fontSize: 18,color: Colors.red))),
              
              //Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Gas Sensor: ' + result['message']['gas_sensor'],style: TextStyle(fontSize: 18))),
              Padding(padding: EdgeInsets.only(bottom: 10) ,child: Text('Three_axis_sensor: ' + axis_sensor ,style: TextStyle(fontSize: 18))),
            ]
          ))
      );*/
      return 'done';
     }
     else{
        completer.complete(
        Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Text('LOADING...')
        )
      );
     }
     return 'done';
  }
}

