import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';
import 'package:socialmediaapp/services/storageservice.dart';

class Upload extends StatefulWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? file;
  bool loading = false;

  TextEditingController contentTextController = TextEditingController();
  TextEditingController locationTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return file == null ? uploadButton() : postForm();
  }

  Widget uploadButton() {
    return IconButton(
        onPressed: () {
          selectPhoto();
        },
        icon: Icon(
          Icons.file_upload,
          size: 50,
          color: Colors.black,
        ));
  }

  Widget postForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Gönderi Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              setState(() {
                file = null;
              });
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        actions: [
          IconButton(
              onPressed: _createPost,
              icon: Icon(Icons.send, color: Colors.black))
        ],
      ),
      body: ListView(
        children: [
          loading ? LinearProgressIndicator() : SizedBox(height: 0),
          Container(
            decoration: BoxDecoration(color: Colors.black),
            child: AspectRatio(
                aspectRatio: 16.0 / 9.0,
                child: Image.file(
                  file!,
                )),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: contentTextController,
            decoration: InputDecoration(
                hintText: "Açıklama Ekle",
                contentPadding: EdgeInsets.only(left: 15, right: 15)),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: locationTextController,
            decoration: InputDecoration(
                hintText: "Fotoğraf Nerede Çekildi",
                contentPadding: EdgeInsets.only(left: 15, right: 15)),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    if (!loading) {
      setState(() {
        loading = true;
      });
      String ImageUrl = await StorageService().postImageUpload(file!);
      String? currentUserId =
          Provider.of<AuthenticationService>(context, listen: false)
              .currentUserId;
      await FireStoreService().createPost(ImageUrl, contentTextController.text,
          currentUserId, locationTextController.text);
      setState(() {
        loading = false;
        contentTextController.clear();
        locationTextController.clear();
        file = null;
      });
    }
  }

  selectPhoto() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Gönderi Oluştur"),
          children: [
            SimpleDialogOption(
              child: Text("Fotoğraf Çek"),
              onPressed: () {
                takeAPhoto();
              },
            ),
            SimpleDialogOption(
              child: Text("Galeriden Seç"),
              onPressed: () {
                selectAGallery();
              },
            )
          ],
        );
      },
    );
  }

  takeAPhoto() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);

    setState(() {
      file = File(image!.path);
    });
  }

  selectAGallery() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      try {
        file = File(image!.path);
      } catch (ex) {
        print(ex);
      }
    });
  }
}
