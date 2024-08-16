//import SwiftUI
//
//struct SplitOptionsView: View {
//    @ObservedObject var firestoreService: FirestoreService
//    @EnvironmentObject var authService: AuthService
//    @Binding var selectedFriends: [Friend]
//    @Binding var description: String
//    @Binding var amount: Double
//    @Binding var selectedSplitOption: SplitOption? // Add this binding
//    @State private var splitEqually: Bool = true
//    @State private var splitByAmount: Bool = false
//    @State private var splitByPercentage: Bool = false
//    @State private var amounts: [String: Double] = [:]
//    @State private var percentages: [String: Double] = [:]
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("Split Options")
//                    .font(.largeTitle)
//                    .padding()
//
//                HStack {
//                    Button(action: {
//                        splitEqually = true
//                        splitByAmount = false
//                        splitByPercentage = false
//                        selectedSplitOption = .paidByYouAndSplitEqually // Set the selected split option
//                    }) {
//                        VStack {
//                            Image(systemName: "equal")
//                            Text("Equally")
//                        }
//                    }
//                    .padding()
//                    .background(splitEqually ? Color.green : Color.gray)
//                    .cornerRadius(10)
//
//                    Button(action: {
//                        splitEqually = false
//                        splitByAmount = true
//                        splitByPercentage = false
//                        selectedSplitOption = .youAreOwedFullAmount // Set the selected split option
//                    }) {
//                        VStack {
//                            Image(systemName: "number")
//                            Text("By Amount")
//                        }
//                    }
//                    .padding()
//                    .background(splitByAmount ? Color.green : Color.gray)
//                    .cornerRadius(10)
//
//                    Button(action: {
//                        splitEqually = false
//                        splitByAmount = false
//                        splitByPercentage = true
//                        selectedSplitOption = .friendPaidAndSplitEqually // Set the selected split option
//                    }) {
//                        VStack {
//                            Image(systemName: "percent")
//                            Text("By Percentage")
//                        }
//                    }
//                    .padding()
//                    .background(splitByPercentage ? Color.green : Color.gray)
//                    .cornerRadius(10)
//                }
//                .padding()
//
//                if splitEqually {
//                    Text("Split equally among selected friends")
//                        .padding()
//                } else if splitByAmount {
//                    VStack {
//                        ForEach(selectedFriends) { friend in
//                            HStack {
//                                Text(friend.name)
//                                TextField("Amount", value: $amounts[friend.id ?? ""], formatter: NumberFormatter())
//                                    .keyboardType(.decimalPad)
//                            }
//                            .padding()
//                        }
//                    }
//                } else if splitByPercentage {
//                    VStack {
//                        ForEach(selectedFriends) { friend in
//                            HStack {
//                                Text(friend.name)
//                                TextField("Percentage", value: $percentages[friend.id ?? ""], formatter: NumberFormatter())
//                                    .keyboardType(.decimalPad)
//                            }
//                            .padding()
//                        }
//                    }
//                }
//
//                Spacer()
//
//                Button(action: {
//                    saveExpense()
//                }) {
//                    Text("Done")
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding()
//            }
//            .navigationBarItems(leading: Button(action: {
//                presentationMode.wrappedValue.dismiss()
//            }) {
//                Text("Cancel")
//            })
//        }
//    }
//
//    private func saveExpense() {
//        guard !description.isEmpty, amount > 0, !selectedFriends.isEmpty else {
//            // Show error message
//            return
//        }
//
//        var splitAmounts: [String: Double] = [:]
//
//        if splitEqually {
//            let splitAmount = amount / Double(selectedFriends.count + 1) // Including the current user
//            for friend in selectedFriends {
//                splitAmounts[friend.id ?? ""] = splitAmount
//            }
//            splitAmounts[authService.user?.id ?? ""] = splitAmount // Add the current user
//        } else if splitByAmount {
//            for friend in selectedFriends {
//                if let friendAmount = amounts[friend.id ?? ""] {
//                    splitAmounts[friend.id ?? ""] = friendAmount
//                }
//            }
//            splitAmounts[authService.user?.id ?? ""] = amount - splitAmounts.values.reduce(0, +)
//        } else if splitByPercentage {
//            for friend in selectedFriends {
//                if let friendPercentage = percentages[friend.id ?? ""] {
//                    splitAmounts[friend.id ?? ""] = amount * friendPercentage / 100
//                }
//            }
//            splitAmounts[authService.user?.id ?? ""] = amount - splitAmounts.values.reduce(0, +)
//        }
//
//        let expense = Expense(
//            description: description,
//            amount: amount,
//            participants: selectedFriends.map { $0.id ?? "" } + [authService.user?.id ?? ""],
//            splitAmounts: splitAmounts,
//            date: Date(),
//            splitOption: selectedSplitOption,
//            paidBy: authService.user?.id ?? "" // Add the current user ID as paidBy
//        )
//
//        firestoreService.addExpense(expense) { success in
//            if success {
//                presentationMode.wrappedValue.dismiss()
//            } else {
//                // Show error message
//            }
//        }
//    }
//}
