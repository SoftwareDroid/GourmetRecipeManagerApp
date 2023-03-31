import 'package:f_logs/f_logs.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/material.dart';
import 'package:recipe_searcher/core/date_format.dart';
import 'package:recipe_searcher/database/cook_history.dart';
import 'package:recipe_searcher/profile/profile.dart';
import 'package:recipe_searcher/screens/view_edit_profile.dart';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/profile/profile_manager.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:recipe_searcher/suggestion/i_suggestion_algorthmn.dart';
import 'package:settings_ui/settings_ui.dart';
import 'share/drawer.dart';
import '../core/dialogs.dart';
import 'package:recipe_searcher/share/app_storage.dart';
import 'package:flutter_mailer/flutter_mailer.dart';

/**
 * The global settings of the app
 *
 */

class ViewSettings extends StatefulWidget {
  _ViewSettingsState createState() => _ViewSettingsState();
}

class _ViewSettingsState extends State<ViewSettings> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //String _dbFile = "aa";
  String mail = "";
  String _folder_on_sdcard = "";
  String _default_profile_name = ProfileManager.instance.hasDefaultProfile()
      ? ProfileManager.instance
          .getProfile(ProfileManager.instance.getDefaultProfile())
          .name
      : "";

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        drawer: new AppDrawer(), // New Line
        appBar: new AppBar(
          title: new Text('Settings'),
        ),
        body: projectWidget());
  }

  Widget _tileSelectDefaultProfile() {
    return SettingsTile(
      title: 'Select Default Profile',
      subtitle: _default_profile_name,
      leading: Icon(Icons.link),
      onTap: () async {
        ProfileManager profileManager = ProfileManager.instance;

        var names = profileManager.getAllProfileNames();

        if (names.isNotEmpty) {
          String defaultProfileName = names[0];
          if (profileManager.hasDefaultProfile()) {
            defaultProfileName = profileManager
                .getProfile(profileManager.getDefaultProfile())
                .name;
          }

          final String defaultProfile = await simpleDialog1ofN(
              context, "Select default profile", names, names[0]);
          // Delete Profile
          if (defaultProfile == null) {
            return;
          }
          setState(() {
            _default_profile_name = defaultProfile;
            profileManager.setDefaultProfile(
                profileManager.getProfileByName(defaultProfile).uid);
            ProfileManager.instance.setNeedSaving();
          });
        }

        //var m = {"one": true, "two": false};
        //Map<String,bool> r = await simpleDialogNofM(context,"t",m);
      },
    );
  }

  Widget _tileCreateProfile() {
    return SettingsTile(
      title: 'Create Profile',
      subtitle: null,
      leading: Icon(Icons.add),
      onTap: () async {
        ProfileManager profileManager = ProfileManager.instance;
        // NOTE already choosen names and the empty name aren't allowed as new profile names.
        List<String> profileNames = profileManager.getAllProfileNames();
        // The Temp Profil name is always reserved
        profileNames.add(ProfileManager.TMP_PROFIL_NAME);
        profileNames.add(ProfileManager.NONE_PROFILE_NAME);
        final String profileName = await simpleDialogAskForString(
            context, "New Profile Name", "Name", "e.g. Weekend", profileNames);
        // Cancelled by user
        if (profileName == null) {
          return;
        }

        int id = profileManager.createProfile(profileName);
        Profile profile = profileManager.getProfile(id);
        // Update new Tags
        profile.update();
        ProfileManager.instance.setNeedSaving();
       // Navigator.pop(context);
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new ViewEditProfile(p: profile, searchCount: 0)));
      },
    );
  }

  Widget _tileClearHistory()
  {
    return SettingsTile(
      title: 'Clear Search History',
      subtitle: "Reverses recipe rejection and acceptance",
      leading: Icon(Icons.clear),
      onTap: () async {
        bool okClear = await simpleDialogAskBoolean(context, "Confirm History Deletion", "You are sure you want to empty the history of recipe decisions. This decision cannot be reversed.");
        if(okClear)
        {
          int deletedRows = await CookHistory.instance.clear();
          final snackBar =
          SnackBar(content: Text("History cleared of ${deletedRows} recipes"));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      },
    );
  }

  Widget _tileSuggestionAlgo() {
    return SettingsTile(
      title: 'Suggestion Algorithm',
      subtitle: "Currently " + SettingsManager.instance.suggestionAlgo,
      leading: Icon(Icons.assessment),
      onTap: () async {
        String newAlgo = await simpleDialog1ofN(context, "Choose a Suggestion Algorithm", [ISuggestionAlgorthmn.RANDOM,ISuggestionAlgorthmn.Classic], SettingsManager.instance.suggestionAlgo);

        if(newAlgo != null)
        {
          setState(() {
            SettingsManager.instance.suggestionAlgo = newAlgo;
          });
        }
      },
    );
  }

  Widget _ownTagDefSection() {
    var p = SettingsManager.instance;
    return SettingsSection(title: 'Define own Keywords', tiles: [
      SettingsTile(
        title: 'Favorite Tag',
        subtitle: p.favoriteTag ,
        leading: Icon(Icons.star),
        onTap: () async {
          var allTags = RecipeDatabase.instance.getAllTags();
          if(allTags.length == 0) {
            return;
          }
          var defName = allTags.contains(p.favoriteTag) ? p.favoriteTag : allTags.first;
          String  name = await simpleDialog1ofN(context, "Choose a new Favorite Tag", allTags.toList(),  defName);
          if(name != null) {
            p.favoriteTag = name;
            p.setNeedSaving();
          }
          //TODO Show Maybe ID, Creation Date
        },
      ),
      // Favorite Tag

      SettingsTile(
        title: 'TODO Tag',
        subtitle: p.todoTag ,
        leading: Icon(Icons.calendar_today),
        onTap: () async {
          var allTags = RecipeDatabase.instance.getAllTags();
          if(allTags.length == 0) {
            return;
          }
          var defName = allTags.contains(p.todoTag) ? p.todoTag : allTags.first;
          String  name = await simpleDialog1ofN(context, "Choose a new ${p.todoTag} Tag", allTags.toList(),  defName);
          if(name != null) {
            p.todoTag = name;
            p.setNeedSaving();
          }
        },
      ),
      SettingsTile(
        title: 'Vegan Tag',
        subtitle: p.veganTag ,
        leading: Icon(Icons.local_florist),
        onTap: () async {
          var allTags = RecipeDatabase.instance.getAllTags();
          if(allTags.length == 0) {
            return;
          }
          var defName = allTags.contains(p.veganTag) ? p.veganTag : allTags.first;
          String  name = await simpleDialog1ofN(context, "Choose a new ${p.veganTag} Tag", allTags.toList(),  defName);
          if(name != null) {
            p.veganTag = name;
            p.setNeedSaving();

          }
          //TODO Show Maybe ID, Creation Date
        },
      ),
      SettingsTile(
        title: 'Vegetarian Tag',
        subtitle: p.vegetarianTag ,
        leading: Icon(Icons.local_florist),
        onTap: () async {
          var allTags = RecipeDatabase.instance.getAllTags();
          if(allTags.length == 0) {
            return;
          }
          var defName = allTags.contains(p.vegetarianTag) ? p.vegetarianTag : allTags.first;
          String  name = await simpleDialog1ofN(context, "Choose a new ${p.vegetarianTag} Tag", allTags.toList(),  defName);
          if(name != null) {
            p.vegetarianTag = name;
            p.setNeedSaving();
          }
          //TODO Show Maybe ID, Creation Date
        },
      ),
    ]
    );
  }

  Widget _tileDeleteProfile() {
    return SettingsTile(
      title: 'Delete Profile',
      subtitle: (ProfileManager.instance.getProfileCount() == 1)? "No Profiles for deletion" : null,
      leading: Icon(Icons.delete_forever),
      onTap: () async {
        ProfileManager profileManager = ProfileManager.instance;
        var names = profileManager.getAllProfileNames();
        // You can't delete the default profile => There must be always one profile
        String defaultProfileName = profileManager.getProfile(profileManager.getDefaultProfile()).name;
        names.remove(defaultProfileName);
        // The temp Profil isn't deletable
        names.remove(ProfileManager.TMP_PROFIL_NAME);
        if (names.isNotEmpty) {
          final String deleteProfile = await simpleDialog1ofN(
              context, "Delete Profile", names, names[0]);
          // Delete Profile
          if (deleteProfile == null) {
            return;
          }
          profileManager.deleteProfile(
              profileManager.getProfileByName(deleteProfile).uid);
        }

        //var m = {"one": true, "two": false};
        //Map<String,bool> r = await simpleDialogNofM(context,"t",m);
      },
    );
  }

  Widget _tileEnableKeywords() {
    SettingsManager s = SettingsManager.instance;
    return SettingsTile.switchTile(
      title: 'Use Keywords',
      subtitle: "Interpret each Notes line as a keyword",
      leading: Icon(Icons.note),
      switchValue: s.areKeywordsEnabled(),
      onToggle: (bool value) {
        s.enableKeywords(value);
        s.setNeedSaving();
        setState(() {});
      },
    );
  }

  Widget _TileSendBugReport() {
    final String CRASH_REPORT_MAIL = "Developer.GourmetFoodPlaner@web.de";


      return SettingsTile(
        title: 'Contact the developer',
        subtitle: "Help improving this app",
        leading: Icon(Icons.mail_outline),
        onTap: () async {
          String body = "Logs:";
          List<Log> logs = await FLog.getAllLogs();
          for(Log l in logs) {
            body  += l.toString() + "\n";
          }
          FLog.clearLogs();
          final MailOptions mailOptions = MailOptions(
            body: "",
            subject: "GourmetFoodPlaner User Report",
            recipients: [CRASH_REPORT_MAIL],
            isHTML: false,
            attachments: [],
          );
          
          await FlutterMailer.send(mailOptions);
        },
      ); }

  Widget _tileEditProfile() {
    return SettingsTile(
      title: 'Edit Profile',
      subtitle: null,
      leading: Icon(Icons.edit),
      onTap: () async {
        ProfileManager profileManager = ProfileManager.instance;
        var names = profileManager.getAllProfileNames();
        // The temp Profil isn't editable from this screen
        names.remove(ProfileManager.TMP_PROFIL_NAME);

        if (names.isNotEmpty) {
          final String editProfile =
              await simpleDialog1ofN(context, "Edit Profile", names, names[0]);
          // Cancelled by user
          if (editProfile == null) {
            return;
          }
          Profile profile = profileManager.getProfileByName(editProfile);
          assert(profile != null, "Name of Profile mismatch");
          // Update new Tags
          profile.update();
         // Navigator.pop(context);
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new ViewEditProfile(p: profile, searchCount: 0)));
        }


      },
    );
  }

  Widget projectWidget() {
    return SettingsList(
      sections: [
        SettingsSection(
          title: 'Suggestion Profiles',
          tiles: [
            _tileSelectDefaultProfile() ,
            _tileCreateProfile(),
            _tileDeleteProfile(),
            _tileEditProfile()

          ],
        ),

        SettingsSection(
          title: 'Experimental',
          tiles: [
            _tileEnableKeywords()
          ],
        ),
        if (SettingsManager.instance.areKeywordsEnabled())
          _ownTagDefSection(),



        /// Database section
        SettingsSection(title: 'Various', tiles: [
          this._tileSuggestionAlgo(),
          _TileSendBugReport(),
          SettingsTile(
            title: 'E-Mail (Recipent Shopping Lists)',
            subtitle: mail,
            leading: Icon(Icons.mail),
            onTap: () async {
              String mail = await simpleDialogAskForString(context,
                  "Enter an E-Mail", "E-Mail", "enter a valid E-Mail", []);

              setState(() {
                this.mail = mail;
                SettingsManager.instance.ownerMail = this.mail;
                SettingsManager.instance.setNeedSaving();
              });
            },
          ),
        ]),
        SettingsSection(title: 'Recipe Database', tiles: [
          SettingsTile(
            title: 'Folder',
            subtitle: this._folder_on_sdcard,
            leading: Icon(Icons.folder_open),
            onTap: () async {},
          ),_tileClearHistory()
        ])
        ,
      ],
    );
  }

  void loadSettings() async {
    var path = await AppStorage.getPublicAppFolder();
    setState(() {
      this._folder_on_sdcard = path;
    });
  }
}
