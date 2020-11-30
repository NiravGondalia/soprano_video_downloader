import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: slash_for_doc_comments
/**
 `PermissionHandler` class to check and request permissions.
 */

class PermissionHandler {

  static Future<bool> checkStoragePermission() async {
    bool permStatus = await Permission.storage.isGranted ?? false;
    if(!permStatus){
     return await _getPermission(Permission.storage);
    }
    return permStatus;
  }

  static Future<bool> _getPermission(Permission permission)  async {
    PermissionStatus status  = await permission.status;
    switch (status) {
      case PermissionStatus.granted:
        return true;
        break;
      case PermissionStatus.denied:
        await permission.request();
        return permission.isGranted;
        break;
      case PermissionStatus.permanentlyDenied:
        await AppSettings.openAppSettings();
        return permission.isGranted;
        break;
      case PermissionStatus.undetermined:
        await permission.request();
        return permission.isGranted;
        break;
      case PermissionStatus.restricted:
        return false;
        break;
      default:
    }
  }
}