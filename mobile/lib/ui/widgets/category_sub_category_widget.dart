import 'package:flutter/material.dart';

class CategoryAndSubCategorySelector extends StatefulWidget {
  final String categoryId;
  final String subcategoryId;
  final Function onChanged;


  CategoryAndSubCategorySelector({
      this.subcategoryId, 
      this.categoryId,
      this.onChanged
    });

  @override
  _CategoryAndSubCategorySelectorState createState() => _CategoryAndSubCategorySelectorState();
}

class _CategoryAndSubCategorySelectorState extends State<CategoryAndSubCategorySelector> {

  _showCategorySelector() {
      showDialog(
        context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select a category"),
          );
        }
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {  _showCategorySelector(); } ,
          child: Container(
        decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.1),
                borderRadius: BorderRadius.circular(6)),
        child: Column(
          children: <Widget>[
            Visibility(visible: widget.categoryId == null, child: Center(child: Text("Tap here to select the category/subcategory", textAlign: TextAlign.center,))),
            Visibility(
              visible: widget.categoryId == null,
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(""),),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                      child: Text("Category   ", style: TextStyle(fontSize: 16, color: Colors.purple),),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.1),
                    borderRadius: BorderRadius.circular(6)),
                    child: Text("Sub Category", style: TextStyle(fontSize: 16, color: Colors.purple)),
                  ),
                  Expanded(child: Text(""),),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}