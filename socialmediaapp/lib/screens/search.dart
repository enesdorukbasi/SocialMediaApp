import 'package:flutter/material.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/screens/profile.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchbarController = TextEditingController();
  Future<List<UserLocal?>>? _findUsers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _generateAppBar(),
      body: _findUsers != null ? getFindsUsers() : noSearching(),
    );
  }

  _generateAppBar() {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[100],
      title: TextFormField(
        onFieldSubmitted: (value) async {
          Future<List<UserLocal?>> searching =
              FireStoreService().searchUser(value);
          setState(() {
            _findUsers = searching;
          });
        },
        controller: searchbarController,
        decoration: InputDecoration(
            hintText: "Kullanıcı Ara",
            prefixIcon: Icon(
              Icons.search,
              size: 30,
              color: Colors.black,
            ),
            suffix: IconButton(
                color: Colors.black,
                padding: EdgeInsets.only(top: 10),
                onPressed: () {
                  searchbarController.clear();
                  setState(() {
                    _findUsers = null;
                  });
                },
                icon: Icon(
                  Icons.clear,
                  color: Colors.black,
                )),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.only(bottom: 10)),
      ),
    );
  }

  getFindsUsers() {
    return FutureBuilder<List<UserLocal?>>(
      future: _findUsers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.length == 0) {
          return Center(
            child: Text("Arama Sonucuna İlişkin Bir Kullanıcı Bulunamadı."),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              if (snapshot.data != null) {
                UserLocal? user = snapshot.data![index];
                if (user != null) {
                  return _findUsersRow(user);
                }
              }
              return Center(
                  child:
                      Text("Arama Sonucuna İlişkin Bir Kullanıcı Bulunamadı."));
            },
          );
        }
      },
    );
  }

  _findUsersRow(UserLocal user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(profileUserId: user.id),
            ));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(user.pphoto),
        ),
        title: Text(
          user.username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  noSearching() {
    return Center(
      child: Text("Arama yok"),
    );
  }
}
