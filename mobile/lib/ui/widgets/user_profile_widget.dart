import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/user_profile_edit.dart';

class UserProfileWidget extends StatefulWidget {
  final User user;
  UserProfileWidget({this.user});
  @override
  _UserProfileWidgetState createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                );
  }
}