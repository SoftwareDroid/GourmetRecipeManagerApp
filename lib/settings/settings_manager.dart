import 'dart:io';
import 'dart:async';
import 'package:recipe_searcher/suggestion/i_suggestion_algorthmn.dart';

import 'package:recipe_searcher/share/app_storage.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
part 'settings_manager.g.dart';

enum SettingsManagerState {NeedLoad,NeedSave,Synced}
/**
 * Saves and laods gloab app settings
 */
@JsonSerializable()
class SettingsManager {

  Map<String, dynamic> toJson() => _$SettingsManagerToJson(this);
  factory SettingsManager.fromJson(Map<String, dynamic> json) => _$SettingsManagerFromJson(json);


  SettingsManagerState state = SettingsManagerState.NeedLoad;
  @JsonKey(required: true)
  int version = 2;

  @JsonKey(required: true)
  String ownerMail = "";    // Should be in settings but we have no settings
  @JsonKey(required: true)
  String veganTag = "vegan";    // Should be in settings but we have no settings
  @JsonKey(required: true)
  String vegetarianTag = "vegetarian";    // Should be in settings but we have no settings
  @JsonKey(required: true)
  String favoriteTag = "favorite";    // Should be in settings but we have no settings
  @JsonKey(required: true)
  String todoTag = "todo";    // Should be in settings but we have no settings
  @JsonKey(required: true)
  bool agreedAlphaReleaseNote = true;
  @JsonKey(required: true)
  bool showHelp = true;     // Show a help at start up
  @JsonKey(required: true)
  bool _use_keywords = true;
  @JsonKey(required: true)
  String suggestionAlgo = ISuggestionAlgorthmn.Classic; // The used suggestion algorithm


  void enableKeywords(bool v) {
    _use_keywords = v;
  }

  void setNeedSaving()
  {
    assert(state != SettingsManagerState.NeedLoad);
    if(state == SettingsManagerState.Synced)
    {
      state = SettingsManagerState.NeedSave;
    }
  }

  bool areKeywordsEnabled() {
    return _use_keywords;
  }

  Future<void> init() async
  {
    if (state == SettingsManagerState.NeedLoad) {
      await _load();
      state = SettingsManagerState.Synced;
    }
  }

  // Singleton pattern
  SettingsManager._privateConstructor() {

  }
  SettingsManager(){}


  static final SettingsManager instance = SettingsManager._privateConstructor();






  Future<File> get _localFile async {
    final path = await AppStorage.getSettingsFile();
    return File(path);
  }

  Future<void> save() async {
    if(state == SettingsManagerState.NeedLoad)
    {
        await _load();
        return Future<File>.value(null);
    }

    assert(state != SettingsManagerState.NeedLoad);
    if(state == SettingsManagerState.Synced)
    {
      return Future<File>.value(null);
    }

    final file = await _localFile;
    String json = jsonEncode(this);
    // Write the file.
    state = SettingsManagerState.Synced;
    await file.writeAsString(json);
  }
  /*
    Load all profiles from the disk

   */
  Future<void> _load() async {
    final file = await _localFile;

    try {

      if (file.existsSync()) {

        String json = await file.readAsString();
        SettingsManager manager2 = SettingsManager.fromJson(jsonDecode(json));
        if (manager2.version != this.version) {

          throw Exception("Version mismatch");
        }
        // Tags
        this.vegetarianTag = manager2.vegetarianTag;
        this.favoriteTag = manager2.favoriteTag;
        this.todoTag = manager2.todoTag;
        this.veganTag = manager2.veganTag;

        this.ownerMail = manager2.ownerMail;
        this.showHelp = manager2.showHelp;
        this.agreedAlphaReleaseNote = manager2.agreedAlphaReleaseNote;
        this._use_keywords = manager2._use_keywords;
        this.state = SettingsManagerState.Synced;
        this.suggestionAlgo = manager2.suggestionAlgo;

      }
    }
    catch(Exception )
    {
      // Rename file in case of version mismatch and throw away the loaded results
      file.delete();
    }
  }
}
