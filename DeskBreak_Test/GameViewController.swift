//
//  GameViewController.swift
//  DeskBreak_Test
//
//  Created by admin44 on 17/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabaseInternal


extension Notification.Name {
    static let progressUpdated = Notification.Name("progressUpdated")
}

class GameViewController: UIViewController {
    var userId: String? // Make sure you have the current user's ID
    var dailyDuration: Int = 0
    var dailyScore: Int = 0
    
    @IBAction func yesTapped(_ sender: UIButton) {
        let yesScore = 20
        dailyScore += yesScore
        dailyDuration += 0
        print("Score after YES tapped: \(dailyScore)")
    }
    
   
    @IBOutlet weak var DurationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the keyboard type to numeric
        DurationTextField.keyboardType = .numberPad

        // Add a Done button to the keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: true)

        // Set the inputAccessoryView of the text field to the toolbar
        DurationTextField.inputAccessoryView = toolbar
    }

    @objc func dismissKeyboard() {
        // Dismiss the keyboard when Done is pressed
        DurationTextField.resignFirstResponder()
    }
    
    @IBAction func overTapped(_ sender: UIButton) {
        guard let durationText = DurationTextField.text,
              let duration = Int(durationText) else {
            showAlert(title: "Invalid Input", message: "Please enter a valid workout duration.")
            return
        }


        let workoutScore = duration * 10
        dailyScore += workoutScore
        dailyDuration += duration
        
        print("Score after OVER tapped: \(dailyScore)")
        
        updateUserProgressInFirebase(duration: dailyDuration, score: dailyScore)

        updateMonthlyStatsInFirebase(minutes: duration)
        
        presentSuccessViewController(duration: dailyDuration, score: dailyScore)
    }
    
    @IBAction func NoTapped(_ sender: UIButton) {
        let noScore = -10
        dailyScore += noScore
        dailyDuration += 0 // Assume no duration for NO button
        print("Score after NO tapped: \(dailyScore)")
    }
    
    
    @IBAction func ExitTapped(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Confirm Exit",
            message: "Are you sure you want to leave the game?",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        present(alertController, animated: true)
    }

    func updateUserProgressInFirebase(duration: Int, score: Int) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                var totalMinutes = document.get("totalMinutes") as? Int ?? 0
                var totalPoints = document.get("totalPoints") as? Int ?? 0
                var dailyMinutes = document.get("dailyMinutes") as? Int ?? 0
                var dailyPoints = document.get("dailyPoints") as? Int ?? 0
                let lastUpdateDate = document.get("lastUpdateDate") as? Timestamp ?? Timestamp(date: Date())

                let currentDate = Date()
                if !self.isSameDay(currentDate, lastUpdateDate.dateValue()) {
                    dailyMinutes = 0
                    dailyPoints = 0
                }

                // Update daily and total values
                dailyMinutes += duration
                dailyPoints += score
                totalMinutes += duration
                totalPoints += score

                // Log the data we're updating
                print("Updating user data: \(totalMinutes) minutes, \(totalPoints) points")

                // Update Firestore with new values
                userRef.updateData([
                    "totalMinutes": totalMinutes,
                    "totalPoints": totalPoints,
                    "dailyMinutes": dailyMinutes,
                    "dailyPoints": dailyPoints,
                    "lastUpdateDate": Timestamp(date: currentDate)
                ]) { error in
                    if let error = error {
                        print("Error updating Firestore: \(error.localizedDescription)")
                    } else {
                        print("User progress updated successfully in Firestore.")
                        NotificationCenter.default.post(name: .progressUpdated, object: nil)
                    }
                }
            } else {
                print("Document does not exist or failed to fetch data.")
            }
        }
    }

    func updateMonthlyStatsInFirebase(minutes: Int) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            return
        }

        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let monthString = dateFormatter.string(from: Date())

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        let dayString = dayFormatter.string(from: Date())

        let monthlyStatsRef = db.collection("users").document(userId).collection("monthlyStats").document(monthString)

        monthlyStatsRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching monthlyStats: \(error.localizedDescription)")
                return
            }

            var dailyMinutes = [String: Int]()
            var streak = 0
            var lastActiveDay: Int?
            
            if let data = document?.data(), let existingDailyMinutes = data["dailyMinutes"] as? [String: Int] {
                dailyMinutes = existingDailyMinutes
                
                // Get the last active day if available
                lastActiveDay = existingDailyMinutes.keys.compactMap { Int($0) }.sorted().last
                streak = data["streak"] as? Int ?? 0
            }

            // Update minutes for the current day
            if let currentDayMinutes = dailyMinutes[dayString] {
                dailyMinutes[dayString] = currentDayMinutes + minutes
            } else {
                dailyMinutes[dayString] = minutes
            }

            // Check if the current day is consecutive to the last active day
            if let lastActive = lastActiveDay, let currentDay = Int(dayString), currentDay == lastActive + 1 {
                streak += 1
            } else {
                // Reset the streak if the current day is not consecutive
                streak = 1
            }

            let totalMinutes = dailyMinutes.values.reduce(0, +)

            // Update Firestore with new data
            monthlyStatsRef.setData([
                "month": monthString,
                "dailyMinutes": dailyMinutes,
                "totalMinutes": totalMinutes,
                "streak": streak
            ], merge: true) { error in
                if let error = error {
                    print("Error updating monthlyStats: \(error.localizedDescription)")
                } else {
                    print("Monthly stats updated successfully in Firestore.")
                }
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    func presentSuccessViewController(duration: Int, score: Int) {
        let successVC = storyboard?.instantiateViewController(withIdentifier: "GameSuccessViewController") as! GameSuccessViewController
        successVC.totalDuration = duration
        successVC.finalScore = score
        present(successVC, animated: true, completion: nil)
    }
}
