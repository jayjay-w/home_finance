import 'package:flutter/material.dart';
import 'package:homefinance/services/auth_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/authentication/login_screen.dart';
import 'package:homefinance/ui/widgets/currency_dropdown.dart';

class UserRegistrationScreen extends StatefulWidget {
  static final String id = 'register_screen';
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  String _fName, _lName, _email, _password;
  String _currency = "USD";
  String _currencySymbol = "\$";
  final _formKey = GlobalKey<FormState>();


  _submit() {
     if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      AuthService.registerUser(context, _fName, _lName, _email, _password, _currency, _currencySymbol);
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
                "Income / Expense Tracker",
                textAlign: TextAlign.center,
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
                          decoration: InputDecoration(labelText: "First Name"),
                          validator: (input) => input.length < 2 ? 'Enter a valid name' : null,
                          onSaved: (input) => _fName = input,
                        ),
                      ),
                       Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Last Name"),
                          validator: (input) => input.length < 2 ? 'Enter a valid name' : null,
                          onSaved: (input) => _lName = input,
                        ),
                      ),
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
                        child: CurrencyDropDown(
                          currencyValue: _currency,
                          onChanged: (curr, sym) { setState(() {
                           _currency = curr;
                           _currencySymbol = sym; 
                          }); },                          
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: TextFormField(
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
                          child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 24),),
                        ),
                      ),
                       SizedBox(height: 40,),
                      OutlineButton(
                        splashColor: Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        highlightElevation: 0,
                        borderSide: BorderSide(color: Colors.grey),
                        onPressed: () { Navigator.pushNamed(context, LoginScreen.id); },
                        child: Text(
                          "Already a user? Click here to login",
                          style: TextStyle(color: primaryColor),
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