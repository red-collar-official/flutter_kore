import Foundation

private let CHANNEL_NAME = "com.umvvm_template.plugins/device_locale"

class DeviceLocalePlugin {
    class func register(with registrar: (NSObject & FlutterPluginRegistrar)?) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: (registrar?.messenger())!)
        channel.setMethodCallHandler({ call, result in
            let method = call.method
            if (method == "currentLocale") {
                result(currentLocale())
            } else if (method == "currentCountry") {
                result(currentCountry())
            } else if (method == "preferredLanguages") {
                result(preferredLanguages())
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    class func currentCountry() -> String? {
        return Locale.current.regionCode
    }
    
    class func currentLocale() -> String? {
        return Locale.current.languageCode
    }
    
    class func preferredLanguages() -> [String] {
        return NSLocale.preferredLanguages;
    }
}
