import SwiftUI

struct MainView: View {
    @State private var selectedIndex: Int = 0
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var firestoreService: FirestoreService

    var body: some View {
        Group {
            if authService.user == nil {
                WelcomeView()
            } else {
                ZStack {
                    switch selectedIndex {
                    case 0:
                        MainDashboardView(firestoreService: firestoreService)
                    case 1:
                        AddExpenseView(firestoreService: firestoreService)
                    case 2:
                        SettingsView()
                    default:
                        MainDashboardView(firestoreService: firestoreService)
                    }
                    VStack {
                        Spacer()
                        CustomNavigationBar(selectedIndex: $selectedIndex, authService: authService, firestoreService: firestoreService)
                    }
                }
                .onAppear {
                    UITabBar.appearance().isHidden = true
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthService())
            .environmentObject(FirestoreService())
    }
}
