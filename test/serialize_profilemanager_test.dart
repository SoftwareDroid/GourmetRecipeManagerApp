// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_searcher/profile/profile.dart';
import 'package:recipe_searcher/profile/profile_manager.dart';


import 'package:recipe_searcher/screens/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {

    //Create Profile
    Profile profile = new Profile(3);
    profile.name = "Hallo";
    profile.update();

    var manager = ProfileManager.instance;

    expect(manager.profiles.length, 0);
    manager.profiles[profile.uid] = profile;


    String json = jsonEncode(manager);
    manager.profiles.clear();
    manager.profiles.clear();
    ProfileManager manager2 = ProfileManager.fromJson(jsonDecode(json));
    expect(manager2.profiles.length, 1);
    expect(manager2.profiles[profile.uid].name, "Hallo");



/*



    String json = jsonEncode(manager);


    manager.profiles.clear();

    manager.loadFromString(json);
    expect(manager.profiles.length, 1);
    expect(manager.profiles[0].name, "Hallo");
*/

    /*// Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);*/
  });

}
