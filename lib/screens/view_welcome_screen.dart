import 'package:flutter/material.dart';
import 'package:recipe_searcher/screens/view_start_suggestion.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recipe_searcher/database/cook_history.dart';
import 'package:recipe_searcher/share/app_storage.dart';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/profile/profile_manager.dart';

/*
A Wizard which init and expains the app
 */

enum ViewWelcomeState {
  INIT,
  ASK_ALPHA_AGREEMENT,
  CHECK_PERMISSION,
  ASK_PERMISSION,
  ERROR_DB_NOT_FOUND,
  LOAD,
  SHOW_HELP
}

class ViewWelcomeScreen extends StatefulWidget {
  ViewWelcomeScreen({Key key}) : super(key: key);

  @override
  _ViewWelcomeScreenState2 createState() => new _ViewWelcomeScreenState2();
}

class _ViewWelcomeScreenState2 extends State<ViewWelcomeScreen> {
  ViewWelcomeState state = ViewWelcomeState.INIT;
  SettingsManager _settings = null;
  Future<bool> _hasStoragePermission = null;
  bool _dontShowAgainHelp = false;
  bool _agreedAlpha = true;
  String appbarTitle = "";
  String databasePath = null;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appbarTitle,
      home: Scaffold(
          appBar: AppBar(
            title: Center(child: Text(appbarTitle)),
          ),
          body: new Container(
              margin:
                  new EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: projectWidget())),
    );
  }

  void init() async {
    _hasStoragePermission = this._hasNeedPermission();
    _settings = SettingsManager.instance;
    await _settings.init();
    if (_settings.agreedAlphaReleaseNote) {
      setStateAskPermission();
    } else {
      this.setState(() {
        appbarTitle = "[CLOSED ALPHA]";
        this.state = ViewWelcomeState.ASK_ALPHA_AGREEMENT;
      });
    }
  }

  Future<void> setStateCheckIfDBExists() async {
    bool dbExist = await RecipeDatabase.instance.checkIfDatabaseExists();
    // Show Error Message if DB is not Found
    if (!dbExist) {
      databasePath = await AppStorage.getPathToRecipeDB();
      setState(() {
        appbarTitle = "Database not found";
        this.state = ViewWelcomeState.ERROR_DB_NOT_FOUND;
      });
    } else {
      appbarTitle = "Please Wait";
      await setStateLoadDB();
    }
  }

  Future<void> setStateLoadDB() async {
    this.state = ViewWelcomeState.LOAD;

    ProfileManager profiles = ProfileManager.instance;
    RecipeDatabase db = RecipeDatabase.instance;
    // ShoppingCartHistory m = ShoppingCartHistory.instance; NOTE init is called from another class
    CookHistory history = CookHistory.instance;

    Future<void> waitForProfiles = profiles.init();
    // Wait till all recipes are loaded before loading the history
    Future<void> waitForRecipes = db.init();
    await waitForRecipes;
    await waitForProfiles;
    Future<void> waitForHistory = history.init();
    await waitForHistory;

    if (_settings.showHelp) {
      setState(() {
        appbarTitle = "About this App";
        state = ViewWelcomeState.SHOW_HELP;
      });
    } else {
      finishWelcomeScreen();
    }
  }

  void finishWelcomeScreen() {
    _settings.save();
    Navigator.pushReplacement(context,
        new MaterialPageRoute(builder: (context) => new StartSuggestion()));
  }

  void setStateAskPermission() async {
    bool hasPermission = await this._hasStoragePermission;
    if (hasPermission) {
      await setStateCheckIfDBExists();
    } else {
      setState(() {
        appbarTitle = "Need Storage Permission";
        this.state = ViewWelcomeState.ASK_PERMISSION;
      });
    }
  }

  Future<bool> _hasNeedPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    return permission == PermissionStatus.granted;
  }

  Widget buildHelp() {
    _settings.setNeedSaving();
    bool dontShowAgain = false;
    String message ="The intention of this app is to be a mobile support for GourmetRecipeManager. A core aspect of this is the planning of shopping, including suggesting dishes, compiling and creating lists of ingredients that can be sent by e-mail.";
    return Column(children: <Widget>[
      Text(message,
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

      Row(children: <Widget>[
        Checkbox(
            value: _dontShowAgainHelp,
            onChanged: (bool value) {
              setState(() {
                _dontShowAgainHelp = value;
              });
            }),
    Flexible(child: Text(" Don't show this again",
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))
      ]),
      RaisedButton(
        child: const Text('Continue'),
        onPressed: () async {
          this._settings.showHelp = !_dontShowAgainHelp;
          this._settings.setNeedSaving();
          finishWelcomeScreen();
        },
      ),
    ]);
  }

  Widget buildLoadState() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Center(
          child: new SizedBox(
            height: 50.0,
            width: 50.0,
            child: new CircularProgressIndicator(
              value: null,
              strokeWidth: 7.0,
            ),
          ),
        ),
        new Container(
          margin: const EdgeInsets.only(top: 25.0),
          child: new Center(
            child: new Text(
              "loading.. wait...",
              style: new TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAskAlphaAgreement() {
    String message =
        "Please do not share this app with other user. It is planned to publish this App as a Free Open Source Software after the closed Alpha Phase is finished. Feel free to contact me for further questions.\n\Best Regards\nPatrick Mispelhorn";
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Text(message,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Row(children: <Widget>[
          Checkbox(
              value: _agreedAlpha,
              onChanged: (bool value) {
                setState(() {
                  _agreedAlpha = value;
                });
              }),
          Flexible(child: Text(" I promise to not share this app",
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))
        ]),
        if (_agreedAlpha)
          RaisedButton(
            child: const Text('Continue'),
            onPressed: () async {
              this._settings.agreedAlphaReleaseNote = true;
              this._settings.setNeedSaving();
              setStateAskPermission();
            },
          ),
      ],
    ));
  }

  Widget buildInitState() {
    return Container();
  }

  Widget buildCheckPermission() {
    return Container(child: Center(child: Text("Check Permission")));
  }

  Widget buildAskPermission() {
    return Column(
      children: <Widget>[
        Text("This app loads the recipe database from the SD card. Storage permission is required for this.",
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        RaisedButton(
            child: const Text('Request Permission'),
            onPressed: () async {
              // Request Permissiom
              Map<PermissionGroup, PermissionStatus> permissions =
              await PermissionHandler()
                  .requestPermissions([PermissionGroup.storage]);
              bool hasPermission = await this._hasNeedPermission();
              if (hasPermission) {
                await setStateCheckIfDBExists();
              }
            }),
      ],
    );
  }

  Widget buildErrorDBNotFound() {
    String message =
        "No recipe database could be found under:\n ${databasePath}\nSimply copy the GourmetRecipeManager's recipes.db to the corresponding folder on the sdcard.";

    return Column(
      children: <Widget>[
        Text(message,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        RaisedButton(
            child: const Text("Check Again"),
            onPressed: () async {
              setStateCheckIfDBExists();
            }),
      ],
    );
  }

  Widget projectWidget() {
    switch (this.state) {
      case (ViewWelcomeState.SHOW_HELP):
        return buildHelp();
      case (ViewWelcomeState.LOAD):
        return buildLoadState();
      case (ViewWelcomeState.ASK_ALPHA_AGREEMENT):
        return buildAskAlphaAgreement();
      case (ViewWelcomeState.INIT):
        return buildInitState();
      case (ViewWelcomeState.ASK_PERMISSION):
        return buildAskPermission();
      case (ViewWelcomeState.CHECK_PERMISSION):
        return buildCheckPermission();
        break;
      case (ViewWelcomeState.ERROR_DB_NOT_FOUND):
        return buildErrorDBNotFound();
      default:
        return Text("Invalid welcome state");
    }
  }
}
