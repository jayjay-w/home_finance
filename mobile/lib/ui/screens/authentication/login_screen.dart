import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/services/auth_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/authentication/signup_screen.dart';
import 'package:homefinance/ui/widgets/loading.dart';

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;
    bool _working = false;

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _changeLoadingVisible();
      bool loginSuccess = await AuthService.loginUser(context, _email, _password);
      if (!loginSuccess) {
      _changeLoadingVisible();
        Flushbar(
          duration: Duration(seconds: 5),
          title: "Login Failed",
          message: "Please check your username and password",
        );
      } else {
        _changeLoadingVisible();
      }
    }
  }

  @override
    void initState() {
      super.initState();
    }


  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      body: LoadingScreen(
        child: _showForm(),
      inAsyncCall: _working,
      ),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _working = !_working;
    });
  }

  Widget _showForm() {
    return SingleChildScrollView(
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
                          color: primaryColor,
                          child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 24),),
                        ),
                      ),
                       SizedBox(height: 40,),
                      GestureDetector(
                        onTap: () { Navigator.pushNamed(context, UserRegistrationScreen.id); },
                        child: Text(
                          "New User? Click here to register",
                          style: TextStyle(color: primaryColor),
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      );
  }
}