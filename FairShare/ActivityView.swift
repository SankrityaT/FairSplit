import SwiftUI
import Firebase
import FirebaseFirestore

struct ActivityView: View {
    @ObservedObject var viewModel: ActivityViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack {
            navigationBar
            if isSearching {
                searchResultsList
            } else {
                activityList
            }
            Spacer()
            CustomNavigationBar(selectedIndex: $selectedIndex, authService: authService, firestoreService: viewModel.firestoreService)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.fetchRecentActivities()
        }
    }

    private var navigationBar: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20))
                    .padding()
                    .background(Circle().fill(Color.purple))
                    .foregroundColor(.white)
            }
            .padding(.leading)

            Spacer()

            if isSearching {
                searchBar
            } else {
                Text("Recent Activity")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: {
                withAnimation {
                    isSearching.toggle()
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .padding()
                    .background(Circle().fill(Color.purple))
                    .foregroundColor(.white)
            }
            .padding(.trailing)
        }
        .padding()
        .background(Color.black)
    }

    private var searchBar: some View {
        HStack {
            TextField("Search Any Expense or a Friend", text: $searchText, onCommit: {
                viewModel.search(query: searchText)
            })
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(25)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)

                    if !searchText.isEmpty {
                        Button(action: {
                            self.searchText = ""
                            viewModel.search(query: searchText)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .transition(.move(edge: .trailing))
            .padding(.horizontal, 10)
        }
        .padding()
    }

    private var activityList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.groupedActivities.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(date, style: .date).foregroundColor(.white)) {
                        ForEach(viewModel.groupedActivities[date] ?? []) { activity in
                            VStack {
                                ActivityRow(expense: activity, currentUserId: authService.user?.id ?? "", firestoreService: viewModel.firestoreService)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                                Divider().background(Color.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .background(Color.black)
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.searchResults, id: \.id) { result in
                    if let expense = result as? Expense {
                        VStack {
                            ActivityRow(expense: expense, currentUserId: authService.user?.id ?? "", firestoreService: viewModel.firestoreService)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .shadow(radius: 10)
                            Divider().background(Color.gray)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct ActivityRow: View {
    var expense: Expense
    var currentUserId: String
    var firestoreService: FirestoreService

    var body: some View {
        HStack {
            if expense.paidBy == currentUserId {
                if let profileImageUrl = firestoreService.currentUser?.profileImageUrl, let url = URL(string: profileImageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading) {
                    Text("You added \"\(expense.description)\"")
                    Text(expense.amountOwed > 0 ? "You get back \(expense.amountOwed, specifier: "%.2f")" : "You owe \(abs(expense.amountOwed), specifier: "%.2f")")
                        .foregroundColor(expense.amountOwed > 0 ? .green : .red)
                    Text("\(expense.date, formatter: DateFormatter.shortTime)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                if let profileImageUrl = getProfileImageUrlByID(expense.paidBy), let url = URL(string: profileImageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading) {
                    Text("\(getFriendNameByID(expense.paidBy)) added \"\(expense.description)\"")
                    Text(expense.splitAmounts[currentUserId]! > 0 ? "You owe \(expense.splitAmounts[currentUserId]!, specifier: "%.2f")" : "You get back \(abs(expense.splitAmounts[currentUserId]!), specifier: "%.2f")")
                        .foregroundColor(expense.splitAmounts[currentUserId]! > 0 ? .red : .green)
                    Text("\(expense.date, formatter: DateFormatter.shortTime)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }

    private func getProfileImageUrlByID(_ id: String) -> String? {
        if let friend = firestoreService.friends.first(where: { $0.id == id }) {
            return friend.profileImageUrl
        } else if id == currentUserId {
            return firestoreService.currentUser?.profileImageUrl
        } else {
            return nil
        }
    }

    private func getFriendNameByID(_ id: String) -> String {
        if let friend = firestoreService.friends.first(where: { $0.id == id }) {
            return friend.name
        } else if id == currentUserId {
            return firestoreService.currentUser?.fullName ?? "You"
        } else {
            return "Unknown"
        }
    }
}

extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(viewModel: ActivityViewModel(firestoreService: FirestoreService()))
            .environmentObject(AuthService())
    }
}
