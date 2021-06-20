import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_final/play_video.dart';
import 'package:test_final/thumbnail.dart';
import 'package:http/http.dart' as http;

class ViolationRecordPage extends StatefulWidget {

  ViolationRecordPage({Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViolationRecordPageState();
}

class Video{
  final String title;
  final String timeStamp;
  final String link;
  final String type;
  final String source;

  Video({
    required this.title,
    required this.timeStamp,
    required this.link,
    required this.type,
    required this.source
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['video'] as String,
      timeStamp: json['timestamp'] as String ,
      link: json['link'] as String,
      type: json['type'] as String,
      source: json['source'] as String,
    );
  }

}
class _ViolationRecordPageState extends State<ViolationRecordPage>{

  var init = false;
  var none = false;
  late List<Video> videoList;

  @override
    void initState() {
        super.initState();
        initVideoURL();
    }

  Future<void> initVideoURL() async{
      
      Uri uri = Uri.parse('https://f47jfxjyc0.execute-api.us-east-1.amazonaws.com/final/getviolationvideo?');
      final response = await http.get(uri);
      if(response.statusCode == 200){
          Map<String, dynamic> result = jsonDecode(response.body);
          setState(() {
            videoList = result['message'].map<Video>((json) => Video.fromJson(json)).toList();
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
              'Violatoin Record',
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
                                  Column(
                                    children: [
                                      Text(videoList[index].title,style: TextStyle(fontSize: 20,)),
                                      Text(videoList[index].type,style: TextStyle(fontSize: 18,)),
                                    ]),
                                  Text(videoList[index].timeStamp,style: TextStyle(fontSize: 14,))
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
      ) : Container(  
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