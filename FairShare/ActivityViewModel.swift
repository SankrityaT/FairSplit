import Foundation
import Combine
import FirebaseFirestore

class ActivityViewModel: ObservableObject {
    @Published var recentActivities: [Expense] = []
    @Published var groupedActivities: [Date: [Expense]] = [:]
    @Published var searchResults: [Expense] = []
    var firestoreService: FirestoreService
    private var cancellables = Set<AnyCancellable>()

    init(firestoreService: FirestoreService) {
        self.firestoreService = firestoreService
        fetchRecentActivities()
    }

    func fetchRecentActivities() {
        guard let userID = AuthService.shared.user?.id else { return }
        firestoreService.fetchRecentActivities(for: userID) { activities in
            print("Fetched recent activities: \(activities)") // Debug statement
            self.recentActivities = activities
            self.groupActivitiesByDate()
        }
    }

    private func groupActivitiesByDate() {
        let grouped = Dictionary(grouping: recentActivities) { (activity: Expense) in
            Calendar.current.startOfDay(for: activity.date)
        }
        DispatchQueue.main.async {
            self.groupedActivities = grouped
            print("Grouped activities: \(self.groupedActivities)") // Debug statement
        }
    }

    func search(query: String) {
        firestoreService.searchExpenses(query: query) { expenses in
            self.searchResults = expenses
        }
    }
}
