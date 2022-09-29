import 'package:flutter/material.dart';
import 'package:socialmediaapp/models/post.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';
import 'package:socialmediaapp/widgets/postcard.dart';

class SinglePost extends StatefulWidget {
  final String postId;
  final String publishedUserId;

  const SinglePost(
      {super.key, required this.postId, required this.publishedUserId});

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  Post? _post;
  UserLocal? _user;
  bool _loading = true;

  getPost() async {
    Post post = await FireStoreService()
        .getSinglePost(widget.postId, widget.publishedUserId);

    if (mounted) {
      if (post != null) {
        setState(() {
          _post = post;
        });
        getUser();
      }
    }
  }

  getUser() async {
    UserLocal? user = await FireStoreService().getUser(widget.publishedUserId);

    if (mounted) {
      if (user != null) {
        setState(() {
          _user = user;
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Gönderi",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: !_loading
          ? PostCard(post: _post!, publishedUser: _user!)
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
