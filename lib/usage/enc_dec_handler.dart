import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:soprano_video_downloader/common.dart';
import 'package:soprano_video_downloader/usage/helper.dart';


// ignore: slash_for_doc_comments
/**
 `EncDecHandler` class for encrypt and decrypt Video files.
 */


class EncDecHandler{

  static encryptFile(String filePath) async {
    try{
      File inFile = new File("$filePath.mp4");

      String outputFilePath = await Helper.createDir();
      File outFile = new File("$outputFilePath/Video.aes");

      bool outFileExists = await outFile.exists();

      if(!outFileExists){
        await outFile.create();
      }

      final videoFileContents = await inFile.readAsStringSync(encoding: latin1);

      final key = Key.fromUtf8(Common.ENC_DEC_KEY);
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key));

      // final encrypted = encrypter.encrypt(videoFileContents, iv: iv);
      // final encrypted = encrypter.encrypt(videoFileContents);
      List args = [encrypter, videoFileContents, iv];
      final encrypted = encryptNow(args);
      await outFile.writeAsBytes(encrypted.bytes);

    } catch (e) {
      print("Encryption Error : $e");
    } finally {
      Helper.deleteMp4File("$filePath.mp4");
    }

  }

  static encryptNow(List args){
    return foundation.compute(ourEnc, args);
  }
  static ourEnc(List args){
    return args[0].encrypt(args[1], args[2]);
  }

  static Future<File> decryptFile(String path) async {
    try{
      File inFile = new File(path);
      // File outFile = new File("videodec.mp4");

      /*bool outFileExists = await outFile.exists();

    if(!outFileExists){
      await outFile.create();
    }*/

      final videoFileContents = await inFile.readAsBytesSync();

      final key = Key.fromUtf8(Common.ENC_DEC_KEY);
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key));

      final encryptedFile = Encrypted(videoFileContents);
      // final decrypted = encrypter.decrypt(encryptedFile, iv: iv);
      final decrypted = encrypter.decrypt(encryptedFile);

      final decryptedBytes = latin1.encode(decrypted);

      final buffer = decryptedBytes.buffer;





      String outputFilePath = await Helper.createDir();
      String tempPath = outputFilePath;
      // Directory tempDir = await getExternalStorageDirectory();
      // String tempPath = tempDir.path;
      var filePath = tempPath + '/file_01.mp4';
      return File(filePath).writeAsBytes(
          buffer.asUint8List(decryptedBytes.offsetInBytes, decryptedBytes.lengthInBytes));

      //await outFile.writeAsBytes(decryptedBytes);
    } catch(e){
      print("Dec error = ${e.toString()}");
    }



  }
}