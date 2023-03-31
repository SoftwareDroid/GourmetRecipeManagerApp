import 'package:recipe_searcher/shopping_cart/shopping_list_entry.dart';
import 'package:recipe_searcher/database/recipe_database.dart';
import 'package:recipe_searcher/share/app_storage.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_manager.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Saves and loads the shopping cart to the filesystem
 */
class ShoppingCartHistory {
  Database _db = null;
  bool _need_init = true;
  final String TABLE_NAME = "ShoppingCart";

  String getCreateTableCommand()
  {
    String name = TABLE_NAME;
    return "CREATE TABLE ${name} (recipe_id INTEGER PRIMARY KEY UNIQUE, timestamp INTEGER NOT NULL, servings FLOAT NOT NULL )";
  }

  ShoppingCartHistory._privateConstructor();

  static final ShoppingCartHistory instance = ShoppingCartHistory._privateConstructor();

  Future<void> init(Database db) async
  {
    await read_db(db);
  }

  void read_db(Database db) async {
    if (!_need_init) {
      return;
    }

    String filename = await AppStorage.getPathToLocalAppDB();


    this._db = db;

    var allEntries = await _get_all_records();
    ShoppingCartManager.instance.setFullList(allEntries);
    // NOTE we only need to sort once, because new entries are added at the end
    _need_init = false;
  }

  Future<List<ShoppingCartEntry>> _get_all_records() async {
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
    await this._db.query(this.TABLE_NAME);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    var tmp = List.generate(maps.length, (i) {
      return  ShoppingCartEntry.FromDB(r: RecipeDatabase.instance.recipes[maps[i]['recipe_id']],yields: maps[i]['servings'], plannedDate: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']));
    });

    return tmp;
  }

  Future<void> deleteEntry(ShoppingCartEntry record) async {
    // Load all entries
    init(this._db);
    // Remove the Dog from the Database.
    await this._db.delete(
      this.TABLE_NAME,
      // Use a `where` clause to delete a specific dog.
      where: "recipe_id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [record.r.id],
    );
  }


  Future<int> clear() async {
    int delRows = await this._db.delete(this.TABLE_NAME);
    return delRows;
  }

  Future<void> saveEntry(ShoppingCartEntry newRecord) async {
    // Load all entries
    init(this._db);
    bool hasAlreadyEntry = ShoppingCartManager.instance.hasRecipe(newRecord.r);
    if (hasAlreadyEntry) {
      var row = newRecord.toMap();
      row.remove("recipe_id");
      // do the update and get the number of affected rows
      int updateCount = await this._db.update(this.TABLE_NAME, row,
          where: 'recipe_id = ?', whereArgs: [newRecord.r.id]);
      assert(updateCount == 1, "Logic Error " + updateCount.toString());
    } else {

      await this._db.insert(
        this.TABLE_NAME,
        newRecord.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    //Overwrite cache
  }
}
