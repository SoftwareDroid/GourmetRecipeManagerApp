import 'package:flutter/material.dart';

import 'package:recipe_searcher/core/dialogs.dart';
import 'package:recipe_searcher/database/cook_history.dart';
import 'package:recipe_searcher/screens/view_edit_profile.dart';
import 'package:recipe_searcher/screens/view_show_suggestion.dart';
import 'package:recipe_searcher/share/app_storage.dart';
import 'package:recipe_searcher/screens/view_shopping_cart.dart';
import 'package:recipe_searcher/screens/view_text_search.dart';
import 'package:sqflite/sqflite.dart';

import 'share/drawer.dart';
import 'package:flutter/services.dart';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/profile/profile_manager.dart';
import 'package:recipe_searcher/suggestion/classic_suggestion.dart';
import 'package:recipe_searcher/core/dart_loading_indicator.dart';

import 'package:settings_ui/settings_ui.dart';

enum StartSearchState { LOADING, LOADED }

class StartSuggestion extends StatefulWidget {
  StartSuggestion({Key key}) : super(key: key);

  @override
  _StartSuggestionState createState() => new _StartSuggestionState();
}

class _StartSuggestionState extends State<StartSuggestion> {
  StartSearchState state = StartSearchState.LOADED;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext ctxt) {
    return new Scaffold(
        drawer: new AppDrawer(), // New Line
        appBar: new AppBar(
          title: new Text('GourmetFoodPlaner'),
        ),
        body: projectWidget(ctxt));
  }

  Widget _tileSingleDefaultSearch(BuildContext ctxt) {
    return SettingsTile(
      title: 'Single Suggestion (Default Profile)',
      subtitle: 'Profile: ' + getDefaultProfileName(),
      leading: Icon(Icons.person),
      onTap: () async {
        ProfileManager p = ProfileManager.instance;
        await p.save();
        if (p.hasDefaultProfile()) {
          var profile = p.getProfile(p.getDefaultProfile());
          // Change screen
          //Navigator.maybePop(ctxt);
          Navigator.push(
              ctxt,
              new MaterialPageRoute(
                  builder: (context) => new ViewShowSuggestion(profile, 1)));
        } else {
          altertDialog(context, "No default profile",
              "Select a default profile in the settings tag.");
        }
      },
    );
  }

  Widget _singleOtherProfileSearch(BuildContext ctxt) {
    return SettingsTile(
      title: 'Single Suggestion (Other Profile)',
      subtitle: "",
      leading: Icon(Icons.people),
      onTap: () async {
        ProfileManager p = ProfileManager.instance;
        var names = p.getAllProfileNames();
        names.remove(ProfileManager.TMP_PROFIL_NAME);
        assert(names.isNotEmpty);
        String profile = await simpleDialog1ofN(context, "Select Profile",
            names, p.getProfile(p.getDefaultProfile()).name);
        if (profile != null) {
          Navigator.push(
              ctxt,
              new MaterialPageRoute(
                  builder: (context) =>
                      new ViewShowSuggestion(p.getProfileByName(profile), 1)));
        }
      },
    );
  }



  Widget _singleTempProfileSearch(BuildContext ctxt) {
    return SettingsTile(
      title: 'Custom Search',
      subtitle: "Search with a new tempomary profile",
      leading: Icon(Icons.build),
      onTap: () async {
        ProfileManager p = ProfileManager.instance;
        var tempProfile = p.resetTempProfile();
        tempProfile.update();
        // Edit Profile with a Search Button
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    new ViewEditProfile(p: tempProfile, searchCount: 1)));
      },
    );
  }

  Widget _defaultWeekSearch(BuildContext ctxt) {
    int search_count = 3;
    return SettingsTile(
      title: 'Default Weekly Scheduler',
      subtitle: 'Choose ${search_count} with recipes the Profile: ' +
          getDefaultProfileName(),
      leading: Icon(Icons.calendar_today),
      onTap: () async {
        ProfileManager p = ProfileManager.instance;
        await p.save();
        if (p.hasDefaultProfile()) {
          var profile = p.getProfile(p.getDefaultProfile());
          // Change screen
          Navigator.push(
              ctxt,
              new MaterialPageRoute(
                  builder: (context) => new ViewShowSuggestion(profile, search_count)));
        } else {
          altertDialog(ctxt, "No default profile",
              "Select a default profile in the settings tag.");
        }
      },
    );
  }

  Widget _weekPlanningWithOtherProfile(BuildContext ctxt) {
    int search_count = 3;
    return SettingsTile(
      title: 'Weekly Scheduler (Choose Profile)',
      subtitle: 'Choose ${search_count} with a arbitrary profile.',
      leading: Icon(Icons.people),
      onTap: () async {
        ProfileManager p = ProfileManager.instance;
        var names = p.getAllProfileNames();
        names.remove(ProfileManager.TMP_PROFIL_NAME);
        assert(names.isNotEmpty);
        String profileName = await simpleDialog1ofN(context, "Select a Profile",
            names, p.getProfile(p.getDefaultProfile()).name);
        if(profileName != null ) {
          var profile = p.getProfileByName(profileName);
          Navigator.push(
              ctxt,
              new MaterialPageRoute(
                  builder: (context) => new ViewShowSuggestion(profile, search_count)));
        }
      },
    );
  }

  Widget _otherProfileSearch(BuildContext ctxt) {
    int search_count = 3;
    return SettingsTile(
      title: 'Weekly scheduler: Other Profile ',
      subtitle: "'Choose ${search_count} with recipes",
      leading: Icon(Icons.code),
      onTap: () async {
        ProfileManager p = ProfileManager.instance;
        var names = p.getAllProfileNames();
        names.remove(ProfileManager.TMP_PROFIL_NAME);
        assert(names.isNotEmpty);
        String profile = await simpleDialog1ofN(context, "Select Profile",
            names, p.getProfile(p.getDefaultProfile()).name);
        if (profile != null) {
          Navigator.push(
              ctxt,
              new MaterialPageRoute(
                  builder: (context) => new ViewShowSuggestion(
                      p.getProfileByName(profile), search_count)));
        }
      },
    );
  }

  Widget projectWidget(BuildContext ctxt) {
    if (this.state == StartSearchState.LOADING) {
      return bodyProgress;
    }

    return SettingsList(sections: [
      SettingsSection(
        title: 'Single Suggestion',
        tiles: [
          _tileSingleDefaultSearch(ctxt),
          //_fullTextSearch(ctxt),
           _singleOtherProfileSearch(ctxt),
          _singleTempProfileSearch(ctxt),

          /// Custom Search
          ///
        ],
      ),
      SettingsSection(title: 'Several Suggestions', tiles: [
        _defaultWeekSearch(ctxt),
        _weekPlanningWithOtherProfile(ctxt)
      ])
    ]);
  }

  String getDefaultProfileName() {
    return ProfileManager.instance.hasDefaultProfile()
        ? ProfileManager.instance
            .getProfile(ProfileManager.instance.getDefaultProfile())
            .name
        : "";
  }



}
