import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let instagramStoryChannelName = "com.firstlook/instagram_story_share"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "InstagramStoryShare")
    let channel = FlutterMethodChannel(
      name: instagramStoryChannelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "shareImage" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.shareImageToInstagram(call: call, result: result)
    }
  }

  private func shareImageToInstagram(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let imagePath = arguments["imagePath"] as? String,
          let imageData = FileManager.default.contents(atPath: imagePath) else {
      result(FlutterError(code: "invalid_image", message: nil, details: nil))
      return
    }

    guard let storyUrl = URL(string: "instagram-stories://share"),
          UIApplication.shared.canOpenURL(storyUrl) else {
      result(FlutterError(code: "instagram_not_installed", message: nil, details: nil))
      return
    }

    var pasteboardItem: [String: Any] = [
      "com.instagram.sharedSticker.backgroundImage": imageData
    ]
    if let attributionUrl = arguments["attributionUrl"] as? String,
       !attributionUrl.isEmpty {
      pasteboardItem["com.instagram.sharedSticker.contentURL"] = attributionUrl
    }

    UIPasteboard.general.setItems(
      [pasteboardItem],
      options: [.expirationDate: Date().addingTimeInterval(5 * 60)]
    )
    UIApplication.shared.open(storyUrl, options: [:]) { didOpen in
      result(didOpen)
    }
  }
}
