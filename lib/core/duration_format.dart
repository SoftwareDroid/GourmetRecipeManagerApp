/**
 *
 * Converts a Duration in a string representation
 */
class DurationFormat {

  static String toHMMSS(Duration d){
    return "${d.inHours}:${d.inMinutes.remainder(60)}:${(d.inSeconds.remainder(60))}";
  }
  static String toHMM(Duration d){
    return "${d.inHours}h ${d.inMinutes.remainder(60)}min";
  }

}
