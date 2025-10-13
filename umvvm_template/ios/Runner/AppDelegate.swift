import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        DeviceLocalePlugin.register(with: registrarFor("DeviceLocalePlugin"))
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func registrarFor(_ plugin: String) -> (NSObject & FlutterPluginRegistrar) {
        return self.registrar(forPlugin: plugin) as! (NSObject & FlutterPluginRegistrar)
    }
}
