import UIKit
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Set up Firebase App Check with a custom provider factory
        let providerFactory = CustomAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        return true
    }
}

