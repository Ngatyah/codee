// ignore_for_file: avoid_print

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String?> get getFilePath async {
    final directory = await getExternalStorageDirectory();
    return directory?.path;
  }

  static Future<File> get getFile async {
    var status = await Permission.manageExternalStorage.status;
    print(status);
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    final path = await getFilePath;
    return File('$path/myfile.txt');
  }

  static Future<File> saveToFile(String data) async {
    final file = await getFile;
    print(await getFile);
    return file.writeAsString(data);
  }

  static Future<String> readFiles() async {
    final file = await getFile;
    String data = await file.readAsString();
    return data;
  }
}
