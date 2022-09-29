import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';
import 'package:socialmediaapp/services/storageservice.dart';
import 'package:timeago/timeago.dart';

class EditProfile extends StatefulWidget {
  final UserLocal? user;

  const EditProfile({super.key, this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var _formKey = GlobalKey<FormState>();
  String _username = "";
  String _about = "";
  File? _selectedPhoto;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.user!.username != null || widget.user!.username != "") {
      _username = widget.user!.username;
    }
    if (widget.user!.about != null || widget.user!.about != "") {
      _about = widget.user!.about;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              onPressed: _save, icon: Icon(Icons.check, color: Colors.black))
        ],
      ),
      body: ListView(
        children: [
          _loading
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          _profilePhoto(),
          _userInformations()
        ],
      ),
    );
  }

  _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _loading = true;
      });
      String activeUserId =
          Provider.of<AuthenticationService>(context, listen: false)
              .currentUserId
              .toString();

      if (_selectedPhoto == null) {
        await FireStoreService()
            .editUser(activeUserId, _username, widget.user!.pphoto, _about);
      } else {
        String newPpUrl =
            await StorageService().profileImageUpload(_selectedPhoto!);
        await FireStoreService()
            .editUser(activeUserId, _username, newPpUrl, _about);
      }
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
    }
  }

  _profilePhoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: InkWell(
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: _getImage(),
          radius: 55.0,
        ),
        onTap: () {
          _selectedGallery();
        },
      ),
    );
  }

  _userInformations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              initialValue: _username,
              decoration: InputDecoration(labelText: "Kullanıcı adı"),
              validator: (value) {
                return value!.trim().length < 4
                    ? "Kullanıcı adı minimum 4 karakter olmalıdır."
                    : null;
              },
              onSaved: (newValue) => _username = newValue.toString(),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: _about,
              decoration: InputDecoration(labelText: "Hakkında"),
              validator: (value) {
                return value!.trim().length > 100
                    ? "100 karakter sınırını geçemezsiniz."
                    : null;
              },
              onSaved: (newValue) => _about = newValue.toString(),
            ),
          ],
        ),
      ),
    );
  }

  _selectedGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _selectedPhoto = File(image.path);
      }
    });
  }

  _getImage() {
    if (_selectedPhoto != null) {
      return FileImage(_selectedPhoto!);
    } else {
      return NetworkImage(widget.user!.pphoto);
    }
  }
}
