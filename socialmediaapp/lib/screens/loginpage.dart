import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/screens/createuserpage.dart';
import 'package:socialmediaapp/screens/forgotmypassword.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  String? email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            _pageElements(),
            _loadingAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _loadingAnimation() {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Center();
    }
  }

  Form _pageElements() {
    return Form(
      key: _formKey,
      child: ListView(
          padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 60.0),
          children: [
            FlutterLogo(
              size: 90.0,
            ),
            SizedBox(
              height: 80.0,
            ),
            TextFormField(
                validator: (value) {
                  if (value == null || value == "") {
                    return "Boş değer girilemez.";
                  } else if (!value.contains("@") || !value.contains(".co")) {
                    return "Mail adresi girilmesi gerekiyor.";
                  }
                },
                onSaved: (newValue) => email = newValue,
                autocorrect: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: "E-Mail Adresinizi Girin",
                    prefixIcon: Icon(Icons.mail),
                    errorStyle: TextStyle(
                      fontSize: 16,
                    ))),
            SizedBox(
              height: 30.0,
            ),
            TextFormField(
              validator: (value) {
                if (value == null || value == "") {
                  return "Boş değer girilemez.";
                } else if (value.trim().length < 5) {
                  return "Minimum 5 karakter olmalıdır.";
                }
              },
              onSaved: (newValue) => password = newValue,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "Şifrenizi Girin",
                  prefixIcon: Icon(Icons.lock),
                  errorStyle: TextStyle(
                    fontSize: 16,
                  )),
            ),
            SizedBox(
              height: 40.0,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreateUserPage(),
                    )),
                    child: Text("Hesap Oluştur",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue[800])),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _logIn,
                    child: Text("Giriş Yap",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue[900])),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(child: Text("Veya")),
            SizedBox(
              height: 20.0,
            ),
            Center(
                child: InkWell(
              child: Text(
                "Google İle Giriş Yap",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
              onTap: _googleSignIn,
            )),
            SizedBox(
              height: 20.0,
            ),
            Center(
                child: InkWell(
              child: Text("Şifremi Unuttum"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ForgotMyPassword()));
              },
            )),
          ]),
    );
  }

  Future<void> _logIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final _authService =
          Provider.of<AuthenticationService>(context, listen: false);
      setState(() {
        loading = true;
      });
      try {
        await _authService.loginUserByMail(email, password);
      } catch (ex) {
        setState(() {
          loading = false;
        });
        errorView(exCode: ex);
      }
    }
  }

  Future<void> _googleSignIn() async {
    var _authenticationService =
        Provider.of<AuthenticationService>(context, listen: false);
    setState(() {
      loading = true;
    });
    try {
      UserLocal userLocal = await _authenticationService.loginWithGoogle();
      if (userLocal != null) {
        UserLocal? firestoreUser =
            await FireStoreService().getUser(userLocal.id);
        if (firestoreUser != null) {
          FireStoreService().createUser(
              id: userLocal.id,
              email: userLocal.email,
              username: userLocal.username,
              photoUrl: userLocal.pphoto);
        }
      }
    } catch (ex) {
      setState(() {
        loading = false;
      });
    }
  }

  errorView({exCode}) {
    String errorMessage = "";
    print(exCode.runtimeType);

    if (exCode == "invalid-email") {
      errorMessage = "E-Mail geçerli değil.";
    } else if (exCode == "user-disabled") {
      errorMessage = "Geçersiz kullanıcı.";
    } else if (exCode == "user-not-found") {
      errorMessage = "Kullanıcı bulunamadı.";
    } else if (exCode == "wrong-password") {
      errorMessage = "Şifre yanlış.";
    }

    var snackBar = SnackBar(content: Text(errorMessage.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
