import 'dart:math';

import 'package:flutter/material.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/screens/recipe_detail/view_recipe_tab_meta_info.dart';
import 'package:recipe_searcher/screens/share/bullet_point.dart';
import 'package:recipe_searcher/screens/view_recipe_detail.dart';
import 'package:recipe_searcher/screens/share/drawer.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_entry.dart';
import 'package:tuple/tuple.dart';

class ViewRecipeDetail extends StatefulWidget {
  final Recipe r;
  final double scaleFactor;

  ViewRecipeDetail({this.r, this.scaleFactor});

  _ViewRecipeDescription createState() =>
      _ViewRecipeDescription(r, scaleFactor);
}

class _ViewRecipeDescription extends State<ViewRecipeDetail> {
  _ViewRecipeDescription(Recipe r, scaleFactor) {
    recipe = ShoppingCartEntry(r: r, yields: r.yields * scaleFactor);
  }
  ShoppingCartEntry recipe;

  @override
  Widget build(BuildContext context) {
    return projectWidget(context);
  }

  Widget projectWidget(BuildContext ctxt) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            drawer: new AppDrawer(), // New Line
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.star)),
                  Tab(icon: Icon(Icons.list)),
                  Tab(icon: Icon(Icons.note)),
                ],
              ),
              title: Text(recipe.r.title),
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: TabBarView(
              children: [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ViewRecipeMetaTab(recipe: recipe.r),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: createIngredientsTab(),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: createInstructionsTab(),
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget createMetaInfoTab() {}

  Widget createInstructionsTab() {
    assert(recipe.r.instructions != null);
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(recipe.r.instructions,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16))
      ],
    ));
  }

  Widget createIngredientsTab() {
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          for (Tuple2<int, String> ingredient in recipe.getListOfIngredients())
            _createIngredientLine(ingredient),
        ]));
  }

  Widget _createIngredientLine(Tuple2<int, String> ingredient) {
    return Row(children: <Widget>[
      new Text(String.fromCharCode(0x2022) + "\t",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      new Text(
      ingredient.item2,
      textAlign: TextAlign.left,
      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
    ),
    ],);

    return ListTile(
      title: new Text(
        ingredient.item2,
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      ),
      leading: Text(String.fromCharCode(0x2022),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}
