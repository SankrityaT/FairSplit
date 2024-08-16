//import SwiftUI
//
//struct ExpensesView: View {
//    @StateObject private var firestoreService = FirestoreService()
//    @State private var searchText: String = ""
//    @State private var isSearching: Bool = false
//    @State private var selectedIndex: Int = 0
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                CustomNavigationBar(selectedIndex: $selectedIndex, isSearching: $isSearching, showAddFriend: .constant(false))
//                List(filteredFriends) { friend in
//                    ExpenseListItemView(friend: friend)
//                }
//                .listStyle(PlainListStyle())
//            }
//            .navigationBarHidden(true)
//        }
//    }
//
//    var totalAmountOwed: Double {
//        firestoreService.friends.filter { !$0.isOwed }.reduce(0) { $0 + $1.amount }
//    }
//
//    var filteredFriends: [Friend] {
//        if searchText.isEmpty {
//            return firestoreService.friends
//        } else {
//            return firestoreService.friends.filter {
//                $0.name.lowercased().contains(searchText.lowercased()) ||
//                $0.amount.description.contains(searchText)
//            }
//        }
//    }
//}
//
//struct ExpensesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpensesView()
//    }
//}
