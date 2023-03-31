// An Entry in the history db table
/**
 * A histroy record for a recipe which contains for example the number of rejection which is used in the suggestion algothmn
 *
 */
class HistoryRecord {
  final int recipe_id;
  //final String profile_name;
  final DateTime timestamp; // Save as Integer in Database always in utc
  final int rejectedSinceLastCooking; // Will be reset by every Accept
  final int statisticAcceptCounter;
  final int statisticRejectCounter;
  //final int suspended; // The recipe will no longer be showed

  HistoryRecord(
      {this.recipe_id,
      //this.profile_name,
      this.timestamp,
      this.rejectedSinceLastCooking,
      this.statisticRejectCounter,
        this.statisticAcceptCounter,
       // this.suspended, // The recipe will no longer be showed

      })
  {
    assert(this.recipe_id != null);
  }

  Map<String, dynamic> toMap() {
    return {
      'recipe_id': recipe_id,
      //'profile_name': profile_name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'rejectCounter': rejectedSinceLastCooking,
      'statisticAcceptCounter': statisticAcceptCounter,
      'statisticRejectCounter': statisticRejectCounter,
      //'suspended': suspended,
    };
  }


}
