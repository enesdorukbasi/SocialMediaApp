import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';
import 'package:socialmediaapp/widgets/mixinFutureBuilder.dart';
import 'package:socialmediaapp/widgets/postcard.dart';

import '../models/post.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Post> _posts = [];

  _getPosts() async {
    String currentUserId =
        Provider.of<AuthenticationService>(context, listen: false)
            .currentUserId
            .toString();

    List<Post> posts = await FireStoreService().getHomePagePosts(currentUserId);

    if (mounted) {
      setState(() {
        _posts = posts;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getPosts();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "SocialApp",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          Post post = _posts[index];
          return SizedBox(
            height: mediaQuery.size.height - 120,
            width: mediaQuery.size.width,
            child: MixinFutureBuilder(
              future: FireStoreService().getUser(post.publishedById),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                } else {
                  return PostCard(post: post, publishedUser: snapshot.data!);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
