import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var authService: AuthService
    @ObservedObject var firestoreService: FirestoreService
    @State private var searchQuery = ""
    @State private var searchResults: [User] = []
    @State private var selectedFriends: [User] = []
    @State private var showSuccess = false
    @State private var navigateToDashboard = false
    @Environment(\.presentationMode) var presentationMode

    let darkBackground = Color(hex: "#1C1C1E")
    let lightPurple = Color(hex: "#8E8E93")
    let mediumPurple = Color(hex: "#5E5CE6")
    let darkPurple = Color(hex: "#3C3C3C")
    let textColor = Color.white

    var body: some View {
        NavigationView {
            VStack {
                // Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                .padding(.top)

                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add Friend")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Search and select friends to add.")
                        .foregroundColor(lightPurple)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal)

                // Search Field
                HStack {
                    TextField("Search friends by email", text: $searchQuery, onEditingChanged: { _ in
                        firestoreService.searchUsers(query: searchQuery) { users in
                            searchResults = users.filter { $0.id != authService.user?.id }
                        }
                    })
                    .padding()
                    .background(darkPurple)
                    .cornerRadius(20)
                    .foregroundColor(textColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(mediumPurple, lineWidth: 1)
                    )
                    .padding(.leading)
                    
                    Button(action: {
                        firestoreService.searchUsers(query: searchQuery) { users in
                            searchResults = users.filter { $0.id != authService.user?.id }
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding()
                            .background(mediumPurple)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .padding(.trailing)
                }
                .padding(.horizontal)

                // Animation or Selected Friends
                if selectedFriends.isEmpty && firestoreService.friends.isEmpty {
                    if searchQuery.isEmpty {
                        Spacer()
                        VStack {
                            Text("Oops! Looks like it's lonely up here.")
                                .foregroundColor(lightPurple)
                            Text("Add friends to make it lively.")
                                .foregroundColor(lightPurple)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 100)
                        Spacer()
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(selectedFriends) { friend in
                                VStack {
                                    if let imageUrl = friend.profileImageUrl, let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            Image(systemName: "person.circle")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .foregroundColor(lightPurple)
                                        }
                                    } else {
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .foregroundColor(lightPurple)
                                    }
                                    Text(friend.fullName ?? "")
                                        .font(.caption)
                                        .foregroundColor(textColor)
                                }
                                .padding(4)
                                .overlay(
                                    Button(action: {
                                        selectedFriends.removeAll { $0.id == friend.id }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .offset(x: 20, y: -20)
                                )
                            }
                        }
                    }
                    .padding()
                }
                
                // List of already added friends
                if !firestoreService.friends.isEmpty && searchQuery.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Friend List")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                            .padding(.horizontal)
                        
                        ScrollView {
                            ForEach(firestoreService.friends) { friend in
                                friendRow(friend: friend)
                            }
                        }
                    }
                }

                // Search Results
                if !searchResults.isEmpty {
                    List(searchResults) { user in
                        HStack {
                            if let profileImageUrl = user.profileImageUrl, let url = URL(string: profileImageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                        .foregroundColor(lightPurple)
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .foregroundColor(lightPurple)
                            }
                            VStack(alignment: .leading) {
                                Text(user.fullName ?? "")
                                Text(user.email ?? "")
                            }
                            .foregroundColor(textColor)
                            Spacer()
                            if firestoreService.friends.contains(where: { $0.id == user.id }) {
                                HStack {
                                    Text("Friend already added")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            } else {
                                Button(action: {
                                    if !selectedFriends.contains(where: { $0.id == user.id }) {
                                        selectedFriends.append(user)
                                    }
                                }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(mediumPurple)
                                }
                            }
                        }
                        .listRowBackground(darkBackground)
                    }
                    .listStyle(PlainListStyle())
                    .background(darkBackground)
                }
                
                Spacer()

                // Done Button
                Button(action: {
                    for friend in selectedFriends {
                        let friendData = Friend(
                            id: friend.id,
                            name: friend.fullName ?? "",
                            email: friend.email ?? "",
                            phoneNumber: friend.phoneNumber ?? "",
                            profileImageUrl: friend.profileImageUrl ?? "",
                            amount: 0.0,
                            isOwed: false
                        )
                        firestoreService.addFriend(friend: friendData) { success in
                            if success {
                                withAnimation {
                                    showSuccess = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation {
                                        showSuccess = false
                                        navigateToDashboard = true
                                    }
                                }
                            } else {
                                print("Failed to add friend")
                            }
                        }
                    }
                }) {
                    Text("Done")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(mediumPurple)
                        .cornerRadius(20)
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .background(darkBackground.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if showSuccess {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green)
                            Text("Friend added successfully!")
                                .foregroundColor(.white)
                        }
                        .frame(width: 150, height: 150)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(20)
                        .transition(.scale)
                    }
                }
            )
            .fullScreenCover(isPresented: $navigateToDashboard) {
                MainDashboardView(firestoreService: firestoreService)
                    .environmentObject(authService)
            }
        }
    }

    // Function to display friend row
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
                Text(friend.email)
                    .foregroundColor(lightPurple)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(darkPurple)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendView(firestoreService: FirestoreService())
            .environmentObject(AuthService())
    }
}

// Utility to convert hex color code to SwiftUI Color
