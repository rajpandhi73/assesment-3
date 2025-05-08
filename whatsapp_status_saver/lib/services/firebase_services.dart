import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

Future<void> uploadStatus(File file) async {
  try {
    // Get file name
    String fileName = basename(file.path);

    // Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child("statuses/$fileName");
    UploadTask uploadTask = storageRef.putFile(file);

    // Wait for upload to complete
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Store metadata in Firestore
    await FirebaseFirestore.instance.collection('statuses').add({
      'name': fileName,
      'url': downloadUrl,
      'timestamp': Timestamp.now(),
    });

    print('✅ Upload successful: $fileName');
  } catch (e) {
    print('❌ Error uploading status: $e');
    rethrow;
  }
}
