import 'profile.dart';
import 'dart:io';
import 'dart:async';
import 'package:recipe_searcher/share/app_storage.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
part 'profile_manager.g.dart';

enum ProfileManagerState {NeedLoad,NeedSave,Synced}

/**
 * Responsible for saving and loading the profiles from sdcard.
 *
 */
@JsonSerializable()
class ProfileManager {
  static final String TMP_PROFIL_NAME = "";
  static final int TMP_PROFIL_ID = -1;
  static final String NONE_PROFILE_NAME = "NONE";
  static final int INVALID_PROFILE_ID = -2;

  Map<String, dynamic> toJson() => _$ProfileManagerToJson(this);
  factory ProfileManager.fromJson(Map<String, dynamic> json) => _$ProfileManagerFromJson(json);

  void setDefaultProfile(int uid)
  {
    assert(profiles.containsKey(uid));
    default_profile = uid;
    this.setNeedSaving();
    this.save();
  }

  Profile resetTempProfile()
  {
    this.profiles.remove(ProfileManager.TMP_PROFIL_ID);
    Profile tmp = Profile(ProfileManager.TMP_PROFIL_ID);
    this.profiles[tmp.uid] = tmp;
    tmp.name = ProfileManager.TMP_PROFIL_NAME;
    return tmp;
  }

  Profile getTempProfile()
  {
    assert(profiles.containsKey(ProfileManager.TMP_PROFIL_ID),"use the reset function instead");
    return this.profiles[ProfileManager.TMP_PROFIL_ID];
  }


  bool hasDefaultProfile()
  {

    return default_profile != -1;
  }

  int getDefaultProfile()
  {
    assert(hasDefaultProfile());
    return default_profile;
  }

  void setNeedSaving()
  {
    assert(state != ProfileManagerState.NeedLoad);
    if(state == ProfileManagerState.Synced)
    {
      state = ProfileManagerState.NeedSave;
    }
  }



  ProfileManagerState state = ProfileManagerState.NeedLoad;
  @JsonKey(required: true)
  int version = 5;
  @JsonKey(required: true)
  int next_uid = 1;
  @JsonKey(required: true)
  int default_profile = 0;  //The profile uid, which is used to the quick search


  Future<void> init() async
  {
    if (state == ProfileManagerState.NeedLoad) {
      await _load();
      state = ProfileManagerState.Synced;
    }
  }

  // Singleton pattern
  ProfileManager._privateConstructor() {

  }
  ProfileManager(){}


  static final ProfileManager instance = ProfileManager._privateConstructor();

  Map<int, Profile> profiles =  { 0: new Profile(0)};


  List<Profile> _profiles2 = [];

  List<String> getAllProfileNames() {
    List<String> names = new List<String>();
    for (int id in profiles.keys) {
      names.add(profiles[id].name);
    }
    return names;
  }

  int _generateNewProfileID()
  {
    next_uid++;
    return next_uid;

  }

  int getProfileCount() {return profiles.length;}

  int createProfile(String name) {
    // We reuse id's
    ProfileManager.instance.setNeedSaving();
    int _uid = _generateNewProfileID();
    Profile p = new Profile(_uid);
    p.name = name;
    profiles[p.uid] = p;
    // Make the first created profile to the default profile
    if (!this.hasDefaultProfile())
      {
        setDefaultProfile(_uid);
      }

    return p.uid;
  }

  Profile getProfile(int key) {
    return profiles[key];
  }

  Profile getProfileByName(String name) {
    for (int id in profiles.keys) {
      if (profiles[id].name == name) {
        return profiles[id];
      }
    }
    return null;
  }

  /**
   * Tries to delting a profile. This operation can fail by deltig the last profile (return false).
   *
   */
  bool deleteProfile(int key) {
    // It is always safe to delete the tmp profile
    assert(profiles.containsKey(key) || key == ProfileManager.TMP_PROFIL_ID);
    if (this.getDefaultProfile() == key )
    {
        return false;
    }
    ProfileManager.instance.setNeedSaving();
    profiles.remove(key);
    return true;
  }

  Future<File> get _localFile async {
    final path = await AppStorage.getProfileFile();
    return File(path);
  }

  Future<File> save() async {
    if(state == ProfileManagerState.NeedLoad)
    {
        await _load();
        return Future<File>.value(null);
    }

    assert(state != ProfileManagerState.NeedLoad);
    if(state == ProfileManagerState.Synced)
    {
      return Future<File>.value(null);
    }

    this._profiles2 = profiles.values.toList();
    final file = await _localFile;
    String json = jsonEncode(this);
    // Write the file.
    state = ProfileManagerState.Synced;
    return file.writeAsString(json);
  }
  /*
    Load all profiles from the disk

   */
  Future<void> _load() async {

    final file = await _localFile;

    try {

      if (file.existsSync()) {

        String json = await file.readAsString();
        ProfileManager manager2 = ProfileManager.fromJson(jsonDecode(json));
        if (manager2.version != this.version) {

          throw Exception("Version mismatch");
        }
        this.default_profile = manager2.default_profile;
        this.profiles = manager2.profiles;
        this.next_uid = manager2.next_uid;


      }
    }
    catch(Exception )
    {
      // Rename file in case of version mismatch and throw away the loaded results
      file.delete();
    }
  }
}
