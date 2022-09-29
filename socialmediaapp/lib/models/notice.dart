import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String activtyUserId;
  final String activtyType;
  final String postId;
  final String postPhoto;
  final String comment;
  final Timestamp createdTime;

  Notice(
      {required this.id,
      required this.activtyUserId,
      required this.activtyType,
      required this.postId,
      required this.postPhoto,
      required this.comment,
      required this.createdTime});

  factory Notice.createdByDoc(DocumentSnapshot doc) {
    return Notice(
      id: doc.id,
      activtyUserId: doc.get("activtyUserId"),
      activtyType: doc.get("activtyType"),
      postId: doc.get("postId"),
      postPhoto: doc.get("postPhoto"),
      comment: doc.get("comment"),
      createdTime: doc.get("createdTime"),
    );
  }
}
