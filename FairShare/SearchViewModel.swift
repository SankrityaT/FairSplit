import Foundation
import Combine
import FirebaseFirestore

class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    private var firestoreService: FirestoreService
    private var cancellables = Set<AnyCancellable>()

    init(firestoreService: FirestoreService) {
        self.firestoreService = firestoreService
    }

    func search(query: String) {
        let dispatchGroup = DispatchGroup()
        var friends: [Friend] = []
        var expenses: [Expense] = []

        dispatchGroup.enter()
        firestoreService.searchFriends(query: query) { result in
            friends = result
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        firestoreService.searchExpenses(query: query) { result in
            expenses = result
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.searchResults = friends.map { SearchResult.friend($0) } + expenses.map { SearchResult.expense($0) }
        }
    }
}

enum SearchResult: Identifiable {
    case friend(Friend)
    case expense(Expense)
    
    var id: String {
        switch self {
        case .friend(let friend):
            return friend.id ?? UUID().uuidString
        case .expense(let expense):
            return expense.id ?? UUID().uuidString
        }
    }
}
