//
//  NotificationView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 6/15/24.
//

import SwiftUI

struct NotificationView: View {
    @ObservedObject var firestoreService: FirestoreService

    var body: some View {
        NavigationView {
            List(firestoreService.notifications) { notification in
                VStack(alignment: .leading) {
                    Text(notification.message)
                        .font(.headline)
                    Text(notification.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Notifications")
            .onAppear {
                firestoreService.fetchNotifications()
            }
        }
    }
}

