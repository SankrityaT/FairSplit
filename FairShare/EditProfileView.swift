//
//  EditProfileView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/17/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @Binding var userFullName: String
    @Binding var userEmail: String
    @Binding var userPhoneNumber: String
    @Binding var userTimeZone: String
    @Binding var userCurrency: String
    @Binding var userLanguage: String

    @State private var tempFullName: String
    @State private var tempEmail: String
    @State private var tempPhoneNumber: String
    @State private var tempTimeZone: String
    @State private var tempCurrency: String
    @State private var tempLanguage: String

    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode

    let currencies = ["USD", "EUR", "GBP", "INR", "JPY"] // Add more as needed
    let languages = ["English", "Spanish", "French", "German", "Chinese"] // Add more as needed

    init(userFullName: Binding<String>, userEmail: Binding<String>, userPhoneNumber: Binding<String>, userTimeZone: Binding<String>, userCurrency: Binding<String>, userLanguage: Binding<String>) {
        self._userFullName = userFullName
        self._userEmail = userEmail
        self._userPhoneNumber = userPhoneNumber
        self._userTimeZone = userTimeZone
        self._userCurrency = userCurrency
        self._userLanguage = userLanguage

        self._tempFullName = State(initialValue: userFullName.wrappedValue)
        self._tempEmail = State(initialValue: userEmail.wrappedValue)
        self._tempPhoneNumber = State(initialValue: userPhoneNumber.wrappedValue)
        self._tempTimeZone = State(initialValue: userTimeZone.wrappedValue)
        self._tempCurrency = State(initialValue: userCurrency.wrappedValue)
        self._tempLanguage = State(initialValue: userLanguage.wrappedValue)
    }

    var body: some View {
        Form {
            Section(header: Text("User Info")) {
                TextField("Full name", text: $tempFullName)
                TextField("Email address", text: $tempEmail)
                TextField("Phone number", text: $tempPhoneNumber)
            }

            Section(header: Text("Preferences")) {
                Picker("Time Zone", selection: $tempTimeZone) {
                    ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { timeZone in
                        Text(timeZone).tag(timeZone)
                    }
                }
                Picker("Currency", selection: $tempCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                Picker("Language", selection: $tempLanguage) {
                    ForEach(languages, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
            }

            Button(action: saveChanges) {
                Text("Save changes")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Edit Profile")
    }

    private func saveChanges() {
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = tempFullName
        changeRequest.commitChanges { error in
            if let error = error {
                errorMessage = "Error updating profile: \(error.localizedDescription)"
            } else {
                saveUserData(user: user)
                userFullName = tempFullName
                userEmail = tempEmail
                userPhoneNumber = tempPhoneNumber
                userTimeZone = tempTimeZone
                userCurrency = tempCurrency
                userLanguage = tempLanguage
                withAnimation {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func saveUserData(user: FirebaseAuth.User) {
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData([
            "fullName": tempFullName,
            "email": tempEmail,
            "phoneNumber": tempPhoneNumber,
            "timeZone": tempTimeZone,
            "currency": tempCurrency,
            "language": tempLanguage
        ]) { error in
            if let error = error {
                errorMessage = "Error saving user data: \(error.localizedDescription)"
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(
            userFullName: .constant("Test User"),
            userEmail: .constant("test@example.com"),
            userPhoneNumber: .constant("1234567890"),
            userTimeZone: .constant(""),
            userCurrency: .constant("USD"),
            userLanguage: .constant("English")
        )
    }
}
