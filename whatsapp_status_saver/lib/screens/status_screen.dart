import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_status_saver/screens/full_screen_view.dart';
import 'package:whatsapp_status_saver/screens/full_screen_video_view.dart';

class StatusScreen extends StatefulWidget {
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<FileSystemEntity> statuses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    requestPermissionAndLoadStatuses();
  }

  Future<void> requestPermissionAndLoadStatuses() async {
    if (Platform.isAndroid) {
      final manageStorage = await Permission.manageExternalStorage.request();
      final storage = await Permission.storage.request();

      if (manageStorage.isGranted || storage.isGranted) {
        loadStatuses();
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
        await openAppSettings();
      }
    } else {
      loadStatuses();
    }
  }

  void loadStatuses() {
    final legacyPath = Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');
    final scopedPath = Directory('/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

    Directory? statusDir;

    if (scopedPath.existsSync()) {
      statusDir = scopedPath;
    } else if (legacyPath.existsSync()) {
      statusDir = legacyPath;
    }

    if (statusDir != null && statusDir.existsSync()) {
      final files = statusDir
          .listSync()
          .where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.mp4'))
          .toList();

      setState(() {
        statuses = files;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WhatsApp .Statuses folder not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Local WhatsApp Statuses')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : statuses.isEmpty
          ? Center(child: Text('No statuses found.'))
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final file = statuses[index];
          return GestureDetector(
            onTap: () {
              if (file.path.endsWith('.mp4')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenVideoView(url: file.path),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenView(imageUrl: file.path),
                  ),
                );
              }
            },
            child: file.path.endsWith('.mp4')
                ? Stack(
              children: [
                Container(color: Colors.black12),
                Center(child: Icon(Icons.play_circle, size: 40)),
              ],
            )
                : Image.file(File(file.path), fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
