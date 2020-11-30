import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soprano_video_downloader/usage/enc_dec_handler.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  String path;

  VideoPlayerScreen({this.path});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>{
  File _videoFile;

  VideoPlayerController _videoPlayerController;
  /// _chewieController is for the UI of VideoPlayer
  ChewieController _chewieController;
  bool _isLoading = true;



  @override
  void initState() {
    super.initState();
    print("init");
    _setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Play Video"),
      ),
      body: Builder(
        builder: (context) {
          return Center(
            child: _isLoading
                ? CircularProgressIndicator()
                : AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: Chewie(
                      controller: _chewieController,
                    ),
                  ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // _videoFile.delete();
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  /// `_initVideoPlayer()` initializes VideoPlayer and Chewie
  Future<void> _initVideoPlayer() async {
    await _videoPlayerController.initialize();
    setState(() {
      print(_videoPlayerController.value.aspectRatio);
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
      );
      _isLoading = false;
    });
  }

  ///  `_setup()` initialize variables and VideoPlayer
  _setup() async {
    _videoFile = File(widget.path);
    _videoPlayerController = VideoPlayerController.file(_videoFile);
    _initVideoPlayer();

    // Decrypting video file to play

    /*EncDecHandler.decryptFile(widget.path).then((value) {
      _videoFile = value;
      _videoPlayerController = VideoPlayerController.file(_videoFile);
      initVideoPlayer();
      setState(() {
        isLoading = false;
      });
    });*/
  }

  /// `_startDecryption()` to decrypt video file to play in VideoPlayer
  _startDecryption(String filePath){
    compute(EncDecHandler.decryptFile, filePath).then((value) => _decryptionDone(value));
  }

  /// `_decryptionDone()` calls when decrypiton completes
  _decryptionDone(File file){
    setState(() {
      _videoFile = file;
      _videoPlayerController = VideoPlayerController.file(_videoFile);
      _initVideoPlayer();
      _isLoading = false;
    });
  }
}
