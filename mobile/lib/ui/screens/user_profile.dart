
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/auth_service.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/user_profile_edit.dart';

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
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            widget.user.imageURL == null || widget.user.imageURL.isEmpty 
                            ? AssetImage('assets/images/user-placeholder.jpg')
                            : CachedNetworkImageProvider(widget.user.imageURL)
                            , 
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      "0",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "Accounts",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black54),
                                    )
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      "0",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "Income",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black54),
                                    )
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      "0",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "Expenses",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black54),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Container(
                              width: 150,
                              child: FlatButton(
                                color: primaryColor,
                                textColor: Colors.white,
                                child: Text(
                                  "Edit Profile",
                                  style: TextStyle(fontSize: 18),
                                ),
                                onPressed: () { Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(user: widget.user,), )); },
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
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