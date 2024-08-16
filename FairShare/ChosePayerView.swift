//import SwiftUI
//
//struct ChoosePayerView: View {
//    @Binding var selectedFriends: [Friend]
//    @Binding var selectedPayer: Friend?
//    var onDone: () -> Void
//
//    var body: some View {
//        VStack {
//            List {
//                ForEach(selectedFriends) { friend in
//                    HStack {
//                        if let imageUrl = friend.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
//                            AsyncImage(url: url) { phase in
//                                switch phase {
//                                case .empty:
//                                    ProgressView()
//                                case .success(let image):
//                                    image.resizable()
//                                        .frame(width: 50, height: 50)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.purple, lineWidth: 2))
//                                case .failure:
//                                    Image(systemName: "person.circle")
//                                        .resizable()
//                                        .frame(width: 50, height: 50)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.purple, lineWidth: 2))
//                                @unknown default:
//                                    Image(systemName: "person.circle")
//                                        .resizable()
//                                        .frame(width: 50, height: 50)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.purple, lineWidth: 2))
//                                }
//                            }
//                        } else {
//                            Image(systemName: "person.circle")
//                                .resizable()
//                                .frame(width: 50, height: 50)
//                                .clipShape(Circle())
//                                .overlay(Circle().stroke(Color.purple, lineWidth: 2))
//                        }
//                        Text(friend.name)
//                        Spacer()
//                        if selectedPayer == friend {
//                            Image(systemName: "checkmark")
//                        }
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        selectedPayer = friend
//                    }
//                }
//            }
//            Button(action: onDone) {
//                Text("Done")
//            }
//        }
//        .navigationTitle("Choose Payer")
//        .navigationBarItems(leading: Button("Cancel") {
//            selectedPayer = nil
//            onDone()
//        })
//    }
//}
