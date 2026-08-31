import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerService {
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> isCameraPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }
}