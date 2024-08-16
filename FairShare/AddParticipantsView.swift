import SwiftUI

struct AddParticipantsView: View {
    @ObservedObject var firestoreService: FirestoreService
    @Binding var selectedFriends: [Friend]
    var onDone: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Add Participants")
                        .font(.title)
                        .padding()
                    Spacer()
                    Button(action: {
                        onDone()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                    }
                }

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
                }
                .padding()

                TextField("Search name, groups", text: .constant(""))
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                List(firestoreService.friends) { friend in
                    HStack {
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
                        Spacer()
                        if selectedFriends.contains(where: { $0.id == friend.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .onTapGesture {
                        if let index = selectedFriends.firstIndex(where: { $0.id == friend.id }) {
                            selectedFriends.remove(at: index)
                        } else {
                            selectedFriends.append(friend)
                        }
                    }
                }

                Spacer()
            }
            .background(Color.black)
            .navigationBarHidden(true)
        }
    }
}
