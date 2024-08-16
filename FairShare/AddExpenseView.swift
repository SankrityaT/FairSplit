import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var firestoreService: FirestoreService
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    @State private var description: String = ""
    @State private var amountText: String = ""
    @State private var selectedFriends: [Friend] = []
    @State private var showFriendSelection: Bool = false
    @State private var showSplitOptions: Bool = false
    @State private var showChoosePayer: Bool = false
    @State private var showSuccessSplash: Bool = false
    @State private var selectedSplitOption: SplitOption? = .paidByYouAndSplitEqually
    @State private var selectedPayer: Friend? = nil
    @State private var selectedSplitFriends: Set<String> = []

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    header
                    Spacer()
                    descriptionField
                    amountField
                    if !selectedFriends.isEmpty {
                        splitOptionButton
                    }
                    friendsSection
                    Spacer()
                }
                .padding()
                .background(Color(hex: "#1C1C1E").edgesIgnoringSafeArea(.all))
                .navigationBarHidden(true)
                .sheet(isPresented: $showFriendSelection) {
                    AddParticipantsView(firestoreService: firestoreService, selectedFriends: $selectedFriends, onDone: {
                        showFriendSelection = false
                    })
                    .environmentObject(authService)
                }
                .sheet(isPresented: $showChoosePayer) {
                    ChoosePayerView(friends: [authService.user!.toFriend()] + selectedFriends, selectedPayer: $selectedPayer, onDone: {
                        showChoosePayer = false
                    })
                    .environmentObject(authService)
                }
                .sheet(isPresented: $showSplitOptions) {
                    ChooseSplitMethodView(
                        amount: .constant(Double(amountText) ?? 0),
                        selectedSplitOption: $selectedSplitOption,
                        friends: [authService.user!.toFriend()] + selectedFriends,
                        selectedSplitFriends: $selectedSplitFriends,
                        onDone: {
                            showSplitOptions = false
                        }
                    )
                    .environmentObject(authService)
                }

                if showSuccessSplash {
                    successSplash
                }
            }
            .onAppear {
                resetFields()
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }

    private var header: some View {
        HStack {
            Button(action: {
                navigateToMainDashboardView()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                    .clipShape(Circle())
            }
            Spacer()
            Text("Add an expense")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                saveExpense()
            }) {
                Text("Save")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(20)
            }
        }
        .padding()
    }

    private var descriptionField: some View {
        CustomIconTextField(icon: "doc.text.fill", placeholder: "Enter a description", text: $description)
    }

    private var amountField: some View {
        CustomIconTextField(icon: "dollarsign.circle.fill", placeholder: "0.00", text: $amountText, keyboardType: .decimalPad)
    }

    private var splitOptionButton: some View {
        VStack {
            if selectedFriends.count > 1 {
                HStack {
                    Button(action: {
                        showChoosePayer = true
                    }) {
                        Text("You")
                            .foregroundColor(Color(hex: "#9370DB"))
                            .padding(.vertical)
                    }
                    Text("and")
                        .foregroundColor(Color.white)
                        .padding(.vertical)
                    Button(action: {
                        showSplitOptions = true
                    }) {
                        Text("Split Equally")
                            .foregroundColor(Color(hex: "#9370DB"))
                            .padding(.vertical)
                    }
                }
            } else {
                Button(action: {
                    showSplitOptions = true
                }) {
                    Text(selectedSplitOption?.title(friendName: selectedFriends.first?.name ?? "") ?? "Paid by you and split equally")
                        .foregroundColor(Color(hex: "#9370DB"))
                        .padding(.vertical)
                }
            }
        }
    }

    private var friendsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("With you and:")
                    .foregroundColor(.white)
                    .padding(.top, 25)
                Spacer()
                Button(action: {
                    showFriendSelection = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#9370DB"))
                        .padding(.top, 25)
                }
            }
            .padding(.horizontal)

            if !selectedFriends.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedFriends) { friend in
                            friendView(friend: friend)
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func friendView(friend: Friend) -> some View {
        VStack {
            if let imageUrl = friend.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            Text(friend.name)
                .font(.caption)
                .foregroundColor(.white)
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

    private var successSplash: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(Color(hex: "#9370DB"))
            Text("Expense added successfully")
                .font(.title)
                .foregroundColor(Color(hex: "#9370DB"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.8))
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut) {
                    navigateToMainDashboardView()
                }
            }
        }
    }

    private func saveExpense() {
        guard !description.isEmpty, let amount = Double(amountText), amount > 0, !selectedFriends.isEmpty, let splitOption = selectedSplitOption else {
            // Show error message
            return
        }

        var splitAmounts: [String: Double] = [:]
        let userID = authService.user?.id ?? ""

        if selectedFriends.count == 1 {
            // Existing logic for two people
            var amountOwed: Double = 0
            switch splitOption {
            case .paidByYouAndSplitEqually:
                let splitAmount = amount / 2.0
                for friend in selectedFriends {
                    splitAmounts[friend.id ?? ""] = splitAmount
                }
                splitAmounts[userID] = splitAmount
                amountOwed = splitAmount

            case .youAreOwedFullAmount:
                for friend in selectedFriends {
                    splitAmounts[friend.id ?? ""] = amount
                }
                splitAmounts[userID] = 0.0
                amountOwed = amount

            case .friendPaidAndSplitEqually:
                let splitAmount = amount / 2.0
                for friend in selectedFriends {
                    splitAmounts[friend.id ?? ""] = splitAmount
                }
                splitAmounts[userID] = splitAmount
                amountOwed = splitAmount

            case .friendPaidFullAmount:
                for friend in selectedFriends {
                    splitAmounts[friend.id ?? ""] = 0.0
                }
                splitAmounts[userID] = amount
                amountOwed = amount
            }

            let expense = Expense(
                description: description,
                amount: amount,
                amountOwed: amountOwed,
                participants: selectedFriends.map { $0.id ?? "" } + [userID],
                splitAmounts: splitAmounts,
                date: Date(),
                splitOption: splitOption,
                paidBy: splitOption.paidBy(for: userID, friends: selectedFriends)
            )

            firestoreService.addExpense(expense) { success in
                if success {
                    showSuccessSplash = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccessSplash = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    // Show error message
                }
            }
        } else {
            // New logic for more than two people
            let allParticipants = [authService.user!.toFriend()] + selectedFriends
            let payer = selectedPayer?.id ?? userID
            let totalAmount = Double(amountText) ?? 0.0
            let splitCount = Double(selectedSplitFriends.count)
            let splitAmount = totalAmount / splitCount

            for friend in selectedFriends {
                splitAmounts[friend.id ?? ""] = selectedSplitFriends.contains(friend.id ?? "") ? splitAmount : 0.0
            }
            splitAmounts[userID] = selectedSplitFriends.contains(userID) ? splitAmount : 0.0

            let expense = Expense(
                description: description,
                amount: amount,
                amountOwed: splitAmounts[userID] ?? 0.0,
                participants: allParticipants.map { $0.id ?? "" },
                splitAmounts: splitAmounts,
                date: Date(),
                splitOption: splitOption,
                paidBy: payer
            )

            firestoreService.addExpense(expense) { success in
                if success {
                    showSuccessSplash = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccessSplash = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    // Show error message
                }
            }
        }
    }

    private func navigateToMainDashboardView() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = UIHostingController(rootView: MainDashboardView(firestoreService: firestoreService).environmentObject(authService))
        window.makeKeyAndVisible()
    }

    private func resetFields() {
        selectedFriends = []
        amountText = ""
        description = ""
    }

    struct AddExpenseView_Previews: PreviewProvider {
        static var previews: some View {
            AddExpenseView(firestoreService: FirestoreService())
                .environmentObject(AuthService())
        }
    }
}

struct CustomIconTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#1C1C1E"))
                    .frame(width: 50, height: 50)
                    .shadow(radius: 4)
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: "#9370DB"))
            }
            VStack(alignment: .leading) {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                Divider()
                    .background(Color(hex: "#9370DB"))
                    .frame(height: 2)
            }
        }
        .padding(.horizontal)
    }
}

struct ChoosePayerView: View {
    var friends: [Friend]
    @Binding var selectedPayer: Friend?
    var onDone: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(friends) { friend in
                        HStack {
                            if let imageUrl = friend.profileImageUrl, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } else if phase.error != nil {
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } else {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
                            Text(friend.name)
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            if selectedPayer?.id == friend.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .onTapGesture {
                            selectedPayer = friend
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("Choose payer", displayMode: .inline)
                .navigationBarItems(leading: Button("Cancel") {
                    onDone()
                }, trailing: Button("Done") {
                    onDone()
                })
            }
        }
    }
}

struct ChooseSplitMethodView: View {
    @Binding var amount: Double
    @Binding var selectedSplitOption: SplitOption?
    var friends: [Friend]
    @Binding var selectedSplitFriends: Set<String>
    var onDone: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(friends) { friend in
                        HStack {
                            if let imageUrl = friend.profileImageUrl, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } else if phase.error != nil {
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } else {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
                            Text(friend.name)
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            if selectedSplitFriends.contains(friend.id ?? "") {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .onTapGesture {
                            if selectedSplitFriends.contains(friend.id ?? "") {
                                selectedSplitFriends.remove(friend.id ?? "")
                            } else {
                                selectedSplitFriends.insert(friend.id ?? "")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("Split options", displayMode: .inline)
                .navigationBarItems(leading: Button("Cancel") {
                    onDone()
                }, trailing: Button("Done") {
                    onDone()
                })
            }
        }
    }
}

// Extension to convert User to Friend
extension User {
    func toFriend() -> Friend {
        return Friend(
            id: self.id,
            name: self.fullName ?? "",
            email: self.email ?? "",
            phoneNumber: self.phoneNumber ?? "",
            profileImageUrl: self.profileImageUrl ?? "",
            amount: 0.0,
            isOwed: false
        )
    }
}

// Add other required structures and extensions here...
