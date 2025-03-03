// Replace the UIApplicationDelegate with SwiftUI App
import SwiftUI
import PassioNutritionAISDK

@main
struct PassioQuickStartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Keep AppDelegate for SDK initialization
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let passioConfiguration = PassioConfiguration(
            key: "YOUR_KEY_HERE"
        )
        
        PassioNutritionAI.shared.configure(passioConfiguration) { status in
            print(status.debugDescription)
        }
        
        return true
    }
} 