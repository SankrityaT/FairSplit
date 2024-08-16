//
//  FetchContactsService.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/16/24.
//

import Foundation
import Contacts
import SwiftUI

class FetchContactsService: ObservableObject {
    @Published var contacts = [CNContact]()

    func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                DispatchQueue.global(qos: .userInitiated).async {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
                    let request = CNContactFetchRequest(keysToFetch: keys)
                    var results = [CNContact]()
                    do {
                        try store.enumerateContacts(with: request) { (contact, stop) in
                            results.append(contact)
                        }
                        DispatchQueue.main.async {
                            self.contacts = results
                        }
                    } catch {
                        print("Failed to fetch contacts: \(error)")
                    }
                }
            } else {
                print("Access denied")
            }
        }
    }
}
