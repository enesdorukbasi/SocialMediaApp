import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/screens/homepage.dart';
import 'package:socialmediaapp/screens/loginpage.dart';
import 'package:socialmediaapp/services/authservice.dart';

class Authentication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _authenticationService =
        Provider.of<AuthenticationService>(context, listen: false);
    return StreamBuilder<UserLocal?>(
      stream: _authenticationService.stateFollower,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          UserLocal? currentUser = snapshot.data;
          _authenticationService.currentUserId = currentUser!.id;
          print(snapshot.data);
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
