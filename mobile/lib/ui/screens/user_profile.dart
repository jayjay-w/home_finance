
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

  UserProfileScreen({this.currency, this.userID});

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
        body: FutureBuilder(
          future: usersRef.document(widget.userID).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            User user = User.fromDocument(snapshot.data);
            
            return ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            user.imageURL == null || user.imageURL.isEmpty 
                            ? AssetImage('assets/images/user-placeholder.jpg')
                            : CachedNetworkImageProvider(user.imageURL)
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
                                  builder: (_) => EditProfileScreen(user: user,), )); },
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
                        user.firstName + ' ' + user.lastName, 
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                       user.email,
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
            );
          },
        ));
  }
}