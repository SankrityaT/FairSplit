//
//  AppCheckProviderFactory.swift
//  FairShare
//
//  Created by Sankritya Thakur on 6/5/24.
//

import FirebaseAppCheck
import FirebaseCore

class CustomAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}

