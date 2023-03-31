import 'package:flutter/material.dart';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/screens/view_shopping_cart.dart';
import 'package:recipe_searcher/screens/view_text_search.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_manager.dart';
import '../view_settings.dart';
import '../view_start_suggestion.dart';
import '../../profile/profile_manager.dart';
import 'package:recipe_searcher/suggestion/decision_stack.dart';

/**
 * A drawer menn which allow to jump to different screens in the app.
 * Settings and other stuff is saved to disk by using the drawer
 */
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext ctxt) {
    return new Drawer(
        child: new ListView(
      children: <Widget>[
        new DrawerHeader(
          child: new Text("Menu"),
          decoration: new BoxDecoration(color: Colors.blue),
        ),
        new ListTile(
          title: new Text("Suggestion"),
          leading: Icon(Icons.assessment),
          onTap: () {
            save();
            //Navigator.pop(ctxt);
           // Navigator.push(ctxt,
            //    new MaterialPageRoute(builder: (ctxt) => new StartSuggestion()));
            Navigator.pushReplacement(ctxt,
                new MaterialPageRoute(builder: (context) => new StartSuggestion()));

          },
        ),
        new ListTile(
          title: new Text("Search"),
          leading: Icon(Icons.search),
          onTap: () {
            save();
          //  Navigator.pop(ctxt);
            //Navigator.push(ctxt,
             //   new MaterialPageRoute(builder: (ctxt) => new ViewTextSearch()));
            Navigator.pushReplacement(ctxt,
                new MaterialPageRoute(builder: (context) => new ViewTextSearch()));
          },
        ),

        new ListTile(
          leading: Icon(Icons.shopping_cart),
          trailing: getIconNumberOfItemsInCart(),
          title: new Text("Shopping cart"),
          onTap: () {
            save();
           // Navigator.pop(ctxt);
           // Navigator.push(ctxt,
             //   new MaterialPageRoute(builder: (ctxt) => new ViewShoppingCart()));
            Navigator.pushReplacement(ctxt,
                new MaterialPageRoute(builder: (context) => new ViewShoppingCart()));
          },
        ),
        new ListTile(
          leading: Icon(Icons.settings),
          title: new Text("Settings"),
          onTap: () {
            save();
           // Navigator.pop(ctxt);
           // Navigator.push(
            //    ctxt, new MaterialPageRoute(builder: (ctxt) => new ViewSettings()));
            Navigator.pushReplacement(ctxt,
                new MaterialPageRoute(builder: (context) => new ViewSettings()));
          },
        ),
        /*new ListTile(
              title: new Text("Statistic"),
              onTap: () {
                save();
                Navigator.pop(ctxt);
                Navigator.push(ctxt,
                    new MaterialPageRoute(builder: (ctxt) => new Settings()));
              },
            ),*/
      ],
    ));
  }

  Widget getIconNumberOfItemsInCart() {
    int itemsOnList = ShoppingCartManager.instance.getEntries().length;

    return ClipOval(
        child: Material(
      color: itemsOnList == 0 ? Colors.red : Colors.lightGreen, // button color
      child: SizedBox(
        width: 30,
        height: 30,
        child: Center(
            child: Text(itemsOnList.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))),
      ),
    ));
  }

  void save() async{
    // Save all Decision ist is like save session
    await DecisionStack.instance.saveAllDecisions();
    // Save all profiles
    var profileManager = ProfileManager.instance;
    profileManager.save();
    // Save all Settings
    SettingsManager.instance.save();
    // Unload all Images
    RecipeDatabase.instance.unloadAllImages();
  }
}
