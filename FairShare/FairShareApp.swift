import SwiftUI
import Firebase

@main
struct FairShareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authService = AuthService()
    @StateObject private var firestoreService = FirestoreService()
    @State private var showLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Show launch screen for 2 seconds
                            withAnimation {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                MainView()
                    .onAppear {
                        NotificationManager.shared.requestAuthorization()
                    }
                    .environmentObject(authService)
                    .environmentObject(firestoreService)
            }
        }
    }
}
