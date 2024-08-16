//
//  AppSettings.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/17/24.
//


import Foundation
import Combine

class AppSettings: ObservableObject {
    @Published var selectedCurrency: String {
        didSet {
            UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency")
        }
    }

    init() {
        self.selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "USD"
    }
}
