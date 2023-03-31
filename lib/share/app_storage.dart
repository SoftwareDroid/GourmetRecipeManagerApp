
import 'package:ext_storage/ext_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Access to shared files like datbases
 *
 */

class AppStorage {
  static final String _db_name = "recipes.db";
  static final String _local_app_db = "local.db";
  static final String _profiles = "profiles.json";
  static final String _settings = "settings.json";

  /**
   * Return the public app folder and creates it if not exist
   *
   */
  static Future<String> getPublicAppFolder() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appName = packageInfo.appName;
    var path = await ExtStorage.getExternalStorageDirectory();
    // Build path
    var fullpath = path + "/" + appName + "/data";
    // Check permission
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      // Request Permissiom
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
    }
    // TODO Create DB's if not exist

    var d = new Directory(fullpath);
    if (!d.existsSync()) {
      Directory a = await d.create(recursive: true);
      assert(a.path == fullpath);
      return a.path;
    }
    return fullpath;
  }

  /**
   *
   * The private app folder is only accessable from app or with root permission
   */

  static Future<String> getPrivateAppFolder() async
  {
    return await getDatabasesPath();
  }
  /*
  * The recipes DB, which is come from the GourmetFoodManager
   */

  static Future<String> getPathToRecipeDB() async {
    String path = await getPublicAppFolder();
    return join(path, _db_name);
  }
  /**
   * A databse which contains additonal data like suggetion history
   *
   */
  static Future<String> getPathToLocalAppDB() async {
    String path = await getPrivateAppFolder();

    return join(path, _local_app_db);
  }

  /**
   *
   * The profiles file, which contains all profiles. These profiles can be used to filter suggestions
   */
  static Future<String> getProfileFile() async {
    String path = await getPrivateAppFolder();
    return join(path, _profiles);
  }
  /**
   *
   * The global settings file of this  app
   */
  static Future<String> getSettingsFile() async {
    String path = await getPrivateAppFolder();
    return join(path, _settings);
  }
}
