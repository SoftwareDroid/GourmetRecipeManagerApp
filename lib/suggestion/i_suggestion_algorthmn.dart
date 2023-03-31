import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/profile/profile.dart';

/**
 * An common interface for all suggestion alogrtmhns.
 * This enables it to use more than one.
 *
 */
class ISuggestionAlgorthmn {
  static final String RANDOM = "Random";
  static final String Classic = "Classic";

  /**
   *
   * Create a recipe suggestion base on a profile and not allowed recipes.
   * Can return null if it is impossible to create a suggestion
   */
  Future<Recipe> createSuggestion(Profile profile, Set<int> suspendRecipes)
  {
    return null;
  }
}