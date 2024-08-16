import SwiftUI

struct FriendSelectionView: View {
    @ObservedObject var firestoreService: FirestoreService
    @Binding var selectedFriends: [Friend]
    @State private var searchQuery: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                // Selected friends
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedFriends) { friend in
                            VStack {
                                if let imageUrl = friend.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    }
                                } else {
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                }
                                Text(friend.name)
                                    .font(.caption)
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
                    .padding()
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search name, groups", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()

                // Friends list
                List {
                    ForEach(firestoreService.friends.filter {
                        searchQuery.isEmpty || $0.name.lowercased().contains(searchQuery.lowercased())
                    }) { friend in
                        HStack {
                            Text(friend.name)
                            Spacer()
                            if selectedFriends.contains(where: { $0.id == friend.id }) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedFriends.contains(where: { $0.id == friend.id }) {
                                selectedFriends.removeAll { $0.id == friend.id }
                            } else {
                                selectedFriends.append(friend)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Add Participants")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct FriendSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FriendSelectionView(firestoreService: FirestoreService(), selectedFriends: .constant([]))
    }
}
