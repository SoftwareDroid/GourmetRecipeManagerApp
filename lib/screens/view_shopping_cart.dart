import 'package:flutter/material.dart';
import 'package:recipe_searcher/core/dart_loading_indicator.dart';
import 'package:recipe_searcher/core/date_format.dart';
import 'package:recipe_searcher/core/dialogs.dart';
import 'package:recipe_searcher/screens/view_recipe_detail.dart';
import 'package:recipe_searcher/screens/view_shopping_list.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_manager.dart';
import 'share/drawer.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_entry.dart';

class ViewShoppingCart extends StatefulWidget {
  _ViewShoppingCartState createState() => _ViewShoppingCartState();
}

class _ViewShoppingCartState extends State<ViewShoppingCart> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  final double _thumb_size = 100; // Size of the thumb in every recipe

  var list = ShoppingCartManager.instance;
  @override
  Widget build(BuildContext ctxt) {
    return new Scaffold(
      key: _scaffoldKey,
      drawer: new AppDrawer(), // New Line
      appBar: new AppBar(
        title: new Text('Shopping Cart'),
      ),
      body: projectWidget(ctxt),
      floatingActionButton: list.isEmpty()
          ? null
          : FloatingActionButton(
              onPressed: () {
                // Add your onPressed code here!
                Navigator.pushReplacement(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new ViewShoppingList()));
              },
              child: Icon(Icons.shopping_cart),
              backgroundColor: Colors.green,
            ),
    );
  }

  void completeEntry(ShoppingCartEntry entry) async {
    entry.r.unloadThumb();
    await ShoppingCartManager.instance.completeSingleEntry(entry);
    setState(() {});
    final snackBar =
    SnackBar(content: Text("Recipe " + entry.r.title + " cooked"));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void removeEntry(ShoppingCartEntry entry) async {
    entry.r.unloadThumb();
    // Remove the item from the data source.
    await list.removeEntry(entry);
    // Update GUI
    setState(() {});
    final snackBar =
        SnackBar(content: Text("Recipe " + entry.r.title + " removed"));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _selectDateForEntry(ShoppingCartEntry entry) async {
    DateTime selectedDate = DateTime.now();
    DateTime lastDay = selectedDate.add(new Duration(days: 14));
    DateTime firstDay = selectedDate.add(new Duration(days: -4));
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDay,
        lastDate: lastDay);
    if (picked != null && picked != entry.plannedDate)
      setState(() {
        entry.plannedDate = picked;
      });
  }

  void _scaleEntry(ShoppingCartEntry entry) async {
    int newServings = await simpleDialogAskInteger(
        context,
        "Number of Servings for " + entry.r.title,
        "Servings",
        "",
        1,
        100,
        entry.yields.round());
    // Update GUI only if has value has changed
    if (newServings != entry.yields.round()) {
      setState(() {
        entry.yields = newServings.toDouble();
      });
    }
  }

  void showDetailForEntry(ShoppingCartEntry entry) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ViewRecipeDetail(r: entry.r,scaleFactor: entry.getScaleFactor(),)));
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.check,
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
              Icons.delete,
              color: Colors.white,
              size: 80,
            )
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget buildRecipeCard(ShoppingCartEntry entry) {
    return Center(
      child: Dismissible(
          //background: Container(color: Colors.red),
          key: Key(entry.r.id.toString()),
          background: slideLeftBackground(),
          secondaryBackground: slideRightBackground(),
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // other swipe complete recipe without the need of sending a mail
              completeEntry(entry);
            } else {
              // Swipe remove entry from shopping cart
              removeEntry(entry);
            }
          },
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    leading: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: _thumb_size,
                        minHeight: _thumb_size,
                        maxWidth: _thumb_size,
                        maxHeight: _thumb_size,
                      ),
                      child: loadImage(context, entry.r.getImage(),
                          (_thumb_size / 2).floor(), false),
                    ),
                    title: Text(entry.r.title),
                    onLongPress: () async {
                      showDetailForEntry(entry);
                    },
                    trailing: FittedBox(
                        fit: BoxFit.contain, // otherwise the logo will be tiny
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                          ),
                          tooltip: 'Remove recipe form cart',
                          onPressed: () {
                            removeEntry(entry);
                          },
                        )),
                    subtitle:
                        //TODO fix local
                        new Column(children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: Text(
                              'Planned at ' +
                                  MyDateFormat.dmy(entry.plannedDate),
                              textAlign: TextAlign.left),
                        ),
                      ]),

                      // Servings indicator
                      Row(children: <Widget>[
                        FittedBox(
                          fit:
                              BoxFit.contain, // otherwise the logo will be tiny
                          child: Icon(
                            Icons.restaurant_menu,
                            color: Colors.black,
                            size: 30.0,
                          ),
                        ),
                        Expanded(
                          child: Text(" " + entry.yields.round().toString(),
                              textAlign: TextAlign.left),
                        ),
                      ])
                    ])),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SCALE'),
                        onPressed: () async {
                          await this._scaleEntry(entry);
                        }),
                    FlatButton(
                        child: const Text('SET DATE'),
                        onPressed: () async {
                          await this._selectDateForEntry(entry);
                        }),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Widget projectWidget(BuildContext ctxt) {
    var body = null;
    if (list.isEmpty()) {
      body = Center(
          child: Text('No recipes in shopping cart',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
    } else {
      body = Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        for (ShoppingCartEntry entry in list.getEntries())
          this.buildRecipeCard(entry)
      ]);
    }

    return SingleChildScrollView(
        child: new Container(
            margin: const EdgeInsets.only(
                left: 20.0, right: 20.0, bottom: 50.0, top: 20.0),
            child: body));
  }
}
