import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class FileSaver {
  static Future<void> saveTextFile(String text, String fileName) async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Permiso de almacenamiento denegado.');
        return;
      }

      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('Error al acceder al almacenamiento.');
        return;
      }

      String filePath = '${directory.path}/$fileName.txt';
      File file = File(filePath);
      await file.writeAsString(text);

      print('Archivo guardado en: $filePath');
      OpenFile.open(filePath);
    } catch (e) {
      print('Error al guardar archivo: $e');
    }
  }
}
