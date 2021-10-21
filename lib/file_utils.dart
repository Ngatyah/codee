// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path_provider/path_provider.dart';
class FileUtils {
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get getFile async {
    final path = await getFilePath;
    return File('$path/${DateTime.now().millisecondsSinceEpoch}.txt');
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
