import 'package:recipe_searcher/database/ingredient.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/profile/profile.dart';
import 'package:recipe_searcher/profile/profile_manager.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:recipe_searcher/suggestion/suggestion_share.dart';
import 'package:string_similarity/string_similarity.dart';

enum SortOrder { Rating, Time, Name, Cuisine, Source, Category, LastModified, LastCooked }

String convertSortOrderToString(SortOrder s) {
  switch (s) {
    case SortOrder.Name:
      {
        return "Name";
      }
    case SortOrder.Rating:
      {
        return "Rating";
      }
    case SortOrder.Time:
      {
        return "Duration";
      }
    case SortOrder.Source:
      {
        return "Source";
      }
    case SortOrder.Category:
      {
        return "Category";
      }
    case SortOrder.LastModified:
      {
        return "Last Modified";
      }
    case SortOrder.LastCooked:
      {
        return "Last Cooked";
      }
    case SortOrder.Cuisine:
      {
        return "Cuisine";
      }
  }
}

class SearchSettings {
  String term = "";
  int profileId = ProfileManager.INVALID_PROFILE_ID;  // Allow all
  SortOrder order = SortOrder.Rating;
}

/**
 * A fulltext search for the mounted recipe database.
 * The search is a simplified mimic fo the full textsearch in GourmetRecipeManger.
 *
 */
class RecipeFulltextSearch {
  static final double SIMARALITY_THRESHOLD =
      0.7; // A word similarity for ignoring typos
  // use the order in the settings

  static int _sortByName(Recipe a, Recipe b) {
    return a.title.compareTo(b.title);
  }

  static int _sortByTime(Recipe a, Recipe b) {
    return a.getTotalTimeInSeconds().compareTo(b.getTotalTimeInSeconds());
  }

  static int _sortByRating(Recipe a, Recipe b) {
    if (a.rating == b.rating) {
      return a.title.compareTo(b.title);
    } else {
      // Higher ratings will come at front
      return b.rating.compareTo(a.rating);
    }
  }

  static int _sortBySource(Recipe a, Recipe b) {
    if ( (a.source == null || b.source == null) || a.source == b.source) {
      return a.title.compareTo(b.title);
    } else {
      // Higher ratings will come at front
      return a.source.compareTo(b.source);
    }
  }

  static int _sortByCategory(Recipe a, Recipe b) {
    if ( (a.category == null || b.category == null) || a.category == b.category) {
      return a.title.compareTo(b.title);
    } else {
      // Higher ratings will come at front
      return a.category.compareTo(b.category);
    }
  }

  static int _sortByCuisine(Recipe a, Recipe b) {

    //TODO Wrong interpet missing as empty string and use cmp == 0 then other option
    if ( (a.cuisine == null || b.cuisine == null) || a.category == b.category) {
      return a.title.compareTo(b.title);
    } else {
      // Higher ratings will come at front
      return a.category.compareTo(b.category);
    }
  }

  /**
   * Idea search in recipe Titles, keywords ,Ingredients Lists
   * If the list is empty than the search result is also empty
   */
  static Future<List<Recipe>> search(SearchSettings settings) async {
    String text = settings.term;
    if (text == null &&
        settings.profileId == ProfileManager.INVALID_PROFILE_ID) {
      return [];
    }
    text = text.toLowerCase();
    RecipeDatabase db = RecipeDatabase.instance;
    List<Recipe> foundRecipes = new List<Recipe>();
    // Iterate over all recipes
    for (Recipe r in db.recipes.values) {
      if (_filterAll(r, settings)) {
        foundRecipes.add(r);
      }
    }
    // Sort Result
    switch (settings.order) {
      case SortOrder.Time:
        {
          foundRecipes.sort(RecipeFulltextSearch._sortByTime);
        }
        break;
      case SortOrder.Rating:
        {
          foundRecipes.sort(RecipeFulltextSearch._sortByRating);
        }
        break;
      case SortOrder.Name:
        {
          foundRecipes.sort(RecipeFulltextSearch._sortByName);
        }
        break;
      default:
        assert(false,"no supported sort");
    }

    return foundRecipes;
  }

  static bool _filterByProfile(Recipe r, SearchSettings s) {
    assert(s.profileId != ProfileManager.TMP_PROFIL_ID);
    if (s.profileId != ProfileManager.INVALID_PROFILE_ID) {
      return isInProfile(ProfileManager.instance.profiles[s.profileId], r);
    }
    // Invalid id => all profiles => always ok
    return true;
  }

  static bool _filterAll(Recipe r, SearchSettings s) {
    String text = s.term;
    return _filterByProfile(r, s) &&
        (_filterRecipeTitle(r, text) ||
            (SettingsManager.instance.areKeywordsEnabled()
                ? _filterKeyword(r, text)
                : _filterNotes(r, text)) ||
            _filterIngredients(r, text) ||
            _filterCuisine(r, text) ||
            _filterSource(r, text) ||
            _filterURL(r, text));
  }

  static bool _filterNotes(Recipe r, String text) {
    if (r.modifications != null &&
        r.modifications.toLowerCase().contains(text)) {
      return true;
    }
    return false;
  }

  static bool _filterCuisine(Recipe r, String text) {
    String cuisine = r.cuisine;
    if (cuisine != null && cuisine.toLowerCase().contains(text)) {
      return true;
    }
    return false;
  }

  static bool _filterSource(Recipe r, String text) {
    String source = r.source;
    if (source != null && source.toLowerCase().contains(text)) {
      return true;
    }
    return false;
  }

  static bool _filterURL(Recipe r, String text) {
    String url = r.link;
    if (url != null && url.toLowerCase().contains(text)) {
      return true;
    }
    return false;
  }

  static bool _filterRecipeTitle(Recipe r, String text) {
    if (r.title == null) {
      return false;
    }

    if (r.title.toLowerCase().contains(text)) {
      return true;
    }
    double similarity =
        StringSimilarity.compareTwoStrings(r.title.toLowerCase(), text);
    return similarity >= SIMARALITY_THRESHOLD;
  }

  static bool _filterKeyword(Recipe r, String text) {
    for (String tag in r.getAllTags()) {
      if (tag.toLowerCase().contains(text)) {
        return true;
      }
    }
    return false;
  }

  static bool _filterIngredients(Recipe r, String text) {
    var groups = r.getGroupedIngredients();
    for (IngredientGroup group in groups) {
      assert(group.ingredients != null);
      for (Ingredient ing in group.ingredients) {
        if (ing.item != null && ing.item.toLowerCase().contains(text)) {
          return true;
        }
      }
    }
    return false;
  }
}
