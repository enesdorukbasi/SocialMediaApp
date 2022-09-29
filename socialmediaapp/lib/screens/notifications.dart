import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/screens/profile.dart';
import 'package:socialmediaapp/screens/singlepost.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';
import 'package:timeago/timeago.dart' as Timeago;
import '../models/notice.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Notice> _notices = [];
  String _currentUserId = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _currentUserId = Provider.of<AuthenticationService>(context, listen: false)
        .currentUserId
        .toString();
    getNotices();
    Timeago.setLocaleMessages('tr', Timeago.TrMessages());
  }

  Future<void> getNotices() async {
    List<Notice> notices = await FireStoreService().getNotices(_currentUserId);
    if (mounted) {
      setState(() {
        _notices = notices;
        _loading = false;
      });
    }
  }

  showingNotices() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_notices.isEmpty) {
      return Center(child: Text("Hiç Duyurunuz Yok"));
    }

    return RefreshIndicator(
      onRefresh: () => getNotices(),
      child: ListView.builder(
        itemCount: _notices.length,
        itemBuilder: (context, index) {
          Notice? notice = _notices[index];
          return noticeRow(notice);
        },
      ),
    );
  }

  Widget noticeRow(Notice? notice) {
    String message = createdMessage(notice!.activtyType);
    return FutureBuilder(
      future: FireStoreService().getUser(notice.activtyUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: 0);
        }

        UserLocal? activityUser = snapshot.data as UserLocal?;

        return ListTile(
          leading: InkWell(
            child: CircleAvatar(
                backgroundImage: NetworkImage(activityUser!.pphoto)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Profile(profileUserId: activityUser.id),
                  ));
            },
          ),
          title: RichText(
            text: TextSpan(
                text: "${activityUser.username} ",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Profile(profileUserId: activityUser.id),
                        ));
                  },
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: notice.comment == ""
                          ? "$message"
                          : '$message  "${notice.comment}"',
                      style: TextStyle(fontWeight: FontWeight.normal))
                ]),
          ),
          subtitle:
              Text(Timeago.format(notice.createdTime.toDate(), locale: 'tr')),
          trailing:
              showingPost(notice.activtyType, notice.postPhoto, notice.postId),
        );
      },
    );
  }

  createdMessage(String activtyType) {
    if (activtyType == "like") {
      return "gönderini beğendi.";
    } else if (activtyType == "comment") {
      return "gönderine yorum yaptı.";
    } else if (activtyType == "follow") {
      return "seni takip etti.";
    }
    return "";
  }

  showingPost(String activityType, String postPhoto, String postId) {
    if (activityType == "like") {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              SinglePost(postId: postId, publishedUserId: _currentUserId),
        )),
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Image.network(
            postPhoto,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (activityType == "comment") {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              SinglePost(postId: postId, publishedUserId: _currentUserId),
        )),
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Image.network(
            postPhoto,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (activityType == "follow") {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Text(
            "Duyurular",
            style: TextStyle(color: Colors.black),
          )),
      body: showingNotices(),
    );
  }
}
