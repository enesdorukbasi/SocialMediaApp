import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Reference _storage = FirebaseStorage.instance.ref();
  String _imageId = "";

  Future<String> postImageUpload(File file) async {
    _imageId = Uuid().v4();
    UploadTask uploadManager =
        _storage.child("images/posts/post_$_imageId.jpg").putFile(file);
    String uploadedImageUrl = "";
    while (true) {
      try {
        TaskSnapshot snapshot = await uploadManager.snapshot;
        uploadedImageUrl = await snapshot.ref.getDownloadURL();
        break;
      } catch (ex) {}
    }
    return uploadedImageUrl;
  }

  Future<String> profileImageUpload(File file) async {
    _imageId = Uuid().v4();
    UploadTask uploadManager =
        _storage.child("images/profile/profile_$_imageId.jpg").putFile(file);
    TaskSnapshot snapshot = await uploadManager.snapshot;
    String uploadedImageUrl = await snapshot.ref.getDownloadURL();
    return uploadedImageUrl;
  }

  postImageDelete(String postUrl) {
    RegExp rule = RegExp(r"post_.+\.jpg");
    var match = rule.firstMatch(postUrl);
    String FileName = match![0].toString();

    if (FileName != null) {
      _storage.child("images/posts/$FileName").delete();
    }
  }
}
