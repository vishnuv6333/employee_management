import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let nativeChannel = FlutterMethodChannel(name: "com.employee_manage/native",
                                              binaryMessenger: controller.binaryMessenger)
    nativeChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "getDeviceInfo":
        let device = UIDevice.current
        result("iOS \(device.systemVersion) (\(device.model))")
      case "getCellTowerLocation":
        result("Cell Tower ID: 310-410-12345 (Mocked)")
      case "showNativeDatePicker":
        let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.frame = CGRect(x: 0, y: 50, width: 270, height: 200)
        alert.view.addSubview(datePicker)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
        result(nil)
      case "showNativeBottomSheet":
        let alert = UIAlertController(title: "Native Bottom Sheet", message: "This is a native iOS action sheet.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Option 1", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Option 2", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = controller.view
            popoverController.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        controller.present(alert, animated: true, completion: nil)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
