import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:movie_it/services/auth_service.dart';

class signUp extends StatefulWidget {
  @override
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 250,
                width: 250,
                child: Image.asset('assets/images/login-logo.png'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Ad',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Email',
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
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
                    String name = _nameController.text;
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    bool isRegisterSuccess = await AuthService()
                        .registerUserWithAuth(
                            email: email, name: name, password: password);
                            
                    if (isRegisterSuccess) {
                      _registeredMessage(context,
                          text: 'Kayıt başarıyla tamamlandı!',
                          color: Colors.green);
                          
                    } else {
                      _registeredMessage(context,
                          text: 'Kayıt tamamlanamadı!', color: Colors.red);
                    }
                  },
                  child: Text('Kayıt Ol'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Flushbar<dynamic> _registeredMessage(BuildContext context,
      {required String text, required Color color}) {
    return Flushbar(
      messageText: Center(
          child: Text(
        text,
        style: TextStyle(color: Colors.white),
      )),
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,
      positionOffset: 30,
      maxWidth: 300,
      borderRadius: BorderRadius.circular(40),
      duration: Duration(seconds: 3),
    )..show(context);
  }
}
