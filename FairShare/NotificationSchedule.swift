////
////  NotificationSchedule.swift
////  FairShare
////
////  Created by Sankritya Thakur on 6/15/24.
////
//
//import Foundation
//import SwiftUI
//
//extension NotificationManager {
//    func scheduleNotification(friendName: String, expenseName: String, amountOwed: Double) {
//        let content = UNMutableNotificationContent()
//        content.title = "\(friendName) added \(expenseName)"
//        content.body = "You owe \(amountOwed)"
//        content.sound = .default
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            } else {
//                print("Notification scheduled successfully")
//            }
//        }
//    }
//}
