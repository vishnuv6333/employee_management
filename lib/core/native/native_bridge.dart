import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.employee_manage/native');

  static Future<String?> getDeviceInfo() async {
    try {
      final String result = await _channel.invokeMethod('getDeviceInfo');
      return result;
    } on PlatformException catch (e) {
      return "Failed to get device info: '${e.message}'.";
    }
  }

  static Future<String?> getCellTowerLocation() async {
    try {
      final String result = await _channel.invokeMethod('getCellTowerLocation');
      return result;
    } on PlatformException catch (e) {
      return "Failed to get cell tower: '${e.message}'.";
    }
  }

  static Future<void> showNativeDatePicker() async {
    try {
      await _channel.invokeMethod('showNativeDatePicker');
    } on PlatformException catch (e) {
      print("Failed to show date picker: '${e.message}'.");
    }
  }

  static Future<void> showNativeBottomSheet() async {
    try {
      await _channel.invokeMethod('showNativeBottomSheet');
    } on PlatformException catch (e) {
      print("Failed to show bottom sheet: '${e.message}'.");
    }
  }
}
