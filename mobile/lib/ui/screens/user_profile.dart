
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/auth_service.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/user_profile_edit.dart';
import 'package:homefinance/ui/widgets/user_profile_widget.dart';

class UserProfileScreen extends StatefulWidget {
 static final String id = "income";
  final String currency;
  final String userID;
  User user;

  UserProfileScreen({this.currency, this.userID, this.user});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("User Profile"),
      ),
        backgroundColor: Colors.white,
        body: ListView(
              children: <Widget>[
                UserProfileWidget(user: widget.user),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.user.firstName + ' ' + widget.user.lastName, 
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                       widget.user.email,
                        style: TextStyle(fontSize: 15),
                      ),
                      Divider(),
                            Center(
                              child: FlatButton(
                                color: primaryColor,
                                textColor: Colors.white,
                                child: Text("Log Out"),
                                onPressed: () { AuthService.logOutUser(context); Navigator.pushNamed(context, '/'); },
                              ),
                            )
                    ],
                  ),
                )
              ],
            ),
        );
  }
}