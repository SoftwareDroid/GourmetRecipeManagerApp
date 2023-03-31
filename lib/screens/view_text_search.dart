import 'package:flutter/material.dart';
import 'package:recipe_searcher/core/dialogs.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/profile/profile.dart';
import 'package:recipe_searcher/screens/view_recipe_detail.dart';
import 'package:recipe_searcher/screens/view_shopping_cart.dart';
import 'package:recipe_searcher/search/recipe_fulltext_search.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_manager.dart';
import 'share/drawer.dart';
import '../profile/profile_manager.dart';

/*
The Screen with a textfield, where the user can enter and search for recipes. The search results can be added to the shopping cart.
 */

class ViewTextSearch extends StatefulWidget {
  _ViewTextSearchState createState() => _ViewTextSearchState();
}

enum SearchSettingsPopup { SEARCH_ORDER, RESTRICT_BY_PROFILE }

class _ViewTextSearchState extends State<ViewTextSearch> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _filter = new TextEditingController();
  DateTime _lastTimeEnteredText =
      DateTime.now(); // Used to ignore rebuidling to gui too often
  static const int MIN_PAUSE_OF_INPUT_FOR_REBUILDING_GUI_IN_MS = 1000;
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Search Example');

  List<Recipe> _searchResult = new List<Recipe>();
  Future<List<Recipe>> pendingSearch = null;

  SearchSettings searchSettings = new SearchSettings();

  @override
  void initState() {
    super.initState();
  }

  _ViewTextSearchState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          this.searchSettings.term = "";
        });
      } else {
        this.searchSettings.term = _filter.text;
        this._callbackTextEntered();
      }
    });
  }

  Widget _createAdvancedSearch(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        var list = List<PopupMenuEntry<Object>>();
        list.add(
          PopupMenuItem(
            child: Text(
                "Search By " + convertSortOrderToString(searchSettings.order)),
            value: SearchSettingsPopup.SEARCH_ORDER,
          ),
        );
        list.add(
          PopupMenuDivider(
            height: 10,
          ),
        );
        list.add(
          PopupMenuItem(
            child: searchSettings.profileId == ProfileManager.INVALID_PROFILE_ID
                ? Text(
                    "No Search Profile",
                  )
                : Text("Used Profile " + ProfileManager.instance.profiles[searchSettings.profileId].name),
            value: SearchSettingsPopup.RESTRICT_BY_PROFILE,
          ),
        );
        return list;
      },
      onSelected: (value) async {

        if (value == SearchSettingsPopup.SEARCH_ORDER) {
          List<String> values = new List<String>();
          for (var mode in SortOrder.values) {
            values.add(convertSortOrderToString(mode));
          }

          final String sortOrder = await simpleDialog1ofN(context, "Sort Order",
              values, convertSortOrderToString(this.searchSettings.order));
          if (sortOrder == null) {
            return;
          }
          // Convert String to enum
          this.searchSettings.order = SortOrder.values
              .firstWhere((e) => convertSortOrderToString(e) == sortOrder);
          this._callbackTextEntered();

        } else
          {

            if (value == SearchSettingsPopup.RESTRICT_BY_PROFILE) {
              ProfileManager profileManager = ProfileManager.instance;
              var names = profileManager.getAllProfileNames();
              names.add(ProfileManager.NONE_PROFILE_NAME);
              // The temp Profil isn't editable from this screen
              names.remove(ProfileManager.TMP_PROFIL_NAME);

              if (names.isNotEmpty) {
                final String editProfile = await simpleDialog1ofN(
                    context, "Choose Profile", names, names[0]);
                // Cancelled by user
                if (editProfile == null) {
                  return;
                }
                if (editProfile == ProfileManager.NONE_PROFILE_NAME) {
                  this.searchSettings.profileId = ProfileManager.INVALID_PROFILE_ID;
                  this._callbackTextEntered();

                } else {
                  Profile profile = profileManager.getProfileByName(editProfile);
                  this.searchSettings.profileId = profile.uid;
                  this._callbackTextEntered();
                }
              }
            }
          }

        return;
      },
      icon: Icon(
        Icons.settings,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
      actions: <Widget>[_createAdvancedSearch(context)],
    );
  }

  Widget _buildSearchResultCard(Recipe r) {
    bool isInCard = ShoppingCartManager.instance.hasRecipe(r);

    return Card(
        child: ListTile(
      /* leading: IconButton(
        icon: Icon(Icons.expand_more, color: Colors.blue, size: 40),
        tooltip: 'Details',
        onPressed: () {

        },
      ),*/
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    new ViewRecipeDetail(r: r, scaleFactor: 1.0)));
      },
      title: Text(r.title),
      trailing: isInCard
          ? IconButton(
              icon:
                  Icon(Icons.remove_shopping_cart, color: Colors.red, size: 40),
              tooltip: 'Remove from shopping card',
              onPressed: () async {
                await ShoppingCartManager.instance.removeRecipe(r);
                setState(() {});
              },
            )
          : IconButton(
              icon:
                  Icon(Icons.add_shopping_cart, color: Colors.green, size: 40),
              tooltip: 'Add to shopping card',
              onPressed: () async {
                // TODO we use classic search with the default profile here to update the history
                Profile defaultProfile = ProfileManager.instance
                    .getProfile(ProfileManager.instance.getDefaultProfile());
                //await ClassicSuggestion.instance.accept(r.id, defaultProfile);
                await ShoppingCartManager.instance.addRecipe(r);
                setState(() {});
              },
            ),
    ));
  }

  Widget _createLastSearchResult() {
    if (_searchResult == null || _searchResult.isEmpty) {
      return _createEmptySearchResult();
    }

    return Column(children: <Widget>[
      for (Recipe entry in _searchResult) this._buildSearchResultCard(entry)
    ]);
  }

  Widget _createEmptySearchResult() {
    return Container(
        child: Center(
            child: Text("No Search Result",
                style: TextStyle(fontWeight: FontWeight.bold))));
  }

  Widget _createSearchIndicator() {
    return Container(
        child: Center(
            child:
                Text("Search", style: TextStyle(fontWeight: FontWeight.bold))));
  }

  Widget _buildResultList() {
    // Use last search result if input is empty
    if (pendingSearch == null) {
      return _createLastSearchResult();
    } else {
      return FutureBuilder<List<Recipe>>(
        future: pendingSearch, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
          List<Widget> children;

          if (snapshot.hasData) {
            // Save last search Result
            _searchResult = snapshot.data;
            return _createLastSearchResult();
          } else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new AppDrawer(),
      // New Line
      appBar: _buildBar(context),
      body: Container(
        child: projectWidget(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new ViewShoppingCart()));
        },
        child: Icon(Icons.shopping_cart),
        backgroundColor: Colors.green,
      ),

      resizeToAvoidBottomPadding: false,
    );
  }

  Widget projectWidget(BuildContext ctxt) {
    var body = Column(
        mainAxisSize: MainAxisSize.min, children: <Widget>[_buildResultList()]);

    return SingleChildScrollView(
        child: new Container(
            margin: const EdgeInsets.only(
                left: 20.0, right: 20.0, bottom: 50.0, top: 20.0),
            child: body));
  }

  void _callbackTextEntered() {
    _lastTimeEnteredText = DateTime.now();
    // Release Input after a short period of time
    Future.delayed(
        const Duration(
            milliseconds: MIN_PAUSE_OF_INPUT_FOR_REBUILDING_GUI_IN_MS), () {
      if (DateTime.now().difference(this._lastTimeEnteredText).inMilliseconds >=
          MIN_PAUSE_OF_INPUT_FOR_REBUILDING_GUI_IN_MS) {
        this.searchSettings.term = this._filter.text;
        pendingSearch = RecipeFulltextSearch.search(this.searchSettings);
        setState(() {});
      }
    });
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          autofocus: true,
          style: new TextStyle(color: Colors.white),
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white)),
        );
        _callbackTextEntered();
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Recipe Search');
        _filter.clear();
      }
    });
  }
}
