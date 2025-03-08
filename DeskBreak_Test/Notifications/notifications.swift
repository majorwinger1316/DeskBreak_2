//
//  notifications.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/03/25.
//

import Foundation
import UserNotifications

func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Notification permission granted ✅")
        } else {
            print("Notification permission denied ❌")
        }
    }
}

func scheduleStretchNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    
    let stretchMessages = [
        "Time to stretch! Stand up and reach for the sky. 🌤️",
        "Give your neck a break! Slowly tilt your head side to side. 🏋️",
        "Shake off the stiffness! Stretch your arms and shoulders. 💪",
        "Take a deep breath and stretch your back. Your posture will thank you! 🧘",
        "A quick stretch can boost energy! Extend your legs and flex your toes. 🦵"
    ]
    
    let shiftTimes: [String: (start: Int, end: Int)] = [
        "9 AM - 5 PM": (9, 17),
        "10 AM - 6 PM": (10, 18),
        "11 AM - 7 PM": (11, 19),
        "12 PM - 8 PM": (12, 20),
        "1 PM - 9 PM": (13, 21)
    ]
    
    let selectedShift = UserDefaults.standard.string(forKey: "selectedShift") ?? "9 AM - 5 PM"
    let shiftHours = shiftTimes[selectedShift] ?? (9, 17)
    
    for hour in shiftHours.start...shiftHours.end {
        for weekday in 2...6 {
            let content = UNMutableNotificationContent()
            content.title = "DeskBreak: Time to Stretch!"
            content.body = stretchMessages.randomElement() ?? "Stand up, stretch, and refresh!"
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            dateComponents.weekday = weekday
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "stretchReminder_\(hour)_\(weekday)", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    print("Stretch notifications scheduled based on \(selectedShift) ✅")
}
