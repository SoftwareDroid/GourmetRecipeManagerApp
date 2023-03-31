import 'package:recipe_searcher/database/history_record.dart';
import 'package:recipe_searcher/share/app_storage.dart';
import 'package:recipe_searcher/shopping_cart/shoppingcart_history.dart';
import 'package:sqflite/sqflite.dart';

// Save to every reipe cook histroy and accept and rejecting data
class CookHistory {

  static final TABLE_NAME = "cook_history";
  Database _db = null;
  Map<int,HistoryRecord> _cached_db = new Map<int,HistoryRecord>();

  //Set<int> _known_recipes = new Set<int>();
  bool _need_init = true;

  CookHistory._privateConstructor();

  static final CookHistory instance = CookHistory._privateConstructor();

  Future<void> init() async
  {
    await open_db();
  }
  // Runtime O(N)
  HistoryRecord getRecord(int id) {
    //assert(this._cached_db.containsKey(id)); //TODO FIXME ggf. ist der insert nicht schnell genung
    return this._cached_db[id];
  }

  void open_db() async {
    if (!_need_init) {
      return;
    }

    String filename = await AppStorage.getPathToLocalAppDB();
    String historyTable =     "CREATE TABLE ${TABLE_NAME} (recipe_id INTEGER PRIMARY KEY UNIQUE, timestamp INTEGER NOT NULL, rejectCounter INTEGER NOT NULL,statisticAcceptCounter INTEGER NOT NULL,statisticRejectCounter INTEGER NOT NULL )";
    String shoppingCarTable  =  ShoppingCartHistory.instance.getCreateTableCommand();


    this._db = await openDatabase(filename,
      onCreate: (db, version) async{
        await db.execute(historyTable);
        await db.execute(shoppingCarTable);
      },
      version: 1);
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.

    // Call the Shoppingcard DB initi function
    await ShoppingCartHistory.instance.init(this._db);

    var tmp = await _get_all_records();
    for(HistoryRecord h in tmp)
    {
      this._cached_db[h.recipe_id] = h;
    }
    // NOTE we only need to sort once, because new entries are added at the end
    _need_init = false;
  }

  bool isRecipeInHistory(int key) {

    return this._cached_db.containsKey(key);
  }

  List<HistoryRecord> getSortedHistory() {
    assert(!_need_init);
    var ret = this._cached_db.values.toList();
    ret.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return ret;
  }

  Future<List<HistoryRecord>> _get_all_records() async {
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await this._db.query(TABLE_NAME);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    var tmp = List.generate(maps.length, (i) {
      return HistoryRecord(
        recipe_id: maps[i]['recipe_id'],
        //profile_name: maps[i]['profile_name'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        rejectedSinceLastCooking: maps[i]['rejectCounter'],
        statisticAcceptCounter: maps[i]['statisticAcceptCounter'],
        statisticRejectCounter: maps[i]['statisticRejectCounter'],
        //suspended: maps[i]['suspended'],
      );
    });

    return tmp;
  }

  Future<int> clear() async {
    this._cached_db.clear();
    int delRows = await this._db.delete(TABLE_NAME);
    return delRows;
  }

  Future<void> createDefaultEntry(int recipe_id) async {
    assert(!this._cached_db.containsKey(recipe_id));
    HistoryRecord record = new HistoryRecord(
        recipe_id: recipe_id,
        timestamp: DateTime.now().toUtc(),
        rejectedSinceLastCooking: 0,
        statisticAcceptCounter: 0,
        statisticRejectCounter: 0);
    await this.saveHistoryEntry(record);
  }

  Future<void> saveHistoryEntry(HistoryRecord newRecord) async {
    // Load all entries
    open_db();
    if (this._cached_db.containsKey(newRecord.recipe_id)) {
      var row = newRecord.toMap();
      row.remove("recipe_id");
      // do the update and get the number of affected rows
      int updateCount = await this._db.update(TABLE_NAME, row,
          where: 'recipe_id = ?', whereArgs: [newRecord.recipe_id]);
      assert(updateCount == 1, "Logic Error " + updateCount.toString());
    } else {

      await this._db.insert(
            TABLE_NAME,
            newRecord.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
    }
    //Overwrite cache
    _cached_db [newRecord.recipe_id] = newRecord;
  }
}
