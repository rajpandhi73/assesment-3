import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FullScreenVideoView extends StatefulWidget {
  final String url;

  const FullScreenVideoView({super.key, required this.url});

  @override
  _FullScreenVideoViewState createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        await Permission.manageExternalStorage.request();
      } else {
        await Permission.storage.request();
      }
    }
  }

  Future<void> saveVideo(BuildContext context) async {
    await requestStoragePermission();

    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');

      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final fileName = widget.url.split('/').last;
      final newPath = '${downloadsDir.path}/$fileName';

      final sourceFile = File(widget.url);
      final targetFile = File(newPath);

      if (!await targetFile.exists()) {
        await sourceFile.copy(newPath);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video saved to Downloads folder')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File already exists in Downloads')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving video: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Video"),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => saveVideo(context),
        child: const Icon(Icons.download),
        tooltip: 'Download Video',
      ),
    );
  }
}
