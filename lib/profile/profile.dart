import 'package:recipe_searcher/profile/profile_manager.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import "../database/recipe_database.dart";
import 'package:json_annotation/json_annotation.dart';
part 'profile.g.dart';

enum VegMode { Vegan, Vegetarian, All }

// We use a Map so, that can easisly extend or Remove Values
const Map<String,int> MeatMode =
{
  "DontCare": 1000,
  "EveryDish": 1,
  "EverySecondDish": 2,
  "EveryThirdDish": 3,
  "OnceAWeek": 4,
   "OnceInTwoWeeks": 5,
};

String meatModeToString(String meatModeConstant)
{
  switch (meatModeConstant) {
    case "DontCare":
      {
        return "DontCare";
      }
    case "EveryDish":
      {
        return "EveryDish";
      }
    case "EverySecondDish":
      {
        return "EverySecondDish";
      }
    case "OnceAWeek":
      {
        return "OnceAWeek";
      }
    case "OnceInTwoWeeks":
      {
        return "OnceInTwoWeeks";
      }
    case "EveryThirdDish":
      {
        return "EveryThirdDish";
      }
  }
}


String vegModeToString(VegMode v) {
  switch (v) {
    case VegMode.All:
      {
        return "No Restriction";
      }
    case VegMode.Vegan:
      {
        return "Vegan";
      }
    case VegMode.Vegetarian:
      {
        return "Vegetarian";
      }
  }
}

/**
 * A profile to filter suggestions.
 * TODO add min rating
 *
 */
@JsonSerializable()
class Profile {
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Profile(int uid) : uid = uid {}

  // Attributes, for Seralization
  final int uid;
  VegMode vegMode = VegMode.All;
  String name = "Default";
  Duration maxTime = Duration(hours: 1);
  String meatMode = "DontCare";
  Map<String, bool> dish_types = new Map<String, bool>();
  Map<String, bool> blacklist_tags = new Map<String, bool>();
  Map<String, bool> whitelist_tags = new Map<String, bool>();
  Map<String, bool> whitelist_cuisines = new Map<String, bool>();

  bool isTempomary()
  {
    return ProfileManager.TMP_PROFIL_ID == this.uid;
  }

  void update() {
    var db = RecipeDatabase.instance;
    SettingsManager s = SettingsManager.instance;
    // Update tags
    for (String tag in db.getAllTags()) {
        if(tag == s.veganTag  || tag == s.vegetarianTag)
          {
            continue;
          }

      if (!blacklist_tags.containsKey(tag)) {
        blacklist_tags[tag] = false;
      }
      if (!whitelist_tags.containsKey(tag)) {
        whitelist_tags[tag] = false;
      }
    }

    for (String c in db.getAllCuisines()) {
      if (!whitelist_cuisines.containsKey(c)) {
        whitelist_cuisines[c] = true;
      }
    }
    for (String c in db.getAllDishTypes()) {
      if (!dish_types.containsKey(c)) {
        dish_types[c] = true;
      }
    }

  }




}
