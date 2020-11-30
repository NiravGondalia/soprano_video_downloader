import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';

// ignore: slash_for_doc_comments
/**
 `Helper` class contains constant strings and static methods that can be used for
 general purpose.
 */

class Helper{

  static const String PREP_DOWNLOAD = "Preparing Download";
  static const String PREP_VIDEO = "Preparing Video";

  static Future<String> createDir() async {
    String dirToBeCreated = "SopranoVideoDownloader";

    String path = await ExtStorage.getExternalStorageDirectory();
    String finalDir = join(path, dirToBeCreated);

    var dir = Directory(finalDir);
    bool dirExists = await dir.exists();
    if (!dirExists) {
      dir.create();
    }
    return finalDir;
  }

  static showToast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1);
  }

  static Future<void> deleteMp4File(String filePath) async {
    print("deleting file : $filePath");
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("File deleting error - ${e.toString()}");
    }
  }
}