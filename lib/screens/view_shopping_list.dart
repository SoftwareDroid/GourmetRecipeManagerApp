import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:recipe_searcher/core/date_format.dart';
import 'package:recipe_searcher/screens/view_shopping_cart.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_manager.dart';
import 'package:tuple/tuple.dart';
import 'share/drawer.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_entry.dart';

/*
A List of ingredients where the use can check them and send a remaining list via e-mail.
 */

class ViewShoppingList extends StatefulWidget {
  _ViewShoppingListState createState() => _ViewShoppingListState();
}

class _ViewShoppingListState extends State<ViewShoppingList> {
  @override
  void initState() {
    super.initState();
  }

  Map<int, Tuple2<String, bool>> _ingredientsChecklist =
      new Map<int, Tuple2<String, bool>>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: new AppDrawer(), // New Line
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ViewShoppingCart()));},
          ),
          title: new Text('Ingredient Shopping List'),
        ),
        body: projectWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            assert(ShoppingCartManager.instance.getEntries().length == 0);
            final MailOptions mailOptions = MailOptions(
              body: _createMailBody(),
              subject: 'Shopping List ' + MyDateFormat.dmyhmin(DateTime.now()),
              recipients: [SettingsManager.instance.ownerMail],
              isHTML: false,
              attachments: [],
            );
            await FlutterMailer.send(mailOptions);
            await ShoppingCartManager.instance.completeAll();
          },
          child: Icon(Icons.mail),
          backgroundColor: Colors.green,
        ));
  }

  String _createMailBody() {
    String ret = "Recipes: ";
    var list = ShoppingCartManager.instance;
    for (var entry in list.getEntries())
    {
      ret += entry.getScaledRecipeName() + "\n";
    }

    ret += "\n\nIngredients: \n";
    for (int key in this._ingredientsChecklist.keys) {
      Tuple2<String, bool> item = this._ingredientsChecklist[key];
      // Put only check items on the list
      if (!item.item2) {
        ret += item.item1 + "\n";
      }
    }
    ret +="\n\n This Mail was auto created by GourmetFoodPlaner App.";
    return ret;
  }

  Widget projectWidget() {
    var list = ShoppingCartManager.instance;
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var entry in list.getEntries()) _create_recipe(entry),
      ],
    ));
  }

  Widget _create_recipe(ShoppingCartEntry entry) {
    return new Card(
        child: Column(children: <Widget>[
      // Title of the recipe
      new Text(
        entry.getScaledRecipeName(),
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      // The Ingredients
      for (Tuple2<int, String> ingredient in entry.getListOfIngredients())
        _create_ingredient_checkbox(ingredient)
    ]));
  }

  Widget _create_ingredient_checkbox(Tuple2<int, String> ingredient) {
    if (!_ingredientsChecklist.containsKey(ingredient.item1)) {
      _ingredientsChecklist[ingredient.item1] =
          new Tuple2<String, bool>(ingredient.item2, false);
    }

    return CheckboxListTile(
        title: _ingredientsChecklist[ingredient.item1].item2
            ? Text(ingredient.item2,
                style: TextStyle(decoration: TextDecoration.lineThrough))
            : Text(ingredient.item2),
        value: _ingredientsChecklist[ingredient.item1].item2,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool value) {
          setState(() => _ingredientsChecklist[ingredient.item1] =
              new Tuple2<String, bool>(ingredient.item2, value));
        });
  }
}
