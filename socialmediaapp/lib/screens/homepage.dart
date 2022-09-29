import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/screens/home.dart';
import 'package:socialmediaapp/screens/notifications.dart';
import 'package:socialmediaapp/screens/profile.dart';
import 'package:socialmediaapp/screens/search.dart';
import 'package:socialmediaapp/screens/upload.dart';
import 'package:socialmediaapp/services/authservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activePageNumber = 0;
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId =
        Provider.of<AuthenticationService>(context, listen: false)
            .currentUserId;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activePageNumber,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Akış",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Keşfet",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload),
            label: "Yükle",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Duyurular",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
        selectedItemColor: Theme.of(context).primaryColorDark,
        unselectedItemColor: Colors.grey,
        onTap: (selectedPageNumber) {
          setState(() {
            _activePageNumber = selectedPageNumber;
            pageController!.jumpToPage(selectedPageNumber);
          });
        },
      ),
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Home(),
          Search(),
          Upload(),
          Notifications(),
          Profile(
            profileUserId: currentUserId,
          )
        ],
        onPageChanged: (value) {
          setState(() {
            _activePageNumber = value;
          });
        },
      ),
    );
  }
}
