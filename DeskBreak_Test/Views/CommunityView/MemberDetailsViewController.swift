//
//
//
//
//
import UIKit
import FirebaseFirestore


class MemberDetailsViewController: UIViewController {
    
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
    
    var userPosition: Int?
    var dayLabels: [UIImageView] = []
    
    var memberId: String? // The member's userId
    
    private func fetchMemberDetailsFromFirebase() {
        guard let memberId = memberId else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(memberId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching member details: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let totalPoints = document.data()?["totalPoints"] as? Int16 ?? 1
                let totalMinutes = document.data()?["totalMinutes"] as? Int16 ?? 1
                self.pointsLabel.text = "\(totalPoints)"
                self.minutesLabel.text = "\(totalMinutes)"
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
        
        fetchMemberDetailsFromFirebase()
        initializeDayLabels()
        fetchMemberDailyData()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
        doneButton.tintColor = UIColor.main
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func doneButtonPressed() {
        dismiss(animated: true, completion: nil)
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
    
    // Fetch member's daily progress from Firestore
    private func fetchMemberDailyData() {
        guard let memberId = memberId else { return }
        
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonth = formatter.string(from: Date())
        
        // Reference to the month's document for daily data
        let monthDocument = db.collection("users").document(memberId).collection("monthlyStats").document(currentMonth)
        
        // Fetch dailyMinutes
        monthDocument.getDocument { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching monthlyStats: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let dailyMinutes = data["dailyMinutes"] as? [String: Int] else {
                print("Error: Missing or invalid dailyMinutes data.")
                return
            }

            // Fetch user's dailyTarget from users collection
            db.collection("users").document(memberId).getDocument { (userSnapshot, error) in
                if let error = error {
                    print("Error fetching user document: \(error.localizedDescription)")
                    return
                }

                guard let userData = userSnapshot?.data(),
                      let dailyTarget = userData["dailyTarget"] as? Int else {
                    print("Error: Missing or invalid dailyTarget data.")
                    return
                }

                // Update the UI on the main thread
                DispatchQueue.main.async {
                    self.updateDayLabels(dailyMinutes: dailyMinutes, dailyTarget: dailyTarget)
                }
            }
        }
    }
    
    private func updateDayLabels(dailyMinutes: [String: Int], dailyTarget: Int) {
        let calendar = Calendar.current
        let date = Date()

        // Determine the number of days in the current month
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30

        // Clear all day labels initially and set default tint color
        for label in dayLabels {
            label.isHidden = true
            label.alpha = 0  // Make labels invisible at the start
        }

        // Ensure the number of labels matches 31 (handle out-of-bounds issues)
        guard dayLabels.count == 31 else {
            print("Error: dayLabels array should contain 31 elements.")
            return
        }

        // Update visible day labels based on the current month's dailyMinutes data
        for day in 1...numberOfDaysInMonth {
            let label = dayLabels[day - 1]
            label.isHidden = false

            // Pad the day to match the format "01", "02", ..., "31"
            let dayString = String(format: "%02d", day)

            // Set the tint color based on the dailyMinutes data
            if let minutes = dailyMinutes[dayString] {
                if minutes <= 2 {
                    label.tintColor = .text // No minutes
                } else if minutes >= dailyTarget {
                    label.tintColor = .systemBlue // Target achieved
                } else if minutes > 2 {
                    label.tintColor = .main // Partial progress
                }
            } else {
                label.tintColor = UIColor.text.withAlphaComponent(0.5) // No data
            }

            // Animate the label to fade in with a slight delay
            UIView.animate(withDuration: 0.5, delay: Double(day) * 0.05, options: .curveEaseInOut, animations: {
                label.alpha = 1  // Fade in the label
            })
        }

        // Hide unused day labels for months with fewer days
        if numberOfDaysInMonth < 31 {
            for extraDay in (numberOfDaysInMonth + 1)...31 {
                let label = dayLabels[extraDay - 1]
                label.isHidden = true
            }
        }
    }
}
