// ignore_for_file: prefer_const_constructors
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/comment.dart';
import 'package:socialmediaapp/models/post.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';

class CommentsPage extends StatefulWidget {
  final Post post;

  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  TextEditingController commentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yorumlar", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[100],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [_showComments(), _createComment()],
      ),
    );
  }

  _showComments() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: FireStoreService().getComments(widget.post.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.size <= 0) {
          return Center(
            child: Text(
              "Henüz bir yorum yapılmamış.",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Comment comment =
                Comment.createCommentByDoc(snapshot.data!.docs[index]);

            return _commentRow(comment);
          },
        );
      },
    ));
  }

  FutureBuilder _commentRow(Comment comment) {
    return FutureBuilder<UserLocal?>(
        future: FireStoreService().getUser(comment.publishedId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(height: 0);
          }

          UserLocal? user = snapshot.data;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: snapshot.data!.pphoto != "" ||
                      snapshot.data!.pphoto != null
                  ? NetworkImage(snapshot.data!.pphoto)
                  : NetworkImage(
                      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
            ),
            title: RichText(
                text: TextSpan(
                    text: snapshot.data!.username,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                  TextSpan(
                      text: comment.content,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black)),
                ])),
            subtitle: Text(
                timeago.format(comment.createdTime.toDate(), locale: "tr")),
          );
        });
  }

  _createComment() {
    return ListTile(
      title: TextFormField(
        controller: commentController,
        decoration: InputDecoration(hintText: "Yorum Ekleyin"),
      ),
      trailing:
          IconButton(onPressed: _createCommentProcess, icon: Icon(Icons.send)),
    );
  }

  void _createCommentProcess() {
    String currentUserId =
        Provider.of<AuthenticationService>(context, listen: false)
            .currentUserId
            .toString();

    FireStoreService()
        .createComment(currentUserId, widget.post, commentController.text);
    commentController.clear();
  }
}
