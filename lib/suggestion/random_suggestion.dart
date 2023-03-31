import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/profile/profile.dart';
import 'package:recipe_searcher/suggestion/i_suggestion_algorthmn.dart';
import 'dart:async';
import 'package:recipe_searcher/suggestion/suggestion_share.dart';


/**
 * A simple suggestion algothmn which chooses a random recipe that match a profile.
 *
 */
class RandomSuggestion extends ISuggestionAlgorthmn {

  RandomSuggestion._privateConstructor();

  static final RandomSuggestion instance =
  RandomSuggestion._privateConstructor();

  @override
  Future<Recipe> createSuggestion(Profile profile, Set<int> suspendRecipes)
  {
    var completer = new Completer<Recipe>();
    profile.update();
    List<Recipe> result = [];
    for(Recipe r in RecipeDatabase.instance.recipes.values) {
      final bool suspend = suspendRecipes.contains(r.id);
      if (!suspend && isInProfile(profile, r)) {
        result.add(r);
      }
    }
    if (result.length == 0) {
      completer.complete(null);
    }
    Recipe randomItem = (result..shuffle()).first;
    completer.complete(randomItem);
    return completer.future;
  }

}