import "dart:collection";

import 'package:recipe_searcher/database/cook_history.dart';
import 'package:recipe_searcher/database/history_record.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:recipe_searcher/shopping_cart/shopping_list_manager.dart';
// This class serves a tempomary buffur for saving suggestions decisions


enum DecisionType {
  ACCEPTED,
  REJECTED,
}

class Decision {
  final DecisionType type;
  final Recipe recipe;
  final DateTime timestamp;
  Decision({this.type,this.recipe,this.timestamp}) {}
}

/**
 * The decisiob stack caches rejections and acceptions to reverse the decision or apply at a later time.
 */
class DecisionStack {
  DecisionStack._privateConstructor();
  static final DecisionStack instance =
  DecisionStack._privateConstructor();

  List<Decision> _stack = new List<Decision>();

  void clear() {
    _stack.clear();
  }

  bool isEmpty() {
    return _stack.isEmpty;
  }

  // Clears the Stack and saves the decions in the cart or write the rejecting back in the database
  Future<void> saveAllDecisions() async{
    for(Decision d in _stack) {
      if(d.type == DecisionType.ACCEPTED) {
        await ShoppingCartManager.instance.addRecipe(d.recipe);
      } else
        if (d.type == DecisionType.REJECTED) {

          CookHistory history = CookHistory.instance;
          HistoryRecord oldRecord = history.getRecord(d.recipe.id);
          assert(oldRecord != null, "Logic Error");

          HistoryRecord recordChanged = new HistoryRecord(
              recipe_id: d.recipe.id,
              timestamp: oldRecord.timestamp,
              rejectedSinceLastCooking: oldRecord.rejectedSinceLastCooking + 1,
              statisticRejectCounter: oldRecord.statisticRejectCounter + 1,
              statisticAcceptCounter: oldRecord.statisticAcceptCounter);
          await history.saveHistoryEntry(recordChanged);

          assert(history.getRecord(d.recipe.id).rejectedSinceLastCooking != oldRecord.rejectedSinceLastCooking,"Rejected Counter not updated");

      }
    }

    _stack.clear();
  }

  int getAcceptedDecisions() {
    int sum = 0;
    for(Decision d in _stack) {
      if (d.type == DecisionType.ACCEPTED) {
        sum++;
      }
    }
    return sum;
  }

  void pushDecision(Recipe r, DecisionType d) {
    _stack.add(Decision(recipe: r,timestamp: DateTime.now().toUtc(),type: d));
  }

  Decision popDecision() {
    return _stack.removeLast();
  }


}