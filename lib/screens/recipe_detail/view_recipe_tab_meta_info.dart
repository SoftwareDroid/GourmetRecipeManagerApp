import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recipe_searcher/core/date_format.dart';
import 'package:recipe_searcher/core/dialogs.dart';
import 'package:recipe_searcher/database/cook_history.dart';
import 'package:recipe_searcher/database/history_record.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:settings_ui/settings_ui.dart';

import '../share/drawer.dart';


/*
Shows differtn Metadat for a recipe

 */
class ViewRecipeMetaTab extends StatefulWidget {
  final Recipe recipe;

  ViewRecipeMetaTab({this.recipe});

  _ViewRecipeMetaTabState createState() =>
      _ViewRecipeMetaTabState(this.recipe);
}

class _ViewRecipeMetaTabState extends State<ViewRecipeMetaTab> {
  final Recipe recipe;
  _ViewRecipeMetaTabState(this.recipe) {
    assert(this.recipe != null, " this screen can show only valid recipes");
    assert(this.recipe.title != null, "Every Recipe needs a title");
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return projectWidget();
  }

  /*Widget _tileYields() {
    return SettingsTile(
      title: 'Yields',
      subtitle: recipe.yields == null ? "" : recipe.yields.floor().toString(),
      leading: Icon(Icons.local_dining),
    );
  }*/

  Widget _tileSource() {
    return SettingsTile(
      title: 'Source',
      subtitle: recipe.source == null ? "" : recipe.source,
      leading: Icon(Icons.person),
    );
  }

  Widget _tileRating() {
    int ratingMax = 5;
    double currentRating =
        this.recipe.rating == null ? 0 : this.recipe.rating / 2;
    // Remoe for example trailing zeros
    NumberFormat formatter = NumberFormat();
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 1;
    String r = formatter.format(currentRating);
    return SettingsTile(
      title: 'Rating',
      subtitle: "${r} of ${ratingMax}",
      leading: Icon(Icons.star),
    );
  }

  String formatTime(int seconds) {
    Duration d = new Duration(seconds: seconds);
    String text = "";
    int inMin = d.inMinutes;

    NumberFormat formatter = NumberFormat();
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 1;

    if (d.inHours >= 1) {
      text = formatter.format(d.inMinutes / 60) + " h";
    } else {
      text = d.inMinutes.toString() + " min";
    }
    return text;
  }

  Widget _prepTime() {
    return SettingsTile(
      title: 'Preperation Time',
      subtitle: recipe.preptime == null ? "" : formatTime(recipe.preptime),
      leading: Icon(Icons.access_time),
    );
  }

  Widget _tileCookingTime() {
    return SettingsTile(
      title: 'Cooking Time',
      subtitle: recipe.cooktime == null ? "" : formatTime(recipe.cooktime),
      leading: Icon(Icons.access_time),
    );
  }

  Widget _tileLink() {
    var link = recipe.link;
    if(link == null || link == "") {
      return null;
    }

    return SettingsTile(
      title: 'Link',
      subtitle: recipe.link,
      leading: Icon(Icons.link),
        onTap: () async {
          var url = recipe.link;

          if (await canLaunch(url)) {
            bool shouldOpen = await simpleDialogAskBoolean(context, "Open external URL", "Confirm the opening of ${url} in the browser.");
            if (shouldOpen) {
            await launch(url);}
          }

        }
    );
  }

  Widget _tileCuisine() {
    return SettingsTile(
      title: 'Cuisine',
      subtitle: recipe.cuisine == null ? "" : recipe.cuisine.split("/").last,
      leading: Icon(Icons.public),
    );
  }

  Widget _tilelastModified() {
    return SettingsTile(
      title: 'Last Modified',
      subtitle: MyDateFormat.dmyhmin(this.recipe.getLastModifiedDate()),
      leading: Icon(Icons.calendar_view_day),
    );
  }

  Widget _tilekeywords() {
    String tags = "";
    List<String> tagList = recipe.getAllTags().toList();
    tagList.sort();
    for (String s in tagList) {
      if (s != tagList.last) {
        tags += s + ", ";
      } else {
        tags += s;
      }
    }

    return SettingsTile(
      title: 'Tags',
      subtitle: tags,
      leading: Icon(Icons.note),
    );
  }

  Widget _tileChoosen() {
    HistoryRecord r = CookHistory.instance.getRecord(recipe.id);
    int count = (r == null) ? 0 : r.statisticAcceptCounter;

    return SettingsTile(
      title: 'Accepted',
      subtitle: count.toString(),
      leading: Icon(Icons.thumb_up),
    );
  }

  Widget _tileRejected() {
    HistoryRecord r = CookHistory.instance.getRecord(recipe.id);
    int count = (r == null) ? 0 : r.statisticRejectCounter;

    return SettingsTile(
      title: 'Rejected',
      subtitle: count.toString(),
      leading: Icon(Icons.thumb_down),
    );
  }

  /*Widget _tileDescription() {


    return SettingsTile(
      title: 'Description',
      leading: Icon(Icons.description),
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new ViewRecipeDescription(r: recipe,scaleFactor: 1.0)));

      },
    );
  }*/


  Widget projectWidget() {
    return SettingsList(
      sections: [
        SettingsSection(
          title: "Information",
          tiles: [
            _tileRating(),
            _prepTime(),
            _tileCookingTime(),
            _tileCuisine(),
            if (SettingsManager.instance.areKeywordsEnabled())
              _tilekeywords(),
           // _tileDescription(),

          ],
        ),

        SettingsSection(title: "History", tiles: [_tileChoosen(), _tileRejected()]),

        SettingsSection(title: "Source", tiles: [_tileLink(), _tileSource(),_tilelastModified()]),

      ],
    );
  }
}
