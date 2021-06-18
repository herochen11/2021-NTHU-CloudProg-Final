import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';


class PLayVideo extends StatefulWidget {

  final String url;
  PLayVideo({Key? key,required this.url})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PLayVideo> {

  VideoPlayerController videoPlayerController = VideoPlayerController.network('');
  late ChewieController chewieController ;
  var init = false;
  
  @override
    void initState() {
        super.initState();
        initializeVideoPlayer();
        initializeVideoPlayer().whenComplete(() => 
          setState(() {
              chewieController = ChewieController(
                videoPlayerController: videoPlayerController,
                autoPlay: true,
                looping: false,
                autoInitialize: true,
            );
            init = true;
          }
      ));
    }
  
  Future<void> initializeVideoPlayer() async {
    
    videoPlayerController = VideoPlayerController.network(widget.url);
 
    await videoPlayerController.initialize();
  }
   
  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }
  
  Widget build(BuildContext context) {
    return Container(
        child: init? 
        Chewie( controller: chewieController,) : 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading'),
        ],
      )
    );
  }
}