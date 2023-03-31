import 'package:flutter/material.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/profile/profile.dart';
import 'package:recipe_searcher/screens/view_edit_profile.dart';
import 'package:recipe_searcher/screens/view_shopping_cart.dart';
import 'package:recipe_searcher/screens/view_recipe_detail.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:recipe_searcher/suggestion/classic_suggestion.dart';
import 'package:recipe_searcher/core/dart_loading_indicator.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_manager.dart';
import 'package:recipe_searcher/suggestion/decision_stack.dart';
import 'package:recipe_searcher/suggestion/i_suggestion_algorthmn.dart';
import 'package:recipe_searcher/suggestion/random_suggestion.dart';

import 'share/drawer.dart';

/*
TODO Popup Menu by prssing on more vert
Shows the Suggestion Page, where the use can accept or reject a suggestion.
The sugestion is calculated based on the used algorthmn.
 */
class ViewShowSuggestion extends StatefulWidget {
  //final Recipe recipe;
  final Profile profile;
  final int remainingChoices;

  ViewShowSuggestion(this.profile, this.remainingChoices) {
    // Empty all decisions
    DecisionStack.instance.clear();
  }

  _ShowRecipe createState() =>
      _ShowRecipe(profile, remainingChoices, remainingChoices);
}

enum ViewShowSuggestionState { LOADING, LOADED }

class _ShowRecipe extends State<ViewShowSuggestion> {
  ViewShowSuggestionState state = ViewShowSuggestionState.LOADING;
  Recipe recipe; // The suggested recipe
  final Profile profile; // A Profile can be used a prefilter
  int remainingChoices;
  final int maxNumberOfChoices;

  int in_card = ShoppingCartManager.instance
      .getEntries()
      .length; // The number of items in the shopping cart

  List<int> image = null; // Image of the suggestion

  Set<int> tempomaryDisabledRecipes = new Set<int>();

  _ShowRecipe(this.profile, this.maxNumberOfChoices, this.remainingChoices) {}

  @override
  void initState() {
    super.initState();
    assert(remainingChoices > 0);
    tempomaryDisabledRecipes.clear();
    start_search();
  }

  Widget getErrorNoRecipeFound() {
    return new Container(
        margin: const EdgeInsets.only(
            left: 20.0, right: 20.0, bottom: 50.0, top: 20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Flexible(
                      child: new Text(
                    "No recipe was found. Maybe the profile is too strict or the database is empty. Use the build icon to alter the suggestion parameters.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ))
                ]),
          ],
        ));
  }

  void _pressAcceptButton() async {
    // Don't show up this recipe twice
    tempomaryDisabledRecipes.add(recipe.id);

    ClassicSuggestion classicSuggestion = ClassicSuggestion.instance;
    //await classicSuggestion.accept(recipe.id, profile);
    //await ShoppingListManager.instance.addRecipe(recipe);
    DecisionStack.instance.pushDecision(recipe, DecisionType.ACCEPTED);

    remainingChoices--;
    if (remainingChoices > 0) {
      int accepted = DecisionStack.instance.getAcceptedDecisions();
      in_card = ShoppingCartManager.instance.getEntries().length + accepted;
      start_search();
    } else {
      if (recipe != null) {
        recipe.unloadImage();
      }
      await DecisionStack.instance.saveAllDecisions();

      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => new ViewShoppingCart()));
      //Navigator.pop(context);
      //Navigator.push(context,
      //    new MaterialPageRoute(builder: (context) => new ViewShoppingCart()));
    }
  }

  // reject the currently suggestion
  void _pressRejectButton() async {
    // Don't show up this recipe twice
    tempomaryDisabledRecipes.add(recipe.id);
    DecisionStack.instance.pushDecision(recipe, DecisionType.REJECTED);
    if (recipe != null) {
      recipe.unloadImage();
    }

    start_search();
  }

  Widget _createButtons() {
    return new Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red,
                child: IconButton(
                  icon: Icon(
                    Icons.thumb_down,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    await this._pressRejectButton();
                  },
                ),
              ),
              Text("  ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, height: 2, fontSize: 16))
              //Text('Rejected: ${rejected}',style: TextStyle(fontWeight: FontWeight.bold,height: 2,fontSize: 16))
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black12,
                child: IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    await DecisionStack.instance.saveAllDecisions();
                    setState(() {
                      if (recipe != null) {
                        recipe.unloadImage();
                      }
                      Navigator.pushReplacement(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new ViewShoppingCart()));
                    });
                  },
                ),
              ),
              Text('${in_card}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, height: 2, fontSize: 16))
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: IconButton(
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await this._pressAcceptButton();
                  },
                ),
              ),
              if (maxNumberOfChoices > 1)
                Text(
                    'Accepted:  ${DecisionStack.instance.getAcceptedDecisions()} of ${maxNumberOfChoices}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, height: 2, fontSize: 16))
              else
                Text('',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, height: 2, fontSize: 16))
            ],
          ),
        ],
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.add_shopping_cart,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.thumb_down,
              color: Colors.white,
              size: 80,
            )
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget getProjectWidget() {
    if (this.state == ViewShowSuggestionState.LOADING) {
      return bodyProgress;
    }

    if (recipe == null) {
      return getErrorNoRecipeFound();
    }

    return new Container(
      margin: const EdgeInsets.only(
          left: 20.0, right: 20.0, bottom: 50.0, top: 20.0),
      child: Dismissible(
          key: Key(recipe.title),
          background: slideLeftBackground(),
          secondaryBackground: slideRightBackground(),
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              this._pressAcceptButton();
            } else {
              this._pressRejectButton();
            }
          },
          child: new Column(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                    child: Text(
                  recipe.title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                )),
                SizedBox(height: 20),
                Expanded(
                    child: loadImage(context, recipe.getImage(), 200, false)),
                SizedBox(height: 20),
                _createButtons()
              ])),
    );
  }

  // Press Back Button or the Back Icon in the App Bar
  void reverseDecision() {
    if (DecisionStack.instance.isEmpty()) {
      Navigator.of(context).pop();
    } else {
      Decision d = DecisionStack.instance.popDecision();
      final int accepted = DecisionStack.instance.getAcceptedDecisions();
      this.remainingChoices = this.maxNumberOfChoices - accepted;
      this.recipe = d.recipe;
      setState(() {
        state = ViewShowSuggestionState.LOADED;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: new AppDrawer(), // New Line
      appBar: new AppBar(
        leading: DecisionStack.instance.isEmpty() ? null : new IconButton(
          icon: new Icon(Icons.undo, color: Colors.white),
          onPressed: () {
            reverseDecision();
          }

        ),
        title: new Text(this.getScreenTitle()),
      ),

      body: getProjectWidget(),
      floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () async {
                  await DecisionStack.instance.saveAllDecisions();
                  Navigator.pushReplacement(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ViewEditProfile(
                              searchCount: this.remainingChoices, p: profile)));
                },
                child: Icon(Icons.settings),
                backgroundColor: Colors.green,
                heroTag: null,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) =>
                              new ViewRecipeDetail(r: recipe,scaleFactor: 1.0)));
                },
                child: Icon(Icons.note),
                backgroundColor: Colors.green,
                heroTag: null,
              )
            ],
          )),
    );
  }

  String getScreenTitle() {
    if (state == ViewShowSuggestionState.LOADING) {
      return "Create Suggestion";
    }
    else {
      return "Recipe Suggestion";
    }
  }

  // Start a new search with a loading indicator
  void start_search() async {
    setState(() {
      state = ViewShowSuggestionState.LOADING;
    });

    ISuggestionAlgorthmn suggestionAlgo =
        SettingsManager.instance.suggestionAlgo == ISuggestionAlgorthmn.Classic
            ? ClassicSuggestion.instance
            : RandomSuggestion.instance;
    if (recipe != null) print("Old Recipe: " + recipe.title);
    if (recipe != null) {
      recipe.unloadImage();
    }
    // Create a new suggestion
    Recipe r = await suggestionAlgo.createSuggestion(profile, tempomaryDisabledRecipes);

    this.recipe = r;
    setState(() {
      state = ViewShowSuggestionState.LOADED;
    });
  }
}
