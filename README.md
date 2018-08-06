# flutter_page_video

Flutter 视频播放插件

## 依赖
```
dependencies:
  flutter_simple_video_player: ^0.0.2
```

## 示例


```
import 'package:flutter/material.dart';
import 'package:flutter_simple_video_player/flutter_simple_video_player.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Video Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: AppBar(
          title: Text("Video"),
        ),
        body:  Home()
      ),
    );
  }
}


class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          RaisedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VideoFullPage('https://youku.cdn-56.com/20180622/3878_d3968706/index.m3u8',)),
            );
          }, child: Text("full play video"),),
          Container(
            height: 256.0,
            color: Colors.black,
            child: Center(
              child: NetVideo("https://youku.cdn-56.com/20180622/3878_d3968706/index.m3u8"),
            ),
          ),
        ],
      ),
    );
  }
}
```