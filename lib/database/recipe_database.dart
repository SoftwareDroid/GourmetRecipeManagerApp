import 'package:recipe_searcher/database/ingredient.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:sqflite/sqflite.dart';
import 'package:recipe_searcher/share/app_storage.dart';

class RecipeDatabase {
  Set<String> _allTags = new Set<String>();
  Set<String> _Cuisines = new Set<String>();
  Set<String> _dishTypes = new Set<String>();

  Map<int, Recipe> recipes = {};
  bool _need_init = true;

  // Singleton pattern
  RecipeDatabase._privateConstructor() {}

  Future<void> init() async {
    await this.read_db();
  }

  static final RecipeDatabase instance = RecipeDatabase._privateConstructor();

  Set<String> getAllTags() {
    ;
    assert(!this._need_init);
    if (_allTags.length == 0) {
      for (int key in recipes.keys) {
        Recipe r = recipes[key];
        for (String tag in r.getAllTags()) {
          this._allTags.add(tag);
        }
      }
    }
    return _allTags;
  }

  Set<String> getAllCuisines() {
    assert(!this._need_init);
    if (_Cuisines.length == 0) {
      for (int key in recipes.keys) {
        Recipe r = recipes[key];
        _Cuisines.add(r.cuisine);
      }
    }
    return _Cuisines;
  }

  Set<String> getAllDishTypes() {
    assert(!this._need_init);
    if (_dishTypes.length == 0) {
      for (int key in recipes.keys) {
        Recipe r = recipes[key];
        _dishTypes.add(r.category);
      }
    }
    return _dishTypes;
  }

  Future<bool> checkIfDatabaseExists() async {
    String filename = await AppStorage.getPathToRecipeDB();
    return databaseExists(filename);
  }

  Future<void> read_db() async {
    if (!_need_init) {
      return;
    }
    _need_init = false;

    String filename = await AppStorage.getPathToRecipeDB();

    /*if (!dbExist)
    {
        throw Exception(filename + " not found");
    }*/

    Database database = await openReadOnlyDatabase(filename);
    List<Map> rows = await database.rawQuery(
        'SELECT recipe.id as id,title,cooktime,category,yields,source,yield_unit,servings,recipe.cuisine as c,deleted,description,last_modified,rating,link,modifications,preptime,instructions FROM recipe INNER JOIN categories ON recipe.id = categories.recipe_id');
    for (int n = 0; n < rows.length; n++) {
      var row = rows[n];
      var recipe = new Recipe.Create(
          id: row["id"],
          title: row["title"],
          instructions: row["instructions"],
          cooktime: row["cooktime"],
          cuisine: row["c"],
          deleted: row["deleted"],
          description: row["description"],
          //image: row["image"],
          last_modified: row["last_modified"],
          link: row["link"],
          modifications: row["modifications"],
          preptime: row["preptime"],
          rating: row["rating"],
          servings: row["servings"],
          source: row["source"],
          //thumb: row["thumb"],
          yield_unit: row["yield_unit"],
          yields: row["yields"],
          category: row["category"]);
      await this.getAllIngredients(database, recipe);
      assert(recipe.cuisine != null);
      recipes[recipe.id] = recipe;
    }

    database.close();
  }
  // Unload all Images from the memory to free RAM
  Future<void> unloadAllImages()  {
    for(Recipe r in recipes.values) {
      r.unloadImage();
      r.unloadThumb();
    }
  }

  Future<List<int>> getImage(Recipe recipe) async
  {
    assert(recipe != null);
    String filename = await AppStorage.getPathToRecipeDB();
    Database database = await openReadOnlyDatabase(filename);
    List<Map> rows = await database.rawQuery(
        'SELECT image FROM recipe WHERE id=?', [recipe.id]);
    assert(rows.length == 1);
    //database.close(); NOTE the can  close this databse here becasue this leads t
    return rows[0]["image"];
  }

  Future<List<int>> getThumb(Recipe recipe) async
  {
    assert(recipe != null);
    String filename = await AppStorage.getPathToRecipeDB();
    bool dbExist = await databaseExists(filename);
    Database database = await openReadOnlyDatabase(filename);
    List<Map> rows = await database.rawQuery(
        'SELECT thumb FROM recipe WHERE id=?', [recipe.id]);
    assert(rows.length == 1);
    database.close();
    return rows[0]["thumb"];
  }



  void getAllIngredients(Database db, Recipe r) async {
    List<Map> rows = await db
        .rawQuery('SELECT * FROM ingredients WHERE recipe_id=?', [r.id]);
    List<Ingredient> ingredients = [];
    for (int n = 0; n < rows.length; n++) {
      var row = rows[n];

      // refid=row[2], unit=row[3], amount=row[4], rangeamount=row[5], item=row[6],
      //optional=row[8], inggroup=row[10],position= row[11],deleted=row[12]
      var ingredient = new Ingredient.Create(
          uid: row["id"],
          refid: row["refid"],
          unit: row["unit"],
          amount: row["amount"],
          rangeamount: row["rangeamount"],
          item: row["item"],
          optional: row["optional"],
          ingroup: row["inggroup"],
          position: row["position"],
          deleted: row["deleted"]);
      ingredients.add(ingredient);
    }
    r.setIngredients(ingredients);
  }
}
