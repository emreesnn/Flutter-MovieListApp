import 'package:flutter/material.dart';
import 'package:movie_it/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_it/view/sign_up_page.dart';

class signIn extends StatefulWidget {
  @override
  _signInState createState() => _signInState();
}

class _signInState extends State<signIn> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 250,
                width: 250,
                child: Image.asset('assets/images/login-logo.png'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                focusNode: _focusNodeEmail,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                focusNode: _focusNodePassword,
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Şifre',
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  onPressed: () async {
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    await AuthService()
                        .signInWithAuth(email: email, password: password);
                    User? user = _auth.currentUser;
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, "/");
                    }
                  },
                  child: Text(
                    'Giriş Yap',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hesabınız yok mu?'),
                  TextButton(
                      onPressed: () {
                        _focusNodeEmail.unfocus();
                        _focusNodePassword.unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => signUp()),
                        );
                      },
                      child: Text('Kaydol'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
