import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/post.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/screens/editprofile.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';
import 'package:socialmediaapp/widgets/postcard.dart';

class Profile extends StatefulWidget {
  final String? profileUserId;

  const Profile({super.key, required this.profileUserId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  int currentPageIndex = 0;

  bool _isFollowing = false;

  List<Post> _posts = [];
  UserLocal? profileUser;
  String _currentUserId = "";

  _getFollowerCount() async {
    int followerCount =
        await FireStoreService().followerCount(widget.profileUserId);
    if (mounted) {
      setState(() {
        _followerCount = followerCount;
      });
    }
  }

  _getFollowingCount() async {
    int followingCount =
        await FireStoreService().followingCount(widget.profileUserId);
    if (mounted) {
      setState(() {
        _followingCount = followingCount;
      });
    }
  }

  _getPosts() async {
    List<Post> posts = await FireStoreService().getPosts(widget.profileUserId);
    if (mounted) {
      setState(() {
        _posts = posts;
        _postCount = posts.length;
      });
    }
  }

  _isFollowingControl() async {
    bool control = await FireStoreService()
        .isFollowing(_currentUserId, widget.profileUserId!);
    setState(() {
      _isFollowing = control;
    });
  }

  _followTheUser() async {
    await FireStoreService()
        .followTheUser(_currentUserId, widget.profileUserId!);
  }

  _unfollowTheUser() async {
    await FireStoreService()
        .unfollowTheUser(_currentUserId, widget.profileUserId!);
  }

  @override
  void initState() {
    super.initState();
    _getFollowerCount();
    _getFollowingCount();
    _getPosts();
    _currentUserId = Provider.of<AuthenticationService>(context, listen: false)
        .currentUserId
        .toString();
    _isFollowingControl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          widget.profileUserId == _currentUserId
              ? IconButton(
                  onPressed: _signOut,
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.black,
                  ))
              : SizedBox(height: 0)
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<UserLocal?>(
          future: FireStoreService().getUser(widget.profileUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            profileUser = snapshot.data;
            return ListView(children: [
              _profileDetails(snapshot.data),
              NavigationBar(
                  height: 50,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  onDestinationSelected: (int index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                  },
                  selectedIndex: currentPageIndex,
                  destinations: [
                    NavigationDestination(
                        icon: Icon(Icons.grid_view_rounded), label: ""),
                    NavigationDestination(
                        icon: Icon(Icons.view_list_sharp), label: "")
                  ]),
              currentPageIndex == 0 ? _gridPosts() : _listPosts(snapshot.data!),
            ]);
          }),
    );
  }

  _gridPosts() {
    List<GridTile> grids = [];
    _posts.forEach((element) {
      grids.add(_createGrid(element));
    });

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      children: grids,
    );
  }

  _listPosts(UserLocal? user) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: _posts[index],
          publishedUser: user!,
        );
      },
    );
  }

  GridTile _createGrid(Post post) {
    return GridTile(
        child: Image.network(
      post.postUrl,
      fit: BoxFit.fill,
    ));
  }

  Widget _profileDetails(UserLocal? userLocal) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 50,
                backgroundImage: _showingProfilePhoto(userLocal),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialCounter("Gönderi", _postCount),
                    _socialCounter("Takipçi", _followerCount),
                    _socialCounter("Takip Edilen", _followingCount)
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Text(
            userLocal!.username,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            userLocal.about,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          widget.profileUserId == _currentUserId
              ? _editProfileButton()
              : _FollowButtons()
        ],
      ),
    );
  }

  Widget _FollowButtons() {
    if (_isFollowing == true) {
      return Container(
          width: double.infinity,
          child: TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
            child: Text(
              "Takipten Çık",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await _unfollowTheUser();
              int followerCount =
                  await FireStoreService().followerCount(widget.profileUserId);
              setState(() {
                _isFollowingControl();
                _followerCount = followerCount;
              });
            },
          ));
    } else {
      return Container(
          width: double.infinity,
          child: TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
            child: Text(
              "Takip Et",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await _followTheUser();
              int followerCount =
                  await FireStoreService().followerCount(widget.profileUserId);

              setState(() {
                _isFollowingControl();
                _followerCount = followerCount;
              });
            },
          ));
    }
  }

  Container _editProfileButton() {
    return Container(
        width: double.infinity,
        child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(user: profileUser),
                  ));
            },
            child: Text(
              "Profili Düzenle",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )));
  }

  ImageProvider<Object>? _showingProfilePhoto(UserLocal? userLocal) {
    if (userLocal!.pphoto.isEmpty) {
      return NetworkImage(
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"); //AssetImage("assets/images/nullprofile.png");
    } else {
      return NetworkImage(userLocal.pphoto);
    }
  }

  Widget _socialCounter(String title, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(fontSize: 13.0),
        ),
      ],
    );
  }

  void _signOut() {
    Provider.of<AuthenticationService>(context, listen: false).signOut();
  }
}
