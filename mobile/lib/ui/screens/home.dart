import 'package:flutter/material.dart';
import 'package:homefinance/models/state.dart';
import 'package:homefinance/ui/widgets/abbBodyContainer.dart';
import 'package:homefinance/ui/widgets/appBar.dart';
import 'package:homefinance/ui/widgets/categorySelector.dart';
import 'package:homefinance/util/state_widget.dart';
import 'package:homefinance/ui/screens/sign_in.dart';
import 'package:homefinance/ui/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return SignInScreen();
    } else {
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }
      
      final userId = appState?.firebaseUserAuth?.uid ?? '';
      final email = appState?.firebaseUserAuth?.email ?? '';
      final firstName = appState?.user?.firstName ?? '';
      final lastName = appState?.user?.lastName ?? '';
      final settingsId = appState?.settings?.settingsId ?? '';


      return Scaffold(
        backgroundColor: Colors.white,
        body: LoadingScreen(
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: makeAppBar(context),
              body: Column(
                children: <Widget>[
                  CategorySelector(),
                  Expanded(
                      child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)
                        ) //Theme.of(context).accentColor
                      ),
                    ),
                  )
                ],
              ),
            ),
            inAsyncCall: _loadingVisible),
      );
    }
  }
}
