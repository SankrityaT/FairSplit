import SwiftUI

struct CustomNavigationBar: View {
    @Binding var selectedIndex: Int
    var authService: AuthService
    var firestoreService: FirestoreService

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(imageName: "house.fill", index: 0, selectedIndex: $selectedIndex, title: "Home") {
                firestoreService.fetchFriends(for: authService.user?.id ?? "") { friends in
                    print("Fetched friends: \(friends)")
                }
                print("Home button tapped")
            }
            AddExpenseButton(selectedIndex: $selectedIndex, authService: authService, firestoreService: firestoreService)
            ProfileTabButton(index: 2, selectedIndex: $selectedIndex, authService: authService, title: "Account")
        }
        .frame(height: 60)
        .background(Color(hex: "#353535").opacity(0.8))
        .cornerRadius(30)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .shadow(radius: 10)
    }
}

struct TabBarButton: View {
    let imageName: String
    let index: Int
    @Binding var selectedIndex: Int
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: {
            selectedIndex = index
            print("Tab selected: \(index)")
            action()
        }) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(selectedIndex == index ? .white : .gray)
                if selectedIndex == index {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                }
            }
            .frame(width: 100, height: 60) // Fixed width and height for proper alignment
            .background(
                selectedIndex == index ? AnyView(Color(hex: "#9370DB").frame(height: 60).clipShape(Capsule())) : AnyView(Color.clear)
            )
            .cornerRadius(30) // Match the corner radius of the nav bar
        }
    }
}

struct AddExpenseButton: View {
    @Binding var selectedIndex: Int
    var authService: AuthService
    var firestoreService: FirestoreService

    var body: some View {
        Button(action: {
            selectedIndex = 1
            firestoreService.fetchExpenses(for: authService.user?.id ?? "") { expenses in
                print("Fetched expenses: \(expenses)")
            }
            print("Add Expense button tapped")
        }) {
            VStack {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(selectedIndex == 1 ? .white : .gray)
                if selectedIndex == 1 {
                    Text("Add Expense")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                }
            }
            .frame(width: 100, height: 60) // Fixed width and height for proper alignment
            .background(
                selectedIndex == 1 ? AnyView(Color(hex: "#9370DB").frame(height: 60).clipShape(Capsule())) : AnyView(Color.clear)
            )
            .cornerRadius(30) // Match the corner radius of the nav bar
        }
    }
}

struct ProfileTabButton: View {
    let index: Int
    @Binding var selectedIndex: Int
    var authService: AuthService
    var title: String

    var body: some View {
        Button(action: {
            selectedIndex = index
            print("Profile button tapped")
        }) {
            VStack {
                if let profileImageUrl = authService.user?.profileImageUrl, let url = URL(string: profileImageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(selectedIndex == index ? Color.white : Color.gray, lineWidth: 2))
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(selectedIndex == index ? Color.white : Color.gray, lineWidth: 2))
                            .foregroundColor(selectedIndex == index ? .white : .gray)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(selectedIndex == index ? Color.white : Color.gray, lineWidth: 2))
                        .foregroundColor(selectedIndex == index ? .white : .gray)
                }
                if selectedIndex == index {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                }
            }
            .frame(width: 100, height: 60) // Fixed width and height for proper alignment
            .background(
                selectedIndex == index ? AnyView(Color(hex: "#9370DB").frame(height: 60).clipShape(Capsule())) : AnyView(Color.clear)
            )
            .cornerRadius(30) // Match the corner radius of the nav bar
        }
    }
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationBar(selectedIndex: .constant(0), authService: AuthService(), firestoreService: FirestoreService())
    }
}
