import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/screens/comments.dart';
import 'package:socialmediaapp/screens/profile.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';

import '../models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final UserLocal publishedUser;

  const PostCard({super.key, required this.post, required this.publishedUser});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _likeCount = 0;
  bool _iLike = false;
  String _currentUserId = "";

  @override
  void initState() {
    super.initState();
    _currentUserId = Provider.of<AuthenticationService>(context, listen: false)
        .currentUserId
        .toString();
    _likeCount = widget.post.likeCount;

    isLikedPost();
  }

  isLikedPost() async {
    bool isLike = await FireStoreService().isLiked(widget.post, _currentUserId);

    if (isLike) {
      setState(() {
        _iLike = true;
      });
    } else {
      setState(() {
        _iLike = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [_postTitle(), _postImage(), _postDown()],
      ),
    );
  }

  Widget _postTitle() {
    return ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  Profile(profileUserId: widget.post.publishedById),
            ));
          },
          child: CircleAvatar(
            backgroundImage: widget.publishedUser.pphoto != ""
                ? NetworkImage(widget.publishedUser.pphoto)
                : NetworkImage(
                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  Profile(profileUserId: widget.post.publishedById),
            ));
          },
          child: Text(
            widget.publishedUser.username,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        trailing: _currentUserId == widget.publishedUser.id
            ? IconButton(
                onPressed: () => postOptions(),
                icon: Icon(Icons.more_vert),
              )
            : null);
  }

  Widget _postImage() {
    return GestureDetector(
      onDoubleTap: () => _likePost(),
      child: Image.network(
        widget.post.postUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _postDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: _iLike
                  ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : Icon(Icons.favorite_border),
              onPressed: _likePost,
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsPage(post: widget.post),
                      ));
                },
                icon: Icon(Icons.comment_outlined)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "$_likeCount Beğeni",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 2.0),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: RichText(
            text: TextSpan(
              text: widget.publishedUser.username,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              children: [
                TextSpan(
                    text: widget.post.content,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _likePost() {
    setState(() {
      if (_iLike == false) {
        _iLike = true;
        _likeCount += 1;
      } else {
        _iLike = false;
        _likeCount -= 1;
      }
    });
    Post newPost = Post(
        id: widget.post.id,
        postUrl: widget.post.postUrl,
        content: widget.post.content,
        publishedById: widget.post.publishedById,
        location: widget.post.location,
        likeCount: _likeCount);
    FireStoreService().likePost(newPost, _currentUserId);
  }

  postOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Gönderi Seçenekleri"),
          children: [
            SimpleDialogOption(
              child: Text("Gönderiyi Sil"),
              onPressed: () {
                FireStoreService().deletePost(_currentUserId, widget.post);
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Text(
                "Vazgeç",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }
}
