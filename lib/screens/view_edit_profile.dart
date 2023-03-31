import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:recipe_searcher/profile/profile_manager.dart';
import 'package:recipe_searcher/screens/view_show_suggestion.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:recipe_searcher/core/duration_format.dart';
import 'package:settings_ui/settings_ui.dart';
import 'share/drawer.dart';
import '../core/dialogs.dart';
import '../profile/profile.dart';

/*
Edit the Parameters of a suggestion profile

 */

class ViewEditProfile extends StatefulWidget {
  final Profile p;
  final int searchCount;

  ViewEditProfile({this.p,this.searchCount});

  _ViewEditProfile createState() => _ViewEditProfile(p,searchCount);
}

class _ViewEditProfile extends State<ViewEditProfile> {
  _ViewEditProfile(Profile p, searchCount)  {
    this.profile = p;
    this.searchCount = searchCount;
  }

  Profile profile;
  int searchCount;


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: new AppDrawer(), // New Line
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: new Text(profile.name == ProfileManager.TMP_PROFIL_NAME ? "Temporary Profile": 'Edit Profile: ' + profile.name),
        ),
        body: buildBody(),
        floatingActionButton: searchCount == 0 ? null : FloatingActionButton(
          onPressed: () async {
            Navigator.pop(context);
            // NOTE Quick Search for Recipes
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) =>
                    new ViewShowSuggestion(profile, 1)));
          },
          child: Icon(Icons.search),
          backgroundColor: Colors.green,
        )

    );
  }



  Widget _buildKeywordsSection() {


    return SettingsSection(title: 'Keyword Filter', tiles: [
      SettingsTile(
        title: 'Diet',
        subtitle: profile.vegMode.toString(),
        leading: Icon(Icons.local_florist),
        onTap: () async {
          List<String> tags = new List<String>();
          for (var mode in VegMode.values) {
            tags.add(vegModeToString(mode));
          }

          final String vegMode = await simpleDialog1ofN(context,
              "Choose your diet", tags, vegModeToString(VegMode.All));
          if (vegMode == Null) {
            return;
          }

          // Convert String to enum
          setState(() {
            profile.vegMode = VegMode.values
                .firstWhere((e) => vegModeToString(e) == vegMode);
            ProfileManager.instance.setNeedSaving();
          });
        },
      ),

      SettingsTile(
        title: 'Must have Tags',
        subtitle: convertTagsToString(profile.whitelist_tags),
        leading: Icon(Icons.assignment),
        onTap: () async {
          var tags = await simpleDialogNofM(
              context, "Must have Tags", profile.whitelist_tags);
          if (tags == null) {
            return;
          }
          setState(() {
            profile.whitelist_tags = tags;
            ProfileManager.instance.setNeedSaving();
          });
        },
      ),
      SettingsTile(
        title: 'Forbidden Tags',
        subtitle: convertTagsToString(profile.blacklist_tags),
        leading: Icon(Icons.assignment),
        onTap: () async {
          var allTags = profile.blacklist_tags;

          var tags = await simpleDialogNofM(
              context, "Blacklist Tags",allTags );
          if (tags == null) {
            return;
          }
          setState(() {
            profile.blacklist_tags = tags;
            ProfileManager.instance.setNeedSaving();
          });
        },
      ),
      if(profile.vegMode == VegMode.All)
        _buildMeatModeTile(),
      // Favorite Tag




    ]);
  }

  Widget _buildMeatModeTile() {
   return SettingsTile(
      title: 'Meat Mode',
      subtitle: meatModeToString(profile.meatMode),
      leading: Icon(Icons.pets),
      onTap: () async {
        List<String> values = new List<String>();
        for (String s in MeatMode.keys) {
          values.add(meatModeToString(s));
        }
        // Show Dialog
        final String mode = await simpleDialog1ofN(
            context, 'Meat Mode', values, meatModeToString("DontCare"));
        if (mode == null) {
          return;
        }
        // Convert String to enum
        setState(() {
          for (String s in MeatMode.keys) {
            if (meatModeToString(s) == mode) {
              profile.meatMode = s;
              ProfileManager.instance.setNeedSaving();
            }
          }
        });
      },
    );
  }

  Widget _buildCommonSection() {
    return SettingsSection(
      title: 'Common',
      tiles: [
        SettingsTile(
          title: 'Name',
          subtitle: profile.name == ProfileManager.TMP_PROFIL_NAME ? "Temporary Profile" : profile.name ,
          leading: Icon(Icons.title),
          onTap: () async {
          },
        ),

        SettingsTile(
          title: 'Maximum Cooking Time',
          subtitle: DurationFormat.toHMM(profile.maxTime),
          leading: Icon(Icons.access_time),
          onTap: () async {
            Duration resultingDuration = await showDurationPicker(
              context: context,
              initialTime: profile.maxTime,
              snapToMins: 10,
            );

            if(resultingDuration != null && profile.maxTime != resultingDuration) {
              this.setState(() {profile.maxTime = resultingDuration; });
              ProfileManager.instance.setNeedSaving();
            }


          },
        ),


        SettingsTile(
            title: 'Cuisine',
            subtitle: convertTagsToString(this.profile.whitelist_cuisines),
            leading: Icon(Icons.public),
            onTap: () async {
              var cuisines = await simpleDialogNofM(context,
                  "Choose Cuisines", this.profile.whitelist_cuisines);
              if (cuisines == null) {
                return;
              }
              setState(() {
                this.profile.whitelist_cuisines = cuisines;
                ProfileManager.instance.setNeedSaving();
              });
            }),
        SettingsTile(
            title: 'Dish Types',
            subtitle: convertTagsToString(this.profile.dish_types),
            leading: Icon(Icons.local_dining),
            onTap: () async {
              var types = await simpleDialogNofM(
                  context, "Choose Dish Types", this.profile.dish_types);
              if (types == null) {
                return;
              }
              setState(() {
                this.profile.dish_types = types;
                ProfileManager.instance.setNeedSaving();
              });
            })

        // TODO Dish Type, Name of Profile + is Default (Only Text änderbar in den Einstellunge), Meat every k-dish, Cuisine
      ],
    );
  }

  Widget buildBody() {
    return SettingsList(
      sections: [

        _buildCommonSection(),
        if (SettingsManager.instance.areKeywordsEnabled())
          _buildKeywordsSection(),
      ],
    );
  }

  String convertTagsToString(Map<String, bool> tags) {
    String ret = "";
    bool first = true;
    for (String key in tags.keys) {
      if (tags[key]) {
        if (!first) {
          ret += ", ";
        }
        ret += key;
        first = false;
      }
    }
    return ret;
  }
}
