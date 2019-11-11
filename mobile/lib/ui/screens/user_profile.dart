
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/ui/screens/user_profile_edit.dart';
import 'package:homefinance/util/auth.dart';
import 'package:homefinance/util/state_widget.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  UserProfileScreen({this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
      ),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: usersRef.document(widget.userId).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print('Loaded user ' + widget.userId);
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
                                color: Colors.blue,
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
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: Text("Log Out"),
                                onPressed: () { StateWidget.of(context).logOutUser(); Navigator.pushNamed(context, '/signin'); },
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