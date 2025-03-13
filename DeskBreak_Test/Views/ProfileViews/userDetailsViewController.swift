//
//  userDetailsViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 05/01/25.
//

import UIKit
import FirebaseFirestore

class userDetailsViewController: UIViewController {
    
    @IBOutlet weak var pointsView: UIView!
    
    @IBOutlet weak var minutesView: UIView!
    
    @IBOutlet weak var daysView: UIView!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var minutesLabel: UILabel!
    
    @IBOutlet weak var firstDayLabel: UIImageView!
    
    @IBOutlet weak var secondDayLabel: UIImageView!
    
    @IBOutlet weak var thirdDayLabel: UIImageView!
    
    @IBOutlet weak var fourthDayLabel: UIImageView!
    
    @IBOutlet weak var fifthDayLabel: UIImageView!
    
    @IBOutlet weak var sixthDayLabel: UIImageView!
    
    @IBOutlet weak var seventhDayLabel: UIImageView!
    
    @IBOutlet weak var eightDayLabel: UIImageView!
    
    @IBOutlet weak var ninthDayLabel: UIImageView!
    
    @IBOutlet weak var tenthDayLabel: UIImageView!
    
    @IBOutlet weak var eleventhDayLabel: UIImageView!
    
    @IBOutlet weak var twelvethDayLabel: UIImageView!
    
    @IBOutlet weak var thirteenthDayLabel: UIImageView!
    
    @IBOutlet weak var fourteenthDayLabel: UIImageView!
    
    @IBOutlet weak var fifteenthDayLabel: UIImageView!
    
    @IBOutlet weak var sixteenthDayLabel: UIImageView!
    
    @IBOutlet weak var seventeenthDayLabel: UIImageView!
    
    @IBOutlet weak var eighteenthDayLabel: UIImageView!
    
    @IBOutlet weak var nineteenthDayLabel: UIImageView!
    
    @IBOutlet weak var twentyDayLabel: UIImageView!
    
    @IBOutlet weak var twentyoneDayLabel: UIImageView!
    
    @IBOutlet weak var twentytwoDayLabel: UIImageView!
    
    @IBOutlet weak var twentythreeDayLabel: UIImageView!
    
    @IBOutlet weak var twentyfourDayLabel: UIImageView!
    
    @IBOutlet weak var twentyfiveDayLabel: UIImageView!
    
    @IBOutlet weak var twentysixDayLabel: UIImageView!
    
    @IBOutlet weak var twentysevenDayLabel: UIImageView!
    
    @IBOutlet weak var twentyeightDayLabel: UIImageView!
    
    @IBOutlet weak var twentynineDayLabel: UIImageView!
    
    @IBOutlet weak var thirtyDayLabel: UIImageView!
    
    @IBOutlet weak var thirtyoneDayLabel: UIImageView!
    
    @IBOutlet weak var calendarPopUpButton: UIButton!
    
    var userPosition: Int?
    var dayLabels: [UIImageView] = []
    
    private func fetchDailyTargetandMinutesFromFirebase() {
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching daily target: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    let totalPoints = document.data()?["totalPoints"] as? Int16 ?? 1
                    let dailyMinutes = document.data()?["totalMinutes"] as? Int16 ?? 1
                    self.pointsLabel.text = String(totalPoints)
                    print("daily min = \(dailyMinutes)")
                    self.minutesLabel.text = String(dailyMinutes)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pointsView.layer.cornerRadius = 12
        pointsView.layer.masksToBounds = true

        minutesView.layer.cornerRadius = 12
        minutesView.layer.masksToBounds = true

        daysView.layer.cornerRadius = 12
        daysView.layer.masksToBounds = true
        
        fetchAvailableMonths()
        fetchDailyTargetandMinutesFromFirebase()
        initializeDayLabels()
        
        // Default fetch for the current month
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonth = formatter.string(from: Date())
        fetchDailyData(for: currentMonth)
        
        // Other initializations
        fetchAvailableMonths()
        
        // Setup the calendar button
        setupCalendarMenu()
    }
    
    private func setupCalendarMenu() {
        guard !availableMonths.isEmpty else {
            print("Error: No available months to populate menu")
            return
        }

        let menuActions = availableMonths.map { month in
            let monthDisplayName = monthDictionary[month] ?? month

            return UIAction(title: monthDisplayName, handler: { _ in
                self.fetchDailyData(for: month)
            })
        }

        calendarPopUpButton.menu = UIMenu(title: "Select Month", children: menuActions)
        calendarPopUpButton.showsMenuAsPrimaryAction = true
    }

    private var monthDictionary: [String: String] = [:] // Stores yyyy-MM → "Month Year"
    private var availableMonths: [String] = [] // Stores yyyy-MM for fetching data
    private let monthNameMapping: [String: String] = [
        "01": "January", "02": "February", "03": "March", "04": "April",
        "05": "May", "06": "June", "07": "July", "08": "August",
        "09": "September", "10": "October", "11": "November", "12": "December"
    ]

    private func fetchAvailableMonths() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Error: userId not found in UserDefaults.")
            return
        }

        let db = Firestore.firestore()
        let monthlyStatsCollection = db.collection("users").document(userId).collection("monthlyStats")

        monthlyStatsCollection.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching available months: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Error: No monthlyStats documents found.")
                return
            }

            self.availableMonths = documents.compactMap { document in
                let documentID = document.documentID // "yyyy-MM" format
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM"
                guard let date = formatter.date(from: documentID) else { return nil }
                
                formatter.dateFormat = "MMMM yyyy" // Convert to "Month Year"
                let formattedMonth = formatter.string(from: date)

                self.monthDictionary[documentID] = formattedMonth
                return documentID
            }.sorted(by: { $0 > $1 }) // Sort latest months first

            // Limit to last 6 months
            self.availableMonths = Array(self.availableMonths.prefix(6))

            DispatchQueue.main.async {
                self.setupCalendarMenu()
            }
        }
    }

    @objc private func showMonthSelectionPopup() {
        let alertController = UIAlertController(title: "Select Month", message: nil, preferredStyle: .actionSheet)

        for month in availableMonths {
            let monthDisplayName = monthDictionary[month] ?? month

            let action = UIAlertAction(title: monthDisplayName, style: .default) { [weak self] _ in
                self?.fetchDailyData(for: month)
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func initializeDayLabels() {
        dayLabels = [
            firstDayLabel, secondDayLabel, thirdDayLabel, fourthDayLabel,
            fifthDayLabel, sixthDayLabel, seventhDayLabel, eightDayLabel,
            ninthDayLabel, tenthDayLabel, eleventhDayLabel, twelvethDayLabel,
            thirteenthDayLabel, fourteenthDayLabel, fifteenthDayLabel,
            sixteenthDayLabel, seventeenthDayLabel, eighteenthDayLabel,
            nineteenthDayLabel, twentyDayLabel, twentyoneDayLabel,
            twentytwoDayLabel, twentythreeDayLabel, twentyfourDayLabel,
            twentyfiveDayLabel, twentysixDayLabel, twentysevenDayLabel,
            twentyeightDayLabel, twentynineDayLabel, thirtyDayLabel,
            thirtyoneDayLabel
        ]
    }

    private func fetchDailyData(for month: String) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Error: userId not found in UserDefaults.")
            return
        }

        let db = Firestore.firestore()
        let monthDocument = db.collection("users").document(userId).collection("monthlyStats").document(month)

        monthDocument.getDocument { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching monthlyStats: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let dailyMinutes = data["dailyMinutes"] as? [String: Int] else {
                print("Error: Missing or invalid dailyMinutes data in monthlyStats.")
                return
            }

            print("Fetched dailyMinutes: \(dailyMinutes)")

            db.collection("users").document(userId).getDocument { (userSnapshot, error) in
                if let error = error {
                    print("Error fetching user document: \(error.localizedDescription)")
                    return
                }

                guard let userData = userSnapshot?.data(),
                      let dailyTarget = userData["dailyTarget"] as? Int else {
                    print("Error: Missing or invalid dailyTarget data in users.")
                    return
                }

                print("Fetched dailyTarget: \(dailyTarget)")

                DispatchQueue.main.async {
                    self.updateLabels(dailyMinutes: dailyMinutes, dailyTarget: dailyTarget)
                }
            }
        }
    }

    private func updateLabels(dailyMinutes: [String: Int], dailyTarget: Int) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"

        guard let selectedMonth = availableMonths.first, // Get the selected month from the list
              let selectedDate = dateFormatter.date(from: selectedMonth) else { return }

        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30

        UIView.animate(withDuration: 0.3) {
            for (index, label) in self.dayLabels.enumerated() {
                if index < numberOfDaysInMonth {
                    label.isHidden = false
                    label.alpha = 1.0 // Fully visible

                    let dayString = String(format: "%02d", index + 1)
                    if let minutes = dailyMinutes[dayString] {
                        if minutes <= 2 {
                            label.tintColor = .text
                        } else if minutes >= dailyTarget {
                            label.tintColor = .systemBlue
                        } else {
                            label.tintColor = .main
                        }
                    } else {
                        label.tintColor = UIColor.text.withAlphaComponent(0.5) // No data
                    }
                } else {
                    label.isHidden = false // Keep it in layout
                    label.tintColor = .clear // Make it transparent
                    label.alpha = 0 // Fully invisible
                }
            }
        }
    }
}
