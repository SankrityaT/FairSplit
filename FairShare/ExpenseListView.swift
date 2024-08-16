//import SwiftUI
//
//struct ExpenseListItemView: View {
//    var friend: Friend
//
//    var body: some View {
//        HStack {
//            if let profileImageUrl = friend.profileImageUrl, let url = URL(string: profileImageUrl) {
//                AsyncImage(url: url) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 50, height: 50)
//                        .clipShape(Circle())
//                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                        .shadow(radius: 5)
//                } placeholder: {
//                    Circle()
//                        .fill(Color.gray)
//                        .frame(width: 50, height: 50)
//                }
//            } else {
//                Circle()
//                    .fill(Color.gray)
//                    .frame(width: 50, height: 50)
//            }
//
//            VStack(alignment: .leading, spacing: 5) {
//                Text(friend.name)
//                    .font(.headline)
//                Text(friend.isOwed ? "owes you" : "you owe")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                Text("$\(friend.amount, specifier: "%.2f")")
//                    .font(.subheadline)
//                    .foregroundColor(friend.isOwed ? .green : .red)
//            }
//
//            Spacer()
//
//            Text(friend.isOwed ? "owes you" : "you owe")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//        .padding(.vertical, 10)
//    }
//}
//
//struct ExpenseListItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpenseListItemView(friend: Friend(id: "1", name: "John Doe", email: "johndoe@example.com", phoneNumber: "1234567890", amount: 25.68, isOwed: false, profileImageUrl: "https://example.com/profile.jpg"))
//    }
//}
