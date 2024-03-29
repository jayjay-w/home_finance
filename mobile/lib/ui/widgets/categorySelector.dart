import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {

  int selectedIndex  = 0;

  final List<String> categories = ['Dashboard', 'Accounts', 'Income', 'Expenses', 'Bills', 'Budget', 'Reports', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
                      child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 30
              ) ,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: index == selectedIndex ? Colors.white : Colors.white60,
                  fontWeight: index == selectedIndex ? FontWeight.bold : FontWeight.normal,
                  fontSize: 24
                ),
                ),
            ),
          );
        },
      ),
    );
  }
}