import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/log.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'file:///C:/Projects/Flutter/soprano_video_downloader/lib/usage/helper.dart';
import 'file:///C:/Projects/Flutter/soprano_video_downloader/lib/usage/permission_handler.dart';
import 'package:soprano_video_downloader/screens/video_player_screen.dart';
import 'package:soprano_video_downloader/usage/enc_dec_handler.dart';

class DownloadScreen extends StatefulWidget {
  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  String url =
      "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8";

  List<FileSystemEntity> file = new List();

  bool isLoading = true;
  bool isDownloading = false;

  String progress = Helper.PREP_DOWNLOAD;

  BuildContext ctx;

  String _fName = "Video";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Videos"),
      ),
      body: RefreshIndicator(
        onRefresh: () => _setup(),
        child: Builder(
          builder: (context) {
            ctx = context;
            return Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: file.length == 0
                          ? Center(
                            child: Text(
                                "You don't have any videos...\nClick download button below to download it."),
                          )
                          : ListView.builder(
                              itemCount: file.length,
                              itemBuilder: (context, index) {
                                //return Text(file[index].toString());
                                return _getVideoCardWidget(file[index].path);
                              },
                            ),
                    ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: isDownloading
            ? SizedBox(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                height: 25,
                width: 25,
              )
            : Icon(Icons.download_rounded),
        label: isDownloading ? Text("$progress") : Text("Download Video"),
        onPressed: () async {
          // encTestVideo();
          if (!isDownloading) {
            if (file.length >= 1) {
              Helper.showToast("Video already exists");
            } else {
              _downloadWithFFmpeg();
              setState(() {
                isDownloading = true;
              });
            }
          } else {
            Helper.showToast("Already downloading video...");
          }
        },
      ),
    );
  }

  /// `_setup()` helps to set variables and request permission.

  Future<void> _setup() async {
    bool permStatus = await PermissionHandler.checkStoragePermission();
    if (permStatus) {
      // String dir = await Helper.createDir();
      Directory dir = await getTemporaryDirectory();
      setState(() {
        file = Directory(dir.path).listSync();
        isLoading = false;
      });
    } else {
      Helper.showToast("Application need storage permission to work");
    }
  }

  /// `_downloadWithFFmpeg()` downloads HLS Video from the url and saves in the
  /// storage directory.
  _downloadWithFFmpeg() async {
    try {
      bool permStatus = await PermissionHandler.checkStoragePermission();
      if (permStatus) {
        final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
        /*String dirPath = await Helper.createDir();
        String filePath = "$dirPath/$_fName.mp4";*/
        Directory tempDir = await getTemporaryDirectory();
        String tempFilePath = "${tempDir.path}/$_fName.mp4";

        List<String> arguments = [
          "-i",
          "$url",
          "-acodec",
          "copy",
          "-bsf:a",
          "aac_adtstoasc",
          "-vcodec",
          "copy",
          tempFilePath,
        ];

        FlutterFFmpegConfig fFmpegConfig = FlutterFFmpegConfig();
        fFmpegConfig.enableStatisticsCallback(_statisticsCallback);
        fFmpegConfig.enableLogCallback((log) => _logCallback(log));

        _flutterFFmpeg.executeAsyncWithArguments(arguments,
            (executionId, returnCode) async {
          if (returnCode == 0) {
            // await EncDecHandler.encryptFile(dirPath, _fName);

            // Encryption Function to encrypt downloaded video
            // startEncryption("${tempDir.path}/$_fName");
            _setup();

            setState(() {
              isDownloading = false;
              // progress = Helper.PREP_VIDEO;
            });
          } else if (returnCode == 1) {
            Helper.showToast("Oops, Something went wrong...");
            setState(() {
                isDownloading = false;
            });

          }
        });
      } else {
        Helper.showToast("Application need storage permission to work");
      }
    } catch (e) {
      print("error _downloadWithFFmpeg : ${e.toString()}");
      Helper.showToast("Oops, Something went wrong...");
      isDownloading = false;
    }
  }

  /// `_statisticsCallback()` FlutterFFmpegConfig method
  void _statisticsCallback(Statistics statistics) {
    setState(() {
      progress =
          "${(statistics.size.toDouble() / 1000000).toStringAsFixed(2)} MB";
    });
  }
  /// `_logCallback()` FlutterFFmpegConfig method
  void _logCallback(Log log) {
  }

  /// `_startEncryption()` to encrypt video file
  _startEncryption(String filePath) async {
    // compute(EncDecHandler.encryptFile, filePath).then((value) => _encryptionDone());
    /*await EncDecHandler.encryptFile(filePath);
    _encryptionDone();*/

    setState(() {
      isDownloading = true;
      progress = Helper.PREP_VIDEO;
    });
    // compute(EncDecTest.Encrypt, filePath).then((value) => _encryptionDone());

    /*await EncDecTest.Encrypt(filePath);
    _encryptionDone();*/
  }

  /// `_encryptionDone()` calls when encryption completes
  _encryptionDone() {
    print("enc Done");
    setState(() {
      isDownloading = false;
      _setup();
    });
  }

  /// `_getVideoCardWidget()` return widget to show in the `ListView`
  Widget _getVideoCardWidget(String path) {
    String fileName = path.split('/').last;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fileName),
              RawMaterialButton(
                onPressed: () {
                  Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          path: path,
                        ),
                      ));
                },
                elevation: 2.0,
                fillColor: Colors.white,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.redAccent[700],
                  size: 30.0,
                ),
                padding: EdgeInsets.all(10.0),
                shape: CircleBorder(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
