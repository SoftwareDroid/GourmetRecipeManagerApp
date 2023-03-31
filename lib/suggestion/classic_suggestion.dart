import 'dart:math';

import 'package:recipe_searcher/database/cook_history.dart';
import 'package:recipe_searcher/database/history_record.dart';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/profile/profile.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_manager.dart';
import 'package:recipe_searcher/suggestion/i_suggestion_algorthmn.dart';
import 'package:recipe_searcher/suggestion/suggestion_share.dart';
import 'package:tuple/tuple.dart';
import 'dart:async';

enum NextDishType { Meat, Veggie, DontCare }

/**
 * The classic suggestion alogorthmn tries to suggest recipes which have less in common with the last cooked (accepted recipes.
 * Score every recipe s = (DaysSinceLastCooked * RatingFactor) + CuisinePenalty + DeclinePenalty and the choose the recipe with the highest score
 *
 */

class ClassicSuggestion extends ISuggestionAlgorthmn {
  static final double RATING_FACTOR_FAVORITE = 1.5;   // Rate recipes with the favorite tag higher
  static final double RATING_FACTOR_RATING_NORMAL = 1.0;
  static final double RATING_FACTOR_RATING_BAD = 0.7;   // Score recipes with a bad rating worse

  static final int LAST_CUISINE_PENALTY_1 = -11;
  static final int LAST_CUISINE_PENALTY_2 = -7;
  static final int LAST_CUISINE_PENALTY_3 = -5;
  static final int LAST_CUISINE_PENALTY_4 = -3;
  static final int LAST_CUISINE_PENALTY_5 = -1;

  static final int PENALTY_IN_PLANNING = -999999;

  static final int REJECT_EXP = 2; //used to calculate the decline penaltay
  static final int REJECT_MIN_PENALATY = -14;

  CookHistory history = CookHistory.instance;
  RecipeDatabase recipe_db = RecipeDatabase.instance;

  ClassicSuggestion._privateConstructor();

  static final ClassicSuggestion instance =
      ClassicSuggestion._privateConstructor();

  void _init() async {
    history = CookHistory.instance;
    history.open_db();
    // Open the recipe db

    recipe_db.read_db();
  }

  /**
   * Use this method only for debug purposes. To search always for the same recipe.
   */
  Future<Recipe> debugSearch() async{
    return recipe_db.recipes[88]; //Gulasch
  }

  /**
   * Create a suggsetion.
   * @return null if there can be recipe suggested
   */
  @override
  Future<Recipe> createSuggestion(Profile profile, Set<int> suspendRecipes) async {
    //return debugSearch();

    var completer = new Completer<Recipe>();
    profile.update();
    // load the history and recipes
    _init();
    // determine first all possible recipes without a consideration of the history
    Map<int, int> recipesToScores =
        this._getAllPossibleRecipes(recipe_db, profile, history,suspendRecipes);
    await _createDefaultEntriesInHistory(recipesToScores.keys.toList());

    var h = history.getSortedHistory();

    Map<String, int> lastCookedCuisines =
        Map<String, int>(); // Cuisine, ranking when last cooked
    NextDishType nextDishType = _determineHistoryScoresAndNextDishType(
        h, lastCookedCuisines, recipesToScores, profile);
    // Determine the scores for all recipes that ar eno in the history
    List<Tuple2<Recipe, int>> remainingRecipes =
        _filterRecipesAfterVegMode(nextDishType, recipesToScores);

    // Sort the remaining recipes after their score, if the score is the same use the id to get a more deterministic result
    remainingRecipes.sort((Tuple2<Recipe, int> a, Tuple2<Recipe, int> b) {
      int cmpScore = b.item2.compareTo(a.item2);
      if (cmpScore != 0) return cmpScore;
      return a.item1.id.compareTo(b.item1.id);
    });

    // Return the first recipe if there
    if (remainingRecipes.length == 0) {
      completer.complete(null);
      return null;
    }

    assert(recipesToScores.containsKey(remainingRecipes[0].item1.id),"Logic Error Result is not possible");
    completer.complete(remainingRecipes[0].item1);
    return completer.future;
  }

  List<Tuple2<Recipe, int>> _filterRecipesAfterVegMode(
      NextDishType type, Map<int, int> recipesToScores) {
    List<Tuple2<Recipe, int>> ret = new List<Tuple2<Recipe, int>>();
    Map<int, int> filteredMap = recipesToScores;
    switch (type) {
      case (NextDishType.Meat):
        recipesToScores
            .removeWhere((k, v) => recipe_db.recipes[k].isNoMeatDish());
        break;
      case (NextDishType.Veggie):
        recipesToScores
            .removeWhere((k, v) => !recipe_db.recipes[k].isNoMeatDish());
        break;
      case (NextDishType.DontCare):
        break;
      default:
        assert(false, "Enum Value missing");
    }
    for (int k in filteredMap.keys) {
      ret.add(Tuple2<Recipe, int>(recipe_db.recipes[k], filteredMap[k]));
    }

    return ret;
  }

  Future<void> _createDefaultEntriesInHistory(List<int> ids) async {
    for (int recipe_id in ids) {
      if (!history.isRecipeInHistory(recipe_id)) {
        await history.createDefaultEntry(recipe_id);
      }
    }
  }

  NextDishType _determineHistoryScoresAndNextDishType(
      List<HistoryRecord> h,
      Map<String, int> cuisineCookorder,
      Map<int, int> recipesScores,
      Profile profile) {
    int cuisineCounter = 1;
    DateTime timeLastMeatDish;
    int countVegDishesAfterLastMeatDish = 0;
    bool foundMeatDish = false;
    // Calc score for all recipes in the history
    for (HistoryRecord record in h) {
      Recipe recipe = recipe_db.recipes[record.recipe_id];
      bool recipeAlreadyInCart = ShoppingCartManager.instance.hasRecipe(recipe);
      if(recipe == null || recipeAlreadyInCart )
        {
          continue;
        }
      // Update last cooked cuisine
      if (!cuisineCookorder.containsKey(recipe.cuisine)) {
        cuisineCookorder[recipe.cuisine] = cuisineCounter;
        cuisineCounter++;
      }
      // Note calculate score for the recipe if it is in the profile
      if(recipesScores.containsKey(record.recipe_id)) {
        recipesScores[record.recipe_id] =
            this._getRecipeScore(record, cuisineCookorder[recipe.cuisine]);
      }

      if (!foundMeatDish) {
        if (recipe.isNoMeatDish()) {
          countVegDishesAfterLastMeatDish++;
        } else {
          foundMeatDish = true;
          timeLastMeatDish = record.timestamp;
        }
      }
    }
    // If there isn
    if (timeLastMeatDish == null) {
      timeLastMeatDish = DateTime.now().toUtc();
    }

    return _getMeatModeForNextDish(
        timeLastMeatDish, countVegDishesAfterLastMeatDish, profile);
  }

  NextDishType _getMeatModeForNextDish(DateTime timeLastMeatDish,
      int countVegDishesAfterLastMeatDish, Profile profile) {
    assert(timeLastMeatDish != null);
    if (profile.vegMode == VegMode.Vegetarian ||
        profile.vegMode == VegMode.Vegan) {
      return NextDishType.Veggie;
    }

    final int passedDaysSinceLastMeatDish =
        DateTime.now().toUtc().difference(timeLastMeatDish).inDays;


    switch (profile.meatMode) {
      case ("EveryDish"):
        return NextDishType.Meat;
      case ("DontCare"):
        return NextDishType.DontCare;
      case ("EverySecondDish"):
        if (countVegDishesAfterLastMeatDish < 1) {
          return NextDishType.Veggie;
        }
        return NextDishType.Meat;
      case ("EverySecondDish"):
        if (countVegDishesAfterLastMeatDish < 2) {
          return NextDishType.Veggie;
        }
        return NextDishType.Meat;
      case ("EveryThirdDish"):
        if (countVegDishesAfterLastMeatDish < 3) {
          return NextDishType.Veggie;
        }
        return NextDishType.Meat;case ("OnceAWeek"):
        if (passedDaysSinceLastMeatDish >= 7) {
          return NextDishType.Meat;
        }
        return NextDishType.Veggie;
      case ("OnceInTwoWeeks"):
        if (passedDaysSinceLastMeatDish >= 14) {
          return NextDishType.Meat;
        }
        return NextDishType.Veggie;
      default:
        assert(false, "Unkown Meat Mode");
    }
    assert(false, "Unkown Meat Mode");
    return NextDishType.DontCare;
  }

  int _getRecipeScore(HistoryRecord record, int cuisineCookorder) {
    Recipe recipe = recipe_db.recipes[record.recipe_id];
    //int score = possibleRecipes[record.recipe_id];
    // Use Seconds to get a more different rating during testing
    final int passedDays =
        DateTime.now().toUtc().difference(record.timestamp).inDays;
    // If the recipe has a cook date in the history set a very hard penaly
    int history_cook_penalty = 0;
    if (passedDays < 0) {
      history_cook_penalty = PENALTY_IN_PLANNING;
    }

    final double ratingRactor = _getRatingFactor(recipe);
    final int cuisinePenalatySummand =
        this._getCuisinePenalty(cuisineCookorder, recipe);
    final int declinesPenaltySummand =
        this._getDeclinesPenaltySummand(record.rejectedSinceLastCooking);
    final int score = (passedDays * ratingRactor).floor() +
        cuisinePenalatySummand +
        declinesPenaltySummand + history_cook_penalty;
    assert(cuisinePenalatySummand <= 0 && declinesPenaltySummand <= 0,
        "Penalties must be zero or negativ");
    assert(ratingRactor >= 0, "negativ favorite factor");
    return score;
  }

  int _getDeclinesPenaltySummand(int declines) {
    return (declines == 0) ? 0 : (REJECT_MIN_PENALATY + -pow(declines + 1, REJECT_EXP));
  }

  int _getCuisinePenalty(int order, Recipe r) {
    switch (order) {
      case (1):
        return LAST_CUISINE_PENALTY_1;
        break;
      case (2):
        return LAST_CUISINE_PENALTY_2;
        break;
      case (3):
        return LAST_CUISINE_PENALTY_3;
        break;
      case (4):
        return LAST_CUISINE_PENALTY_4;
        break;
      case (5):
        return LAST_CUISINE_PENALTY_5;
        break;
      default:
        assert(order != 0, "Logic Error");
        return 0;
    }
  }

  double _getRatingFactor(Recipe r) {
    var p = SettingsManager.instance;
    if (p.areKeywordsEnabled() && r.hasTag(p.favoriteTag)) {
      return RATING_FACTOR_FAVORITE;
    } else if (r.rating >= 4) {
      return RATING_FACTOR_RATING_NORMAL;
    } else {
      return RATING_FACTOR_RATING_BAD;
    }
  }

  Map<int, int> _getAllPossibleRecipes(
      RecipeDatabase db, Profile profile, CookHistory history, Set<int> suspendRecipes) {
    Map<int, int> recipes = new Map<int, int>();

    for (int recipe_id in db.recipes.keys) {
      // TODO batch insert, um den Prozess zu beschleunigen
      if (!history.isRecipeInHistory(recipe_id)) {
        history.createDefaultEntry(recipe_id);
      }

      Recipe recipe = db.recipes[recipe_id];
      final bool suspend = suspendRecipes.contains(recipe_id);
      if (!suspend && isInProfile(profile, recipe)) {
        recipes[recipe_id] = 0; //NOTE we overwrite this entry later
      }
    }
    return recipes;
  }



  // Button accept a recipe

}
