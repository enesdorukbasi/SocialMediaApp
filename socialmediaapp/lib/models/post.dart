import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String postUrl;
  final String content;
  final String publishedById;
  final String location;
  final int likeCount;

  Post(
      {required this.id,
      required this.postUrl,
      required this.content,
      required this.publishedById,
      required this.location,
      required this.likeCount});

  factory Post.createPostByDoc(DocumentSnapshot doc) {
    return Post(
        id: doc.id,
        postUrl: doc.get("postUrl"),
        content: doc.get("content"),
        publishedById: doc.get("publishedById"),
        location: doc.get("location"),
        likeCount: doc.get("likeCount"));
  }
}
