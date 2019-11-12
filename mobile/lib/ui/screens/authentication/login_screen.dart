import 'package:flutter/material.dart';
import 'package:homefinance/services/auth_service.dart';
import 'package:homefinance/ui/screens/authentication/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      AuthService.loginUser(context, _email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
                child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Home Finance",
                style: TextStyle(fontFamily: 'Roboto', fontSize: 50),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: TextFormField(
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: "Email"),
                          validator: (input) => !input.contains('@') ? 'Enter a valid email' : null,
                          onSaved: (input) => _email = input,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: TextFormField(
                          autocorrect: false,
                          decoration: InputDecoration(labelText: "Password"),
                          validator: (input) => input.length < 4 ? 'Enter a valid password' : null,
                          onSaved: (input) => _password = input,
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: 20,),
                      Container(
                        width: 200,
                        child: FlatButton(
                          onPressed: _submit,
                          color: Colors.lightBlue,
                          child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 24),),
                        ),
                      ),
                       SizedBox(height: 40,),
                      GestureDetector(
                        onTap: () { Navigator.pushNamed(context, UserRegistrationScreen.id); },
                        child: Text(
                          "New User? Click here to register",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}