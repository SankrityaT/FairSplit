import SwiftUI

// Define the colors based on the new palette
let darkBackground = Color(hex: "#1C1C1E")
let lightPurple = Color(hex: "#9370DB")
let mediumPurple = Color(hex: "#C8A8E9")
let darkPurple = Color(hex: "#3C3C3C")

struct MainDashboardView: View {
    @EnvironmentObject var authService: AuthService
    @ObservedObject var firestoreService: FirestoreService
    @State private var isAddFriendPresented = false
    @State private var searchText: String = ""
    @State private var selectedIndex: Int = 0
    @State private var isSearching: Bool = false
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var activityViewModel: ActivityViewModel

    init(firestoreService: FirestoreService) {
        self.firestoreService = firestoreService
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(firestoreService: firestoreService))
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(firestoreService: firestoreService))
    }

    var body: some View {
        NavigationView {
            ZStack {
                darkBackground.edgesIgnoringSafeArea(.all) // Use the dark background color
                VStack {
                    topBar
                    if isSearching {
                        searchResultsList
                    } else {
                        friendsList
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $isAddFriendPresented) {
                AddFriendView(firestoreService: firestoreService)
                    .environmentObject(authService)
            }
            .navigationBarHidden(true)
            .onAppear {
                if let userID = authService.user?.id {
                    Task {
                        await fetchAllData(userID: userID)
                    }
                }
            }
        }
    }

    private func fetchAllData(userID: String) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await firestoreService.fetchFriends(for: userID) { _ in }
            }
            group.addTask {
                await firestoreService.fetchExpenses(for: userID) { _ in }
            }
            group.addTask {
                await firestoreService.fetchRecentActivities(for: userID) { _ in }
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            if !isSearching {
                Text("FairShare")
                    .font(.title)
                    .foregroundColor(lightPurple)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }

            Spacer()
            if isSearching {
                CustomTextFieldSearch(text: $searchText, placeholder: "Search for Expense", iconName: "magnifyingglass")
                    .transition(.opacity)
                    .onChange(of: searchText) { newValue in
                        searchViewModel.search(query: newValue)
                    }
            }

            Button(action: {
                withAnimation {
                    if isSearching {
                        isSearching = false
                    } else {
                        searchText = ""
                        isSearching = true
                    }
                }
            }) {
                Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(mediumPurple)
            }

            Button(action: {
                isAddFriendPresented.toggle()
            }) {
                Image(systemName: "person.badge.plus")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(mediumPurple)
            }

            Button(action: {
                let activityView = ActivityView(viewModel: activityViewModel)
                let activityViewController = UIHostingController(rootView: activityView.environmentObject(authService))
                UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
            }) {
                Image(systemName: "bell.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(mediumPurple)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(darkBackground)
    }

    private var friendsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(firestoreService.friends, id: \.id) { friend in
                    NavigationLink(destination: FriendProfileView(firestoreService: firestoreService, friend: friend)
                        .environmentObject(authService)) {
                        friendRow(friend: friend)
                    }
                }
            }
        }
    }

    var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(searchViewModel.searchResults) { result in
                    switch result {
                    case .friend(let friend):
                        NavigationLink(destination: FriendProfileView(firestoreService: firestoreService, friend: friend)
                            .environmentObject(authService)) {
                                friendRow(friend: friend)
                            }
                    case .expense(let expense):
                        expenseRow(expense: expense)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    private func expenseRow(expense: Expense) -> some View {
        VStack(alignment: .leading) {
            Text(expense.description)
                .font(.headline)
                .foregroundColor(.white)
            Text("Total: \(expense.amount, specifier: "%.2f")")
                .foregroundColor(.white)
            Text(expense.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(darkPurple.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }

    private func calculateOwedAmount(for friendID: String) -> Double {
        var totalAmount: Double = 0.0

        for expense in firestoreService.expenses {
            if expense.paidBy == authService.user?.id {
                totalAmount += expense.splitAmounts[friendID] ?? 0.0
            } else if expense.paidBy == friendID {
                totalAmount -= expense.splitAmounts[authService.user?.id ?? ""] ?? 0.0
            }
        }
        return totalAmount
    }

    private func friendRow(friend: Friend) -> some View {
        HStack {
            if let profileImageUrl = friend.profileImageUrl, let url = URL(string: profileImageUrl) {
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
                        .foregroundColor(mediumPurple)
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .foregroundColor(mediumPurple)
            }

            VStack(alignment: .leading) {
                Text(friend.name)
                    .font(.headline)
                    .foregroundColor(.white)
                let totalOwed = calculateOwedAmount(for: friend.id ?? "")
                if totalOwed == 0 {
                    Text("No expenses")
                        .foregroundColor(.white)
                } else {
                    Text(totalOwed > 0 ? "Owes you \(totalOwed, specifier: "%.2f")" : "You owe \(abs(totalOwed), specifier: "%.2f")")
                        .foregroundColor(totalOwed > 0 ? .green : .red)
                }
            }
            Spacer()
            
            // Add this Image view for the chevron
            Image(systemName: "chevron.right")
                .foregroundColor(mediumPurple)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 4) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
