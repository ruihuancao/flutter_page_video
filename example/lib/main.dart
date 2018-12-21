import 'package:flutter/material.dart';
import 'package:flutter_simple_video_player/flutter_simple_video_player.dart';

void main() {
  runApp(MaterialApp(
      home: MyApp()
  ));
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Video Demo"),
        ),
        body: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 200.0,
                  child: SimpleVideoPlayer(
                    "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8",
                  ),
                )
              ],
            )
        )
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: ListView(
        children: <Widget>[
          RaisedButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return HomePage();
            }));
          }, child: Text("Video Play"),),
          RaisedButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return SimpleVideoPlayer("http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8", isLandscape: true,);
            }));
          }, child: Text("Video Full Play"),)
        ],
      ),
    );
  }
}



