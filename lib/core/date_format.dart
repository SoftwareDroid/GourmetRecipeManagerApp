import 'dart:core';

/**
 * Convert a date to an string represnation
 *
 */
class MyDateFormat
{
  static String dmy(DateTime time)
  {
    int day = time.day;
    int year = time.year;
    int month = time.month;
    return "${day}.${month}.${year}";
  }

  static String dmyhmin(DateTime time)
  {
    int day = time.day;
    int year = time.year;
    int month = time.month;
    int hour = time.hour;
    int min = time.minute;
    return "${day}.${month}.${year} ${hour}:${min}";
  }

}