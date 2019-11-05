import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 20, left: 16, right: 10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("November 2019", textAlign: TextAlign.center,  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24),),
          ),
          dashboardListWidget("Expenses", "Kes 102,328.00", Icons.arrow_downward, Colors.red),
          dashboardListWidget("Income", "Kes 163,000.00", Icons.arrow_upward, Colors.green),
          dashboardListWidget("Bills", "Kes 93,452.00", Icons.payment, Colors.blue),
          dashboardListWidget("Budget", "Kes 96,109.00", Icons.queue_play_next, Colors.black),
          dashboardListWidget("Accounts", "Kes 3,239,008.00", Icons.account_box, Colors.green),
          dashboardListWidget("Transfers", "Kes 0.00", Icons.refresh, Colors.indigo),
          
        ],
      ),
    );
  }


  Widget dashboardListWidget(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.1),
          borderRadius: BorderRadius.circular(6)
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: color, size: 36,),
            Expanded(
              child: 
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 12),
                child: Text(
                  title, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32), 
                  ),
              ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(value, style: TextStyle(color: color, fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(Icons.arrow_right, size: 32),
            )
          ],
        ),
      ),
    );
  }
}