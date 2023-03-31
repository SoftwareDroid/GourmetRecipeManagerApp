/*
ingredient = Ingredient(refid=row[2], unit=row[3], amount=row[4], rangeamount=row[5], item=row[6],
                                    optional=row[8], inggroup=row[10],position= row[11],deleted=row[12])
 */

import 'package:intl/intl.dart';

/**
 * A single ingredient for an recipe
 *
 */
class Ingredient {
  final int uid;
  final int refid;
  final String unit;
  final double amount;
  final double rangeamount;
  final String item;
  final int optional;
  final int deleted;
  final int position;
  final String ingroup;

  Ingredient.Create(
      {this.uid,
      this.refid,
      this.unit,
      this.amount,
      this.rangeamount,
      this.item,
      this.optional,
      this.deleted,
      this.position,
      this.ingroup}) {}


  String getAmount(double scale) {
    double amount2 = amount * scale;
    if (amount2.truncate() - amount2 == 0) {
      return amount2.truncate().toString();
    } else {
      NumberFormat formatter = NumberFormat();
      formatter.minimumFractionDigits = 0;
      formatter.maximumFractionDigits = 2;
      return formatter.format(amount2);

    }
  }
}

class IngredientGroup {
  final String name;
  final List<Ingredient> ingredients;
  int _id = 0;

  IngredientGroup.Create(this.name, this.ingredients) {
    ingredients.sort((a, b) => a.position.compareTo(b.position));
    if (ingredients.length > 0) {
      this._id = ingredients[0].position;
    }
  }

  int getID() {
    if (name == null) {
      return 10000;
    } else {
      return this._id;
    }
  }
}
/*
class IngredientGroup:
def __init__(self, name: Optional[str], ingredients: Sequence[Ingredient]):
self._name = name
self._ingredients = sorted(ingredients, key=lambda x: x.position())
if len(self._ingredients) > 0:
self._id = self._ingredients[0].position()
else:
self._id = 0

def name(self) -> Optional[str]:
return self._name

def id(self):
"""Return a high id fo that all these ingredients are listed at the button"""
if self._name is None:
return 10000
return self._id

def ingredients(self) -> Sequence[Ingredient]:
"""Return the sorted ingredients"""
return self._ingredients*/
