import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmediaapp/models/post.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/services/storageservice.dart';

import '../models/notice.dart';

class FireStoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime time = DateTime.now();

//User Service Methods

  Future<void> createUser({id, email, username, photoUrl = ""}) async {
    _firestore.collection("users").doc(id).set({
      "username": username,
      "email": email,
      "createdTime": time,
      "pphoto": photoUrl,
      "about": ""
    });
  }

  Future<UserLocal?> getUser(id) async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(id).get();
    if (doc.exists) {
      UserLocal user = UserLocal.createUserByDoc(doc);
      print(user.email);
      return user;
    }
    return null;
  }

  Future<void> editUser(
      String id, String username, String pphoto, String about) async {
    await _firestore
        .collection("users")
        .doc(id)
        .update({"pphoto": pphoto, "username": username, "about": about});
  }

  Future<List<UserLocal?>> searchUser(String value) async {
    QuerySnapshot snapshots = await _firestore
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: value)
        .get();

    List<UserLocal> users =
        await snapshots.docs.map((e) => UserLocal.createUserByDoc(e)).toList();

    return users;
  }

//Post Service Methos

  Future<void> createPost(imageUrl, content, publishedById, location) async {
    await _firestore
        .collection("posts")
        .doc(publishedById)
        .collection("usersposts")
        .add({
      "content": content,
      "location": location,
      "postUrl": imageUrl,
      "publishedById": publishedById,
      "likeCount": 0,
      "createdTime": time
    });
  }

  deletePost(String currentUserId, Post post) async {
    //Post delete process
    _firestore
        .collection("posts")
        .doc(currentUserId)
        .collection("usersposts")
        .doc(post.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

//Comments delete process
    QuerySnapshot commentsSnapshot = await _firestore
        .collection("comments")
        .doc(post.id)
        .collection("postcomments")
        .get();

    commentsSnapshot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

//Likes delete process
    QuerySnapshot likesSnapshot = await _firestore
        .collection("likes")
        .doc(post.id)
        .collection("postlikes")
        .get();

    if (likesSnapshot != null) {
      likesSnapshot.docs.forEach((DocumentSnapshot doc) {
        doc.reference.delete();
      });
    }

//Notice delete process
    QuerySnapshot noticeSnapshot = await _firestore
        .collection("notices")
        .doc(post.publishedById)
        .collection("usersnotices")
        .where("postId", isEqualTo: post.id)
        .get();

    if (noticeSnapshot != null) {
      noticeSnapshot.docs.forEach((DocumentSnapshot doc) {
        doc.reference.delete();
      });
    }

    StorageService().postImageDelete(post.postUrl);
  }

  Future<List<Post>> getPosts(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("posts")
        .doc(userId)
        .collection("usersposts")
        .orderBy("createdTime", descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((e) => Post.createPostByDoc(e)).toList();

    return posts;
  }

  Future<Post> getSinglePost(String postId, String publeshedUserId) async {
    DocumentSnapshot snapshot = await _firestore
        .collection("posts")
        .doc(publeshedUserId)
        .collection("usersposts")
        .doc(postId)
        .get();

    Post post = Post.createPostByDoc(snapshot);
    return post;
  }

  Future<void> likePost(Post newPost, String currentUserId) async {
    DocumentSnapshot doc = await _firestore
        .collection("posts")
        .doc(newPost.publishedById)
        .collection("usersposts")
        .doc(newPost.id)
        .get();

    if (doc.exists) {
      Post oldPost = Post.createPostByDoc(doc);

      await _firestore
          .collection("posts")
          .doc(newPost.publishedById)
          .collection("usersposts")
          .doc(newPost.id)
          .update({"likeCount": newPost.likeCount});

      if (oldPost.likeCount >= newPost.likeCount) {
        DocumentSnapshot docLike = await _firestore
            .collection("likes")
            .doc(oldPost.id)
            .collection("postlikes")
            .doc(currentUserId)
            .get();

        if (docLike.exists) {
          docLike.reference.delete();
        }
      } else {
        await _firestore
            .collection("likes")
            .doc(oldPost.id)
            .collection("postlikes")
            .doc(currentUserId)
            .set({});

        //Add Notice
        createNotice(currentUserId, oldPost.publishedById, "like", "", oldPost);
      }
    }
  }

  Future<bool> isLiked(Post post, String currenUserId) async {
    DocumentSnapshot documentSnapshot = await _firestore
        .collection("likes")
        .doc(post.id)
        .collection("postlikes")
        .doc(currenUserId)
        .get();

    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection("comments")
        .doc(postId)
        .collection("postcomments")
        .orderBy("createdTime", descending: true)
        .snapshots();
  }

  createComment(String currentUserId, Post post, String content) {
    _firestore
        .collection("comments")
        .doc(post.id)
        .collection("postcomments")
        .add({
      "content": content,
      "createdTime": time,
      "publishedId": currentUserId
    });

    createNotice(currentUserId, post.publishedById, "comment", content, post);
  }

  Future<int> followerCount(userId) async {
    QuerySnapshot followers = await _firestore
        .collection("followers")
        .doc(userId)
        .collection("usersfollowers")
        .get();

    return followers.docs.length;
  }

  Future<int> followingCount(userId) async {
    QuerySnapshot following = await _firestore
        .collection("following")
        .doc(userId)
        .collection("usersfollowing")
        .get();
    return following.docs.length;
  }

  followTheUser(String activeUserId, String profileUserId) async {
    await _firestore
        .collection("followers")
        .doc(profileUserId)
        .collection("usersfollowers")
        .doc(activeUserId)
        .set({});

    await _firestore
        .collection("following")
        .doc(activeUserId)
        .collection("usersfollowing")
        .doc(profileUserId)
        .set({});

    createNotice(activeUserId, profileUserId, "follow", "", null);
  }

  unfollowTheUser(String activeUserId, String profileUserId) async {
    await _firestore
        .collection("followers")
        .doc(profileUserId)
        .collection("usersfollowers")
        .doc(activeUserId)
        .get()
        .then((DocumentSnapshot follower) {
      if (follower.exists) {
        follower.reference.delete();
      }
    });

    await _firestore
        .collection("following")
        .doc(activeUserId)
        .collection("usersfollowing")
        .doc(profileUserId)
        .get()
        .then((DocumentSnapshot following) {
      if (following.exists) {
        following.reference.delete();
      }
    });
  }

  Future<bool> isFollowing(String activeUserId, String profileUserId) async {
    bool isFollowing = false;

    await _firestore
        .collection("following")
        .doc(activeUserId)
        .collection("usersfollowing")
        .doc(profileUserId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        isFollowing = true;
      }
    });
    return isFollowing;
  }

//Notice Service Methods

  createNotice(String activityUserId, String profileId, String activityType,
      String comment, Post? post) async {
    if (activityUserId != profileId) {
      await _firestore
          .collection("notices")
          .doc(profileId)
          .collection("usersnotices")
          .add({
        "activtyUserId": activityUserId,
        "activtyType": activityType,
        "comment": comment,
        "postId": post != null ? post.id : "",
        "postPhoto": post != null ? post.postUrl : "",
        "createdTime": time
      });
    }
  }

  Future<List<Notice>> getNotices(String profileUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("notices")
        .doc(profileUserId)
        .collection("usersnotices")
        .orderBy("createdTime", descending: true)
        .limit(20)
        .get();

    List<Notice> notices = [];

    snapshot.docs.forEach((element) {
      Notice notice = Notice.createdByDoc(element);
      notices.add(notice);
    });

    return notices;
  }

//Homepage Service Methods

  Future<List<Post>> getHomePagePosts(String followingId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("homepages")
        .doc(followingId)
        .collection("usershomepages")
        .orderBy("createdTime", descending: true)
        .get();

    List<Post> posts =
        snapshot.docs.map((e) => Post.createPostByDoc(e)).toList();
    return posts;
  }
}
