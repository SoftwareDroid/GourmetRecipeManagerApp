// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:recipe_searcher/screens/main.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_searcher/database/recipe_database.dart';


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    var db = RecipeDatabase.instance;
    await db.read_db();

  });

}
