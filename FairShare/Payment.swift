//
//  Payment.swift
//  FairShare
//
//  Created by Sankritya Thakur on 6/18/24.
//

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Payment: Identifiable, Codable {
    @DocumentID var id: String?
    var from: String
    var to: String
    var amount: Double
    var date: Timestamp
}
