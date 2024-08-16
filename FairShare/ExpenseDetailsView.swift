import SwiftUI

struct ExpenseDetailsView: View {
    @ObservedObject var firestoreService: FirestoreService
    @Binding var selectedFriends: [Friend]
    @Binding var description: String
    @Binding var amount: Double
    @Binding var selectedSplitOption: SplitOption?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService

    private var halfAmount: Double {
        return amount / 2.00
    }

    private var fullAmount: Double {
        return amount
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.green)
                }
                Spacer()
                Text("Expense details")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.black)

            Text("How was this expense split?")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top)

            ForEach(getSplitOptions()) { option in
                HStack {
                    overlappingProfileImages(friend: selectedFriends.first)
                    VStack(alignment: .leading) {
                        Text(option.title)
                            .foregroundColor(.white)
                        Text(option.subtitle)
                            .foregroundColor(option.subtitleColor)
                    }
                    Spacer()
                    if selectedSplitOption == option.splitOption {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 5)
                .onTapGesture {
                    selectedSplitOption = option.splitOption
                }
            }

            Spacer()

            Button(action: {
                // Navigate to more options view if needed
            }) {
                Text("More options")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func getSplitOptions() -> [SplitOptionView] {
        guard let friend = selectedFriends.first else { return [] }
        
        return [
            SplitOptionView(
                splitOption: .paidByYouAndSplitEqually,
                title: "Paid by You and Split Equally",
                subtitle: "\(friend.name) owes you $\(halfAmount)",
                subtitleColor: .green
            ),
            SplitOptionView(
                splitOption: .youAreOwedFullAmount,
                title: "You are Owed Full Amount",
                subtitle: "\(friend.name) owes you $\(fullAmount)",
                subtitleColor: .green
            ),
            SplitOptionView(
                splitOption: .friendPaidAndSplitEqually,
                title: "\(friend.name) Paid and Split Equally",
                subtitle: "You owe \(friend.name) $\(halfAmount)",
                subtitleColor: .red
            ),
            SplitOptionView(
                splitOption: .friendPaidFullAmount,
                title: "\(friend.name) Paid Full Amount",
                subtitle: "You owe \(friend.name) $\(fullAmount)",
                subtitleColor: .red
            )
        ]
    }

    
    struct SplitOptionView: Identifiable {
        let id = UUID()
        let splitOption: SplitOption
        let title: String
        let subtitle: String
        let subtitleColor: Color
    }

    private func overlappingProfileImages(friend: Friend?) -> some View {
        ZStack {
            if let profileImageUrl = authService.user?.profileImageUrl, let url = URL(string: profileImageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .offset(x: 20)
            }

            if let friend = friend, let profileImageUrl = friend.profileImageUrl, let url = URL(string: profileImageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.trailing, 20)
    }
}

struct ExpenseDetailsView_Previews: PreviewProvider {
    @State static var selectedFriends = [Friend(id: "1", name: "John Doe", email: "john@example.com", phoneNumber: "", profileImageUrl: nil, amount: 0.0, isOwed: false)]
    @State static var description = "Dinner"
    @State static var amount = 20.0
    @State static var selectedSplitOption: SplitOption? = nil

    static var previews: some View {
        ExpenseDetailsView(
            firestoreService: FirestoreService(),
            selectedFriends: $selectedFriends,
            description: $description,
            amount: $amount,
            selectedSplitOption: $selectedSplitOption
        )
        .environmentObject(AuthService())
    }
}
