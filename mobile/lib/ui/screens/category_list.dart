import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/category.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/subcategory_list.dart';
import 'package:homefinance/ui/widgets/common_widgets.dart';

class CategoryListScreen extends StatefulWidget {
   static String id = "category_list_screen";
  final String currency;
  final String userID;

  CategoryListScreen({@required this.currency, this.userID});
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String _editCategoryName;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _editCategoryName = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Categories"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showEditCategoryDialog(true, null, context, widget.userID);
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoryRef.where('owner', isEqualTo: widget.userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) { return Center(child: CircularProgressIndicator(),); }
          return _buildList(context, snapshot.data.documents);
        },
      ),
    );
  }

   Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {    
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
              children: snapshot.map((data) => _buildListItem(context, data)).toList(),
          ),
        ),
      ],
    );
  }

  

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final cat = Category.fromDocument(data);
    return  ListTile(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => SubCategoryListScreen(userID: widget.userID, currency: widget.currency, parentCategory: cat),
                                    ));
      },
      title: Text(cat.name),
      subtitle: StreamBuilder<QuerySnapshot> (
          stream: subCategoryRef.where('categoryId', isEqualTo: cat.id).snapshots(),
          builder: (context, snapshot) {
            int subCategoryCount = 0;
            if (snapshot.hasData) {
              subCategoryCount = snapshot.data.documents.length;
            }                            
            return Text("$subCategoryCount subcategories");
          },
        ),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () { showEditCategoryDialog(false, cat, context, widget.userID); },
      ),
    );    
  }
}