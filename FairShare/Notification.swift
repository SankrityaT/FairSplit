//
//  Notification.swift
//  FairShare
//
//  Created by Sankritya Thakur on 6/15/24.
//

import Foundation

struct Notification: Identifiable {
    var id: UUID = UUID()
    var message: String
    var date: Date
}
