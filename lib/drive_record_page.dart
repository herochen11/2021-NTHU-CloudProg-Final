import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test_final/play_video.dart';
import 'package:test_final/thumbnail.dart';
import 'package:http/http.dart' as http;

class DriveRecordPage extends StatefulWidget {

  DriveRecordPage({Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DriveRecordPageState();
}

class Video{
  final String title;
  final String timeStamp;
  final String link;

  Video({
    required this.title,
    required this.timeStamp,
    required this.link,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['video'] as String,
      timeStamp: json['timestamp'] as String ,
      link: json['link'] as String,
    );
  }

}
class _DriveRecordPageState extends State<DriveRecordPage>{

  var init = false;
  var none = false;
  late List<Video> videoList;

  @override
    void initState() {
        super.initState();
        initVideoURL();
    }

  Future<void> initVideoURL() async{
      
      Uri uri = Uri.parse('https://f47jfxjyc0.execute-api.us-east-1.amazonaws.com/final/getdrivevideo');
      final response = await http.get(uri);
      if(response.statusCode == 200){
          Map<String, dynamic> result = jsonDecode(response.body);
        setState(() {
            videoList = result['message'].map<Video>((json) => Video.fromJson(json)).toList();
            print(videoList.length);
            if(videoList.length == 0)
              none = true;
            init = true;
          });
          //videoList = result['message'].map<Video>((json) => Video.fromJson(json)).toList();
      }
      else{
      }
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
              'Driving Record',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.right,
            ),
            leading: IconButton(onPressed:(){ Navigator.pop(context); }, icon: Icon(Icons.arrow_back), color: Colors.black,iconSize: 25)
          ),
      body: SafeArea(
        child: init? ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: videoList.length,
          itemBuilder: (BuildContext context, int index) {
            return 
            TextButton(
              onPressed: (){
                showDialog(context: context, 
                  builder: 
                    (BuildContext context)=>AlertDialog(
                        backgroundColor: Colors.transparent,
                        content: PLayVideo(url:videoList[index].link)),
                        );
              },
              child: 
                Card(
                elevation: 10,
                child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child:
                          Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 128, 
                              width: 72,  
                              child: RotatedBox(quarterTurns: 45, child: ThumbNail(url: videoList[index].link)) ),
                          ])),
                      Expanded(
                          flex: 8,
                          child: Container(
                            height: 128,
                            child:
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Text(videoList[index].title,style: TextStyle(fontSize: 20,)),
                                  Text(videoList[index].timeStamp,style: TextStyle(fontSize: 14),)
                                ]
                              )
                            )
                        ),
                    ]
                    
                )
              )
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
      ) : none?
          Container(  
          alignment: Alignment.center,
          child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text('No video Record'),
          ],
          )):
          Container(  
          alignment: Alignment.center,
          child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading'),
        ],
      ))  
    )
  );
  }
}