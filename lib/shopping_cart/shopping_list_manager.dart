import 'package:recipe_searcher/database/history_record.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_entry.dart';
import 'package:recipe_searcher/shopping_cart/shoppingcart_history.dart';
import 'package:recipe_searcher/database/cook_history.dart';

/**
 * Manages the shopping cart
 *
 */
class ShoppingCartManager {
  ShoppingCartManager._privateConstructor();
  static final ShoppingCartManager instance =
      ShoppingCartManager._privateConstructor();

  bool hasRecipe(Recipe r) {
    return this._list.containsKey(r.id);
  }

  void setFullList(List<ShoppingCartEntry> entries) {
    this._list.clear();
    for (ShoppingCartEntry e in entries) {
      this._list[e.r.id] = e;
    }
  }

  Future<void> addRecipe(Recipe r) async {

    var entry = new ShoppingCartEntry(r: r, yields: r.yields == null ? 1 : r.yields);
    await ShoppingCartHistory.instance.saveEntry(entry);
    this._list[r.id] = entry;
  }

  Future<void> removeEntry(ShoppingCartEntry e) async {
    await ShoppingCartHistory.instance.deleteEntry(e);
    this._list.remove(e.r.id);
  }

  // Remove the entry form the shopping the a certain recipe id
  Future<void> removeRecipe(Recipe r) async {
    ShoppingCartEntry delEntry = null;
    for(ShoppingCartEntry e in _list.values) {
      if(e.r.id == r.id) {
        delEntry = e;
        break;
      }
    }
    if(delEntry != null) {
      await ShoppingCartHistory.instance.deleteEntry(delEntry);
      this._list.remove(r.id);

    }

  }

  Future<void> clear() async {
    await ShoppingCartHistory.instance.clear();
    this._list.clear();
  }

  // Accept a single recipe
  Future<void> completeSingleEntry(ShoppingCartEntry e) {
    _completeRecipe(e);
    this._list.remove(e.r.id);

  }

  Future<void> completeAll() {
    for(ShoppingCartEntry e in _list.values) {
      _completeRecipe(e);
    }
    clear();
  }


  Future<void> _completeRecipe(ShoppingCartEntry e) async {

    CookHistory history = CookHistory.instance;
    HistoryRecord r = history.getRecord(e.r.id);
    assert(r != null, "Logic Error");
    HistoryRecord recordChanged = new HistoryRecord(
        recipe_id: e.r.id,
        timestamp: e.plannedDate,
        rejectedSinceLastCooking: 0,
        statisticRejectCounter: r.statisticRejectCounter,
        statisticAcceptCounter: r.statisticAcceptCounter + 1);
    await history.saveHistoryEntry(recordChanged);
  }

  List<ShoppingCartEntry> getEntries() {
    var entries = _list.values.toList();
    entries.sort((a, b) => a.r.title.compareTo(b.r.title));
    return entries;
  }

  bool isEmpty() {
    return _list.isEmpty;
  }

  String createShoppingListAsString() {
    String ret = "";

    for (int key in _list.keys) {
      Recipe r = _list[key].r;
      ret += "[" + r.title + "]" + "\n";
      for (var entry in _list[key].getListOfIngredients()) {
        ret += entry.item2 + "\n";
      }
      ret += "\n";
    }
    print(ret);
    return ret;
  }

  Map<int, ShoppingCartEntry> _list = new Map<int, ShoppingCartEntry>();
}
