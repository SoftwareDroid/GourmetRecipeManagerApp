import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/profile/profile.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';

/**
 * Checks if a profile matchs with a profile
 *
 */
bool isInProfile(Profile profile, Recipe r) {
  // Check max recipe time and dish type
  final int timelimitInSeconds = profile.maxTime.inSeconds;

  if (r.getTotalTimeInSeconds() > timelimitInSeconds ||
      !profile.dish_types.containsKey(r.category) || !profile.whitelist_cuisines.containsKey(r.cuisine)
  ) {

    return false;
  }

  if (SettingsManager.instance.areKeywordsEnabled() && !_isInProfileKeywordExension(profile,r)) {
    return false;
  }

  return true;
}

bool _isInProfileKeywordExension(Profile profile, Recipe r) {
  // Veggie Mdde
  switch (profile.vegMode) {
    case VegMode.All:
    // None tag restriction
      break;
    case VegMode.Vegetarian:
      if (!r.hasTag(SettingsManager.instance.vegetarianTag)) {
        return false;
      }
      break;
    case VegMode.Vegan:
      if (!r.hasTag(SettingsManager.instance.veganTag)) {
        return false;
      }
      break;
  }
  // Check Blacklist tags
  for (String tag in profile.blacklist_tags.keys) {
    if (profile.blacklist_tags[tag] && r.hasTag(tag)) {
      return false;
    }
  }

  // Check Whitelist tags
  for (String tag in profile.whitelist_tags.keys) {
    if (profile.whitelist_tags[tag] && !r.hasTag(tag)) {
      return false;
    }
  }
  return true;
}