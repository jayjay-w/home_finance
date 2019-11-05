import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/state.dart';
import 'package:homefinance/ui/screens/accounts.dart';
import 'package:homefinance/ui/screens/dashboard.dart';
import 'package:homefinance/ui/screens/receive_money.dart';
import 'package:homefinance/ui/screens/reports.dart';
import 'package:homefinance/ui/screens/send_money.dart';
import 'package:homefinance/ui/screens/transfer_money.dart';
import 'package:homefinance/ui/widgets/appBar.dart';
import 'package:homefinance/util/state_widget.dart';
import 'package:homefinance/ui/screens/sign_in.dart';
import 'package:homefinance/ui/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;
  int _currentTab = 0;

  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
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
                  // CategorySelector(),
                  Expanded(
                      child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)
                        ) //Theme.of(context).accentColor
                      ),
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int index) {
                          setState(() {
                           _currentTab = index; 
                          });
                        },
                        children: <Widget>[
                          DashboardScreen(),
                          ReceiveMoneyScreen(),
                          SendMoneyScreen(),
                          TransferMoneyScreen(),
                          AccountsScreen()
                        ],
                      ),
                    ),
                  )
                ],
              ),
            bottomNavigationBar: CupertinoTabBar(
              currentIndex: _currentTab,
              backgroundColor: Theme.of(context).accentColor,
              onTap: (int index) {
                setState(() {
                 _currentTab = index; 
                });
                _pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.ease);
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home)),
                BottomNavigationBarItem(icon: Icon(Icons.arrow_downward,)),
                BottomNavigationBarItem(icon: Icon(Icons.arrow_upward)),
                BottomNavigationBarItem(icon: Icon(Icons.sync)),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance)),
              ],
            ),
            ),
            inAsyncCall: _loadingVisible),
      );
    }
  }
}
