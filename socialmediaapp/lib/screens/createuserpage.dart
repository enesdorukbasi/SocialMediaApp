import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/services/authservice.dart';
import 'package:socialmediaapp/services/firestoreservice.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({Key? key}) : super(key: key);

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? username = "", email = "", password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Hesap Oluştur"),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            loading
                ? LinearProgressIndicator()
                : SizedBox(
                    height: 0.0,
                  ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        autocorrect: true,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            hintText: "Kullanıcı Adı Giriniz",
                            labelText: "Kullanıcı Adı :",
                            errorStyle: TextStyle(fontSize: 16),
                            prefixIcon: Icon(Icons.mail)),
                        validator: (value) {
                          if (value == null || value == "") {
                            return "Kullanıcı adı alanı boş bırakılamaz.";
                          } else if (value.trim().length < 3 ||
                              value.trim().length > 12) {
                            return "Kullanıcı adı 3-12 karakter sayısı içermelidir.";
                          } else {}
                        },
                        onSaved: (newValue) {
                          username = newValue;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            hintText: "E-Mail Adresi Giriniz",
                            labelText: "E-Mail :",
                            errorStyle: TextStyle(fontSize: 16),
                            prefixIcon: Icon(Icons.mail)),
                        validator: (value) {
                          if (value == null || value == "") {
                            return "E-Mail alanı boş bırakılamaz.";
                          } else if (!value.contains("@") ||
                              !value.contains(".co")) {
                            return "Bu alan sadece mail kabul etmektedir.";
                          } else {}
                        },
                        onSaved: (newValue) {
                          email = newValue;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: "Şifrenizi Giriniz",
                            errorStyle: TextStyle(fontSize: 16),
                            labelText: "Şifre :",
                            prefixIcon: Icon(Icons.lock)),
                        validator: (value) {
                          if (value == null || value == "") {
                            return "Şifre alanı boş bırakılamaz";
                          } else if (value.trim().length < 5) {
                            return "Minimum 5 karakter olmalıdır.";
                          } else {}
                        },
                        onSaved: (newValue) {
                          password = newValue;
                        },
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          child: Text("Kayıt Ol",
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
                  )),
            )
          ],
        ));
  }

  Future<void> _register() async {
    var _formState = _formKey.currentState;
    final _authenticationService =
        Provider.of<AuthenticationService>(context, listen: false);
    if (_formState!.validate()) {
      _formState.save();
      setState(() {
        loading = true;
      });
      try {
        UserLocal user =
            await _authenticationService.createUserByMail(email, password);
        if (user != null) {
          FireStoreService()
              .createUser(id: user.id, email: user.email, username: username);
        }
        Navigator.pop(context);
      } catch (ex) {
        setState(() {
          loading = false;
        });
        exceptionView(exCode: ex);
      }
    }
  }

  exceptionView({exCode}) {
    String? exMessage;

    if (exCode == "ERROR_INVALID_EMAIL") {
      exMessage = "Girilen mail adresi kullanılıyor";
    }

    SnackBar snackBar = SnackBar(content: Text(exMessage.toString()));
    if (snackBar != null || snackBar != "") {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
