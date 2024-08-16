import SwiftUI

struct FriendProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    @ObservedObject var firestoreService: FirestoreService
    var friend: Friend
    
    private var totalOwed: Double {
        firestoreService.expenses.filter { $0.participants.contains(friend.id ?? "") }
            .map { expense in
                if expense.paidBy == authService.user?.id {
                    return expense.splitAmounts[friend.id ?? ""] ?? 0.0
                } else {
                    return -(expense.splitAmounts[authService.user?.id ?? ""] ?? 0.0)
                }
            }
            .reduce(0, +)
    }
    
    private var sortedExpenses: [String: [Expense]] {
        Dictionary(grouping: firestoreService.expenses.filter { $0.participants.contains(friend.id ?? "") }) { expense in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: expense.date)
        }
    }
    
    var body: some View {
        VStack {
            headerView
            balanceSummary
            expensesList
            Spacer()
            settleUpButton
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#833ab4"), Color(hex: "#ffc857"), Color(hex: "#353535")]), startPoint: .leading, endPoint: .trailing)
                .frame(height: 150)

            // Back button
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color(hex: "#FFC857")))
                    }
                    Spacer()
                }
                .padding([.leading, .top], 20)
                Spacer()
            }

            // Profile picture, name, and balance summary
            VStack(alignment: .leading) {
                Spacer()
                HStack(alignment: .bottom) {
                    if let profileImageUrl = friend.profileImageUrl, let url = URL(string: profileImageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    Text(friend.name)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
                .padding(.leading, 30)
                .padding(.bottom,90)
            }
            .padding(.top, 90) // Move the profile picture and name up
        }
    }



    
    private var balanceSummary: some View {
        VStack {
            Text("Balance Summary")
                .font(.headline)
                .foregroundColor(.white)
            Text(totalOwed > 0 ? "You are owed \(totalOwed, specifier: "%.2f")" : "You owe \(abs(totalOwed), specifier: "%.2f")")
                .font(.title2)
                .bold()
                .foregroundColor(totalOwed > 0 ? .green : .red)
                .padding(.top, 2)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, -60)
    }
    
    private var expensesList: some View {
        ScrollView {
            LazyVStack {
                ForEach(sortedExpenses.keys.sorted(by: >), id: \.self) { month in
                    Section(header: Text(month).foregroundColor(.white).font(.headline).padding(.top, 8)) {
                        ForEach(sortedExpenses[month]?.sorted(by: { $0.date > $1.date }) ?? []) { expense in
                            VStack {
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                    VStack(alignment: .leading) {
                                        Text(expense.description)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Paid by \(expense.paidBy == authService.user?.id ? "You" : friend.name)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(expense.date, style: .time)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text(expense.paidBy == authService.user?.id
                                         ? (expense.splitAmounts[friend.id ?? ""]! > 0 ? "You are owed \(expense.splitAmounts[friend.id ?? ""]!, specifier: "%.2f")" : "You owe \(abs(expense.splitAmounts[friend.id ?? ""]!), specifier: "%.2f")")
                                         : (expense.splitAmounts[authService.user?.id ?? ""]! > 0 ? "You owe \(expense.splitAmounts[authService.user?.id ?? ""]!, specifier: "%.2f")" : "You are owed \(abs(expense.splitAmounts[authService.user?.id ?? ""]!), specifier: "%.2f")"))
                                    .foregroundColor(expense.paidBy == authService.user?.id
                                                     ? (expense.splitAmounts[friend.id ?? ""]! > 0 ? .green : .red)
                                                     : (expense.splitAmounts[authService.user?.id ?? ""]! > 0 ? .red : .green))
                                }
                                .padding()
                                Divider().background(Color.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
    
    private var settleUpButton: some View {
        Button(action: {
            // Present the SettleUpView
            let settleUpView = SettleUpView(friend: friend)
                .environmentObject(authService)
                .environmentObject(firestoreService)
            
            let settleUpViewController = UIHostingController(rootView: settleUpView)
            UIApplication.shared.windows.first?.rootViewController?.present(settleUpViewController, animated: true, completion: nil)
        }) {
            Text("Settle Up")
                .foregroundColor(.white)
                .padding()
                .frame(width: 150)
                .background(Color(hex: "#E6E6FA"))
                .cornerRadius(20)
        }
        .padding(.bottom,100)
    }
}
struct FriendProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FriendProfileView(firestoreService: FirestoreService(), friend: Friend(id: "123", name: "John Doe", email: "mohan@example.com", phoneNumber: "1234567890", profileImageUrl: "https://example.com/profile.jpg", amount: 0.0, isOwed: false))
            .environmentObject(AuthService())
    }
}
