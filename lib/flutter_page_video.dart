library flutter_page_video;


import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:io' show File;

enum VideoType { net, assets , file}

class VideoPlayPause extends StatefulWidget {
  final VideoPlayerController controller;

  VideoPlayPause(this.controller);

  @override
  State createState() {
    return new _VideoPlayPauseState();
  }
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  Widget imageFadeAnim;
  VoidCallback listener;

  _VideoPlayPauseState() {
    listener = () {
      setState(() {});
    };
  }

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    controller.setVolume(1.0);
    controller.play();
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  Widget getController() {
    Color primaryColor = Theme.of(context).primaryColor;
    return Center(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
                icon: Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          Align(
            alignment: Alignment.center,
            child: controller.value.isBuffering
                ? CircularProgressIndicator()
                : IconButton(
                icon: Icon(
                  Icons.pause,
                  color: primaryColor,
                  size: 60.0,
                ),
                onPressed: onPlayerController),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: 0.8,
              child: Container(
                  height: 30.0,
                  color: Colors.black45,
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Center(
                            child: Text(
                              "${controller.value.position.toString().split(".")[0]}",
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                      Expanded(
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          colors:
                          VideoProgressColors(playedColor: primaryColor),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Center(
                            child: Text(
                              "${controller.value.duration.toString().split(".")[0]}",
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void onPlayerController() {
    if (!controller.value.initialized) {
      return;
    }
    if (controller.value.isPlaying) {
      imageFadeAnim = getController();
      controller.pause();
    } else {
      imageFadeAnim = FadeAnimation(
        child: getController(),
      );
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      GestureDetector(
        child: Center(
          child: new VideoPlayer(controller),
        ),
        onTap: onPlayerController,
      ),
      Center(
        child: imageFadeAnim,
      ),
    ];

    return new Stack(
      fit: StackFit.passthrough,
      children: children,
    );
  }
}

class FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  FadeAnimation({this.child, this.duration: const Duration(milliseconds: 500)});

  @override
  _FadeAnimationState createState() => new _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
    new AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? new Opacity(
      opacity: 1.0 - animationController.value,
      child: widget.child,
    )
        : new Container();
  }
}

typedef Widget VideoWidgetBuilder(
    BuildContext context, VideoPlayerController controller);

abstract class PlayerLifeCycle extends StatefulWidget {
  final VideoWidgetBuilder childBuilder;
  final String dataSource;

  PlayerLifeCycle(this.dataSource, this.childBuilder);
}

abstract class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = createVideoPlayerController();
    controller.addListener(() {
      if (controller.value.hasError) {
        print(controller.value.errorDescription);
      }
    });
    controller.initialize();
    controller.setLooping(true);
    controller.play();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context, controller);
  }

  VideoPlayerController createVideoPlayerController();
}

class NetworkPlayerLifeCycle extends PlayerLifeCycle {
  NetworkPlayerLifeCycle(String dataSource, VideoWidgetBuilder childBuilder)
      : super(dataSource, childBuilder);

  @override
  _NetworkPlayerLifeCycleState createState() =>
      new _NetworkPlayerLifeCycleState();
}

class _NetworkPlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  VideoPlayerController createVideoPlayerController() {
    return new VideoPlayerController.network(widget.dataSource);
  }
}

class AssetPlayerLifeCycle extends PlayerLifeCycle {
  AssetPlayerLifeCycle(String dataSource, VideoWidgetBuilder childBuilder)
      : super(dataSource, childBuilder);

  @override
  _AssetPlayerLifeCycleState createState() => new _AssetPlayerLifeCycleState();
}

class _AssetPlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  VideoPlayerController createVideoPlayerController() {
    return new VideoPlayerController.asset(widget.dataSource);
  }
}

class FilePlayerLifeCycle extends PlayerLifeCycle {
  FilePlayerLifeCycle(String dataSource, VideoWidgetBuilder childBuilder)
      : super(dataSource, childBuilder);

  @override
  _FilePlayerLifeCycleState createState() => new _FilePlayerLifeCycleState();
}

class _FilePlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  VideoPlayerController createVideoPlayerController() {
    return new VideoPlayerController.file(File(widget.dataSource));
  }
}

class AspectRatioVideo extends StatefulWidget {
  final VideoPlayerController controller;

  AspectRatioVideo(this.controller);

  @override
  AspectRatioVideoState createState() => new AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      if (initialized != controller.value.initialized) {
        initialized = controller.value.initialized;
        setState(() {});
      }
    };
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      final Size size = controller.value.size;
      return new Center(
        child: new AspectRatio(
          aspectRatio: size.width / size.height,
          child: new VideoPlayPause(controller),
        ),
      );
    } else {
      return new Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

/// 播放网络视频
class NetVideo extends StatelessWidget {
  final String source;

  NetVideo(this.source);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new NetworkPlayerLifeCycle(
        source,
            (BuildContext context, VideoPlayerController controller) =>
        new AspectRatioVideo(controller),
      ),
    );
  }
}

/// 播放assets 视频
class AssetVideo extends StatelessWidget {
  final String assets;

  AssetVideo(this.assets);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new AssetPlayerLifeCycle(
          assets,
              (BuildContext context, VideoPlayerController controller) =>
          new AspectRatioVideo(controller)),
    );
  }
}

/// 播放文件视频
class FileVideo extends StatelessWidget {
  final String path;

  FileVideo(this.path);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new FilePlayerLifeCycle(
          path,
              (BuildContext context, VideoPlayerController controller) =>
          new AspectRatioVideo(controller)),
    );
  }
}

/// 全屏播放视频
class VideoFullPage extends StatefulWidget {
  final String source;
  final VideoType type;

  VideoFullPage(this.source, {this.type: VideoType.net});

  @override
  _VideoFullPageState createState() => _VideoFullPageState();
}

class _VideoFullPageState extends State<VideoFullPage> {
  @override
  void initState() {
    super.initState();
    // 全屏（隐藏status bar 和Navitation Bar）
    SystemChrome.setEnabledSystemUIOverlays([]);
    // 设置横屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    // 退出全屏
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    // 返回竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(VideoType.net == widget.type){
      return Scaffold(
          body: FileVideo(widget.source)
      );
    }else if(VideoType.net == widget.type){
      return Scaffold(
          body: AssetVideo(widget.source)
      );
    }else{
      return Scaffold(
          body: NetVideo(widget.source)
      );
    }
  }
}


