//
//  AddRoutineViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 21/03/25.
//

import UIKit
import UserNotifications

class AddRoutineViewController: UIViewController {
    
    @IBOutlet weak var stretchButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var weekdaySelectView: WeekdaySelectView!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var notificationView: UIView!
    
    
    var routine: Routine?
    var editIndex: Int?
    let stretches: [StretchType] = [.liftUp, .neckFlex]
    var selectedStretch: StretchType?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        timeView.layer.cornerRadius = 8
        notificationView.layer.cornerRadius = 8
        
        if let routine = routine {
            // Edit mode
            selectedStretch = stretches.first { $0.title == routine.exerciseName }
            stretchButton.setTitle(selectedStretch?.title, for: .normal)
            timePicker.date = routine.time
            weekdaySelectView.selectedDays = routine.weekdays
            reminderSwitch.isOn = routine.reminderEnabled
            
            title = "Edit Stretch"
        } else {
            title = "Add New Stretch"
        }
    }
    
    private func setupUI() {
        saveButton.layer.cornerRadius = 10
        
        // Update UI for iOS 13+ Dark Mode support
        if #available(iOS 13.0, *) {
            saveButton.backgroundColor = .systemBlue
            stretchButton.setTitleColor(.main, for: .normal)
        } else {
            saveButton.backgroundColor = .blue
            stretchButton.setTitleColor(.main, for: .normal)
        }
    }
    
    @IBAction func stretchButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Select Stretch", message: nil, preferredStyle: .actionSheet)
        
        for stretch in stretches {
            alert.addAction(UIAlertAction(title: stretch.title, style: .default, handler: { _ in
                self.selectedStretch = stretch
                self.stretchButton.setTitle(stretch.title, for: .normal)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let selectedStretch = selectedStretch, !weekdaySelectView.selectedDays.isEmpty else {
             // Show alert for invalid form
             let alert = UIAlertController(
                 title: "Invalid Form",
                 message: "Please select a stretch and at least one day",
                 preferredStyle: .alert
             )
             alert.addAction(UIAlertAction(title: "OK", style: .default))
             present(alert, animated: true)
             return
         }
         
         let newRoutine = Routine(
             exerciseName: selectedStretch.title,
             time: timePicker.date,
             weekdays: weekdaySelectView.selectedDays,
             reminderEnabled: reminderSwitch.isOn
         )

         RoutineStore.shared.saveRoutine(newRoutine)
         
         if reminderSwitch.isOn {
             scheduleStretchNotifications(for: newRoutine)
         } else {
             removeStretchNotifications(for: newRoutine)
         }
         
         dismiss(animated: true)
     }

    private func scheduleStretchNotifications(for routine: Routine) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // Remove previous notifications
        
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: Date()) // Get today's weekday
        let currentHour = calendar.component(.hour, from: Date())
        let currentMinute = calendar.component(.minute, from: Date())
        
        let hour = calendar.component(.hour, from: routine.time)
        let minute = calendar.component(.minute, from: routine.time)
        let formattedTime = String(format: "%02d:%02d", hour, minute) // Format time as HH:mm
        
        for weekday in routine.weekdays {
            let content = UNMutableNotificationContent()
            content.title = "DeskBreak: Time to Stretch!"
            content.body = "It's time to perform \(routine.exerciseName) at \(formattedTime). Stand up, stretch, and refresh!"
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = weekday.rawValue
            
            // Check if the selected weekday is today
            if weekday.rawValue == currentWeekday {
                // Check if the selected time is later than the current time
                if hour > currentHour || (hour == currentHour && minute > currentMinute) {
                    // Schedule a one-time notification for today
                    let todayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let todayRequest = UNNotificationRequest(
                        identifier: "stretchReminder_TODAY_\(routine.exerciseName)",
                        content: content,
                        trigger: todayTrigger
                    )
                    center.add(todayRequest) { error in
                        if let error = error {
                            print("❌ Error scheduling notification for today: \(error)")
                        } else {
                            print("✅ Notification scheduled TODAY for \(routine.exerciseName) at \(formattedTime)")
                        }
                    }
                } else {
                    // If the time has already passed today, schedule for the next occurrence
                    if let nextOccurrence = getNextOccurrence(of: weekday, at: routine.time, after: Date()) {
                        var nextDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextOccurrence)
                        nextDateComponents.weekday = weekday.rawValue
                        
                        let nextTrigger = UNCalendarNotificationTrigger(dateMatching: nextDateComponents, repeats: false)
                        let nextRequest = UNNotificationRequest(
                            identifier: "stretchReminder_NEXT_\(routine.exerciseName)",
                            content: content,
                            trigger: nextTrigger
                        )
                        center.add(nextRequest) { error in
                            if let error = error {
                                print("❌ Error scheduling next notification: \(error)")
                            } else {
                                print("✅ Notification scheduled for NEXT \(routine.exerciseName) at \(formattedTime)")
                            }
                        }
                    }
                }
            }
            
            // Schedule repeating notifications for future weeks
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "stretchReminder_\(routine.exerciseName)_\(weekday.rawValue)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error)")
                } else {
                    print("✅ Notification scheduled for \(routine.exerciseName) on \(weekday.shortName) at \(formattedTime)")
                }
            }
        }
    }

    private func getNextOccurrence(of weekday: WeekdayCode, at time: Date, after date: Date) -> Date? {
        let calendar = Calendar.current
        let targetWeekday = weekday.rawValue
        
        // Get the components for the target time
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        // Get the current date's weekday
        let currentWeekday = calendar.component(.weekday, from: date)
        
        // Calculate the days to add to reach the target weekday
        var daysToAdd = targetWeekday - currentWeekday
        if daysToAdd <= 0 {
            daysToAdd += 7 // Move to the next week
        }
        
        // Get the next occurrence date
        guard let nextDate = calendar.date(byAdding: .day, value: daysToAdd, to: date) else {
            return nil
        }
        
        // Set the time for the next occurrence
        var components = calendar.dateComponents([.year, .month, .day], from: nextDate)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        
        return calendar.date(from: components)
    }
     
     private func removeStretchNotifications(for routine: Routine) {
         let center = UNUserNotificationCenter.current()
         
         for weekday in routine.weekdays {
             let identifier = "stretchReminder_\(routine.exerciseName)_\(weekday.rawValue)"
             center.removePendingNotificationRequests(withIdentifiers: [identifier])
             print("Notification removed for \(routine.exerciseName) on \(weekday.shortName)")
         }
     }
 }
