import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String publishedId;
  final Timestamp createdTime;

  Comment(this.id, this.content, this.publishedId, this.createdTime);

  factory Comment.createCommentByDoc(DocumentSnapshot doc) {
    return Comment(doc.id, doc.get("content"), doc.get("publishedId"),
        doc.get("createdTime"));
  }
}
