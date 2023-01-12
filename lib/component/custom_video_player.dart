import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final VoidCallback onNewVideoPressed;

  const CustomVideoPlayer({
    Key? key,
    required this.video,
    required this.onNewVideoPressed,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController;
  Duration currentPosition = Duration();
  bool showControls = false;

  @override
  void initState() {
    super.initState();

    initializeController();
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget){
    super.didUpdateWidget(oldWidget);

    if(oldWidget.video.path != widget.video.path){
      initializeController();
    }
  }

  initializeController() async {
    currentPosition = Duration();

    videoController = VideoPlayerController.file(
      File(widget.video.path),
    );

    await videoController!.initialize();

    videoController!.addListener(() {
      final currentPosition = videoController!.value.position;

      setState(() {
        this.currentPosition = currentPosition;
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return CircularProgressIndicator();
    }

    return Center(
      child: AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: GestureDetector(
          onTap: () {
            setState(() {
              showControls = !showControls;
            });
          },
          child: Stack(
            children: [
              VideoPlayer(
                videoController!,
              ),
              if (showControls)
                _Controls(
                  onReversePressed: onReversePressed,
                  onPlayPressed: onPlayPressed,
                  onForwardPressed: onForwardPressed,
                  isPlaying: videoController!.value.isPlaying,
                ),
              if (showControls)
                _NewVideo(
                  onPressed: widget.onNewVideoPressed,
                ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: currentPosition.inSeconds.toDouble(),
                          onChanged: (double val) {
                            videoController!
                                .seekTo(Duration(seconds: val.toInt()));
                          },
                          min: 0,
                          max: videoController!.value.duration.inSeconds
                              .toDouble(),
                        ),
                      ),
                      Text(
                        '${videoController!.value.duration.inMinutes}:${(videoController!.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onReversePressed() {
    final currentPosition = videoController!.value.position;

    Duration position = Duration();

    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onPlayPressed() {
    // 이미 실행중이면 중지
    // 실행중이 아니면 실행
    setState(() {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
    });
  }

  void onForwardPressed() {
    final maxPosition = videoController!.value.duration;
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;

    if ((maxPosition - Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }
    videoController!.seekTo(position);
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onReversePressed;
  final VoidCallback onPlayPressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;

  const _Controls({
    Key? key,
    required this.onReversePressed,
    required this.onPlayPressed,
    required this.onForwardPressed,
    required this.isPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      height: MediaQuery.of(context).size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
            onPressed: onReversePressed,
            iconData: Icons.rotate_left,
          ),
          renderIconButton(
            onPressed: onPlayPressed,
            iconData: isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          renderIconButton(
            onPressed: onForwardPressed,
            iconData: Icons.rotate_right,
          ),
        ],
      ),
    );
  }

  Widget renderIconButton(
      {required VoidCallback onPressed, required IconData iconData}) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 30.0,
      color: Colors.white,
      icon: Icon(
        iconData,
      ),
    );
  }
}

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewVideo({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: IconButton(
        color: Colors.white,
        iconSize: 30.0,
        onPressed: onPressed,
        icon: Icon(
          Icons.photo_camera_back,
        ),
      ),
    );
  }
}
