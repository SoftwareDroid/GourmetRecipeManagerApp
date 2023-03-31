import 'package:intl/intl.dart';
import 'package:recipe_searcher/database/ingredient.dart';
import 'package:recipe_searcher/database/recipe.dart';
import 'package:tuple/tuple.dart';

/**
 * An entry in the shopping cart
 * The entry can be scaled and have planned date.
 */
class ShoppingCartEntry {
  Map<String, dynamic> toMap() {
    return {
      'recipe_id': this.r.id,
      "timestamp": plannedDate.millisecondsSinceEpoch,
      "servings": this.yields,
    };
  }

  ShoppingCartEntry({this.r, this.yields});
  ShoppingCartEntry.FromDB({this.r, this.yields, this.plannedDate});
  final Recipe r;
  DateTime plannedDate = DateTime.now();
  double yields;

  /**
   * Return a reicpe name with a scale factor at front
   */
  String getScaledRecipeName() {
    NumberFormat formatter = NumberFormat();
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 1;
    return formatter.format(getScaleFactor()) + " x " + this.r.title;
  }

  double getScaleFactor() {
    final double scaleFactor = yields / r.yields;
    return scaleFactor;
  }

  List<Tuple2<int, String>> getListOfIngredients() {
    List<Tuple2<int, String>> ret = new List<Tuple2<int, String>>();
    for (var group in r.getGroupedIngredients()) {
      for (Ingredient i in group.ingredients) {
        String entry =
            (i.amount == null ? "" : i.getAmount(getScaleFactor()) + " ") +
                (i.unit == null ? "" : i.unit.toString() + " ") +
                i.item +
                (i.optional == 1 ? " (Optional)" : "");
        ret.add(new Tuple2<int, String>(i.uid, entry));
      }
    }
    return ret;
  }
}