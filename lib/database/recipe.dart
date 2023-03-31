import 'dart:ffi';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/settings/settings_manager.dart';

import 'ingredient.dart';

enum LoadingState { Loaded, BeforeLoading }
enum StarSymbol { STAR_FULL, STAR_EMPTY, STAR_HALF }
/**
 * A wrapper for a recipe.
 * All attributes come the recipe database of GourmetFoodManager
 *
 */
class Recipe {
  LoadingState _stateImage = LoadingState.BeforeLoading;
  LoadingState _stateThumb = LoadingState.BeforeLoading;
  final int id;
  final String title;
  final String instructions;
  final String cuisine;
  final int rating;
  final String description;
  final String source;
  final int preptime;
  final int cooktime;
  final int servings;
  final double yields;
  final String yield_unit;
  List<int> _image =
      []; //_Uint8ArrayView Siehe https://api.flutter.dev/flutter/widgets/Image/Image.memory.html
  List<int> _thumb = [];
  final int deleted;
  final String link;
  final double last_modified; // Posfix Timestamp
  final String modifications;
  List<Ingredient> _ingredients = new List<Ingredient>();
  final String category;

  Set<String> _tags = null;

  Set<String> getAllTags() {
    if (this._tags == null) {
      _createTags();
    }
    return this._tags;
  }

  void setIngredients(List<Ingredient> ingredients) {
    assert(_ingredients.length == 0);
    this._ingredients = ingredients;
  }

  Recipe.Create(
      {this.id,
      this.title,
      this.instructions,
      this.cuisine,
      this.rating,
      this.description,
      this.source,
      this.preptime,
      this.cooktime,
      this.servings,
      this.yields,
      this.yield_unit,
      this.deleted,
      this.last_modified,
      this.link,
      this.modifications,
      this.category}) {
    assert(this.cuisine != null);
  }

  List<StarSymbol> symbolizedRating() {
    List<StarSymbol> ret = new List<StarSymbol>();
    int ratingCopy = this.rating;
    for (var i = 0; i < 5; i++) {
      ratingCopy -= 2;
      if (ratingCopy >= 0) {
        ret.add(StarSymbol.STAR_FULL);
      } else if (ratingCopy == -1) {
        ret.add(StarSymbol.STAR_HALF);
      } else {
        ret.add(StarSymbol.STAR_EMPTY);
      }
    }
    return ret;
  }

  DateTime getLastModifiedDate() {
    return DateTime.fromMillisecondsSinceEpoch((this.last_modified * 1000).round());
  }

  Future<List<int>> getImage() async {
    if (this._stateImage != LoadingState.Loaded) {
      var img = await RecipeDatabase.instance.getImage(this);
      this._image = img;
      this._stateImage = LoadingState.Loaded;
    }
    return this._image;
  }

  Future<List<int>> getThumb() async {
    if (this._stateThumb != LoadingState.Loaded) {
      var thumb = await RecipeDatabase.instance.getThumb(this);
      this._thumb = thumb;
      this._stateThumb = LoadingState.Loaded;
    }
    return _thumb;
  }

  void unloadImage() {
    this._image = [];
    this._stateImage = LoadingState.BeforeLoading;
  }

  void unloadThumb() {
    this._thumb = [];
    this._stateThumb = LoadingState.BeforeLoading;
  }

  List<IngredientGroup> getGroupedIngredients() {
    List<IngredientGroup> allGroups = [];
    Map<String, List<Ingredient>> groups = {};
    for (Ingredient ing in this._ingredients) {
      String group = ing.ingroup;
      if (!groups.containsKey(group)) {
        groups[group] = new List<Ingredient>();
      }
      groups[group].add(ing);
    }
    for (String groupKey in groups.keys) {
      String name = groupKey;
      allGroups.add(IngredientGroup.Create(name, groups[groupKey]));
    }
    allGroups.sort((a, b) => a.getID().compareTo(b.getID()));
    return allGroups;
  }

  void _createTags() {
    this._tags = Set<String>();
    if (this.modifications == null) {
      return;
    }
    var lines = this.modifications.split("\n");
    for (String line in lines) {
      String normalized_line = line.toLowerCase();
      this._tags.add(normalized_line);
    }
  }

  bool isNoMeatDish() {
    var p = SettingsManager.instance;
    return this.hasTag(p.vegetarianTag) || this.hasTag(p.veganTag);
  }

  bool hasTag(String tag) {
    if (this._tags == null) {
      _createTags();
    }
    return this._tags.contains(tag.toLowerCase());
  }

  int getTotalTimeInSeconds() {
    return this.cooktime + this.preptime;
  }
}

/*
    def _create_tags(self):
        if self._notes is None:
            return
        lines = self._notes.splitlines()

        for line in lines:
            normalized_line: str = line.lower()
            if normalized_line not in all_tags:
                print("keyword does't exist: " + normalized_line + " in " + self.title())
            else:
                self._tags.add(normalized_line)
 */
