import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FullScreenView extends StatelessWidget {
  final String imageUrl;

  const FullScreenView({super.key, required this.imageUrl});

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        if (await Permission.manageExternalStorage.isDenied) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            throw Exception('Manage External Storage permission not granted.');
          }
        }
      } else {
        if (await Permission.storage.isDenied) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission not granted.');
          }
        }
      }
    }
  }

  Future<void> saveImage(BuildContext context) async {
    try {
      await requestStoragePermission();

      final downloadsDir = Directory('/storage/emulated/0/Download');

      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final fileName = imageUrl.split('/').last;
      final newPath = '${downloadsDir.path}/$fileName';

      await File(imageUrl).copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to Download folder')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fullscreen View")),
      body: Center(
        child: Image.file(File(imageUrl)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => saveImage(context),
        child: const Icon(Icons.download),
        tooltip: 'Save to Downloads',
      ),
    );
  }
}
