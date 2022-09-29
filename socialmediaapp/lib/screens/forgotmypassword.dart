import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/userlocal.dart';
import '../services/authservice.dart';
import '../services/firestoreservice.dart';

class ForgotMyPassword extends StatefulWidget {
  const ForgotMyPassword({Key? key}) : super(key: key);

  @override
  State<ForgotMyPassword> createState() => _ForgotMyPasswordState();
}

class _ForgotMyPasswordState extends State<ForgotMyPassword> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Şifre Sıfırla"),
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
                        height: 50.0,
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _forgotPassword,
                          child: Text("Sıfırla",
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

  Future<void> _forgotPassword() async {
    var _formState = _formKey.currentState;
    final _authenticationService =
        Provider.of<AuthenticationService>(context, listen: false);
    if (_formState!.validate()) {
      _formState.save();
      setState(() {
        loading = true;
      });
      try {
        await _authenticationService.ForgotMyPassword(email!);
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
