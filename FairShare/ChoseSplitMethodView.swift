//import SwiftUI
//
//struct ChooseSplitMethodView: View {
//    @Binding var amount: Double
//    @Binding var selectedSplitOption: SplitOption?
//    var friends: [Friend]
//    var onDone: () -> Void
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                List {
//                    ForEach(SplitOption.allCases, id: \.self) { option in
//                        HStack {
//                            Text(option.title(friendName: ""))
//                            Spacer()
//                            if selectedSplitOption == option {
//                                Image(systemName: "checkmark")
//                            }
//                        }
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            selectedSplitOption = option
//                        }
//                    }
//                }
//                .navigationTitle("Split Method")
//                .navigationBarItems(leading: Button("Cancel") {
//                    onDone()
//                }, trailing: Button("Done") {
//                    onDone()
//                })
//            }
//        }
//    }
//}
//
//
