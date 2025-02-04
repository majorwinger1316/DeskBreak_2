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
import AVFoundation
import Vision
import AudioToolbox

extension Notification.Name {
    static let progressUpdated = Notification.Name("progressUpdated")
}

class GameViewController: UIViewController {
    var userId: String? // Make sure you have the current user's ID
    var dailyDuration: Int = 0
    var dailyScore: Int = 0
    
    //MARK: - Game Variables
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    let videoCapture = VideoCapture()
    var pointsLayer = CAShapeLayer()
    var isFormDetected = false
    var isTimerStarted = false
    var isFullBodyInFrame = false
    
    // Timer and score
    var timer: Timer?
    var remainingTime = 30
    var duration = 0
    var score = 0
    
    // UI Elements
    let timerLabel = UILabel()
    let scoreLabel = UILabel()
    let guidanceLabel = UILabel()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    @IBAction func yesTapped(_ sender: UIButton) {
        let yesScore = 20
        dailyScore += yesScore
        dailyDuration += 0
        print("Score after YES tapped: \(dailyScore)")
    }
    
    
    @IBOutlet weak var DurationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPreview()
        setupUI()
        videoCapture.predictor.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showTimerDurationAlert()
        }
    }
    
    private func showTimerDurationAlert() {
        print("Showing timer duration alert")  // Debug print
        let alert = UIAlertController(title: "Select Timer Duration", message: "Choose a duration for your session", preferredStyle: .alert)
        
        for minutes in 1...10 {
            alert.addAction(UIAlertAction(title: "\(minutes) Minute\(minutes > 1 ? "s" : "")", style: .default, handler: { [weak self] _ in
                self?.startSession(withDuration: minutes * 60)
                self?.duration = minutes
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupVideoPreview() {
        videoCapture.startCaptureSession(useFrontCamera: true)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        guard let previewLayer = previewLayer else { return }
        
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        
        // Add points layer above the video layer
        pointsLayer.frame = view.bounds
        pointsLayer.strokeColor = UIColor.green.cgColor
        pointsLayer.fillColor = UIColor.clear.cgColor
        pointsLayer.lineWidth = 5.0
        view.layer.addSublayer(pointsLayer)
    }
    
    private func setupUI() {
        // Timer label
        timerLabel.frame = CGRect(x: 20, y: 50, width: 150, height: 40)
        timerLabel.textColor = .white
        timerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        timerLabel.text = "Time: \(remainingTime)s"
        view.addSubview(timerLabel)
        
        // Score label
        scoreLabel.frame = CGRect(x: view.frame.width - 170, y: 50, width: 150, height: 40)
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: \(score)"
        view.addSubview(scoreLabel)
        
        // Guidance label
        guidanceLabel.frame = CGRect(x: 20, y: view.frame.height - 100, width: view.frame.width - 40, height: 50)
        guidanceLabel.textColor = .yellow
        guidanceLabel.font = UIFont.systemFont(ofSize: 18)
        guidanceLabel.textAlignment = .center
        guidanceLabel.text = "Please step back until your full body is in the frame."
        view.addSubview(guidanceLabel)
        
        // Blur view for feedback when body is not fully visible
        blurView.frame = view.bounds
        blurView.isHidden = true // Initially hidden
        view.addSubview(blurView)
    }
    
    private func startTimer() {
        print("startTimer() function called")
        
        // Ensure we are on the main thread to schedule the timer
        DispatchQueue.main.async {
            if self.timer == nil {  // Only create a new timer if it doesn't already exist
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    self.remainingTime -= 1
                    print("Remaining time: \(self.remainingTime)") // Log remaining time
                    self.timerLabel.text = "Time: \(self.remainingTime)s"
                    
                    if self.remainingTime <= 0 {
                        print("Timer ended")
                        self.timer?.invalidate()
                        self.timer = nil
                        self.endSession()
                    }
                }
            } else {
                print("Timer already running!")
            }
        }
    }
    
    private func endSession() {
        // Show final score
        let alert = UIAlertController(title: "Time's Up!", message: "Your score: \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dailyScore += self.score
            self.dailyDuration += self.duration
            
            print("Score after OVER tapped: \(self.dailyScore)")
            
            self.updateUserProgressInFirebase(duration: self.duration, score: self.dailyScore)

            self.updateMonthlyStatsInFirebase(minutes: self.dailyDuration)
            
            self.presentSuccessViewController(duration: self.dailyDuration, score: self.dailyScore)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func resetSession() {
        score = 0
        remainingTime = 30
        isTimerStarted = false  // Reset this flag
        isFormDetected = false
        isFullBodyInFrame = false
        scoreLabel.text = "Score: \(score)"
        timerLabel.text = "Time: \(remainingTime)s"
        guidanceLabel.text = "Please step back until your full body is in the frame."
        blurView.isHidden = false // Show blur until body is detected
    }
    
    // Start session with the selected duration
    private func startSession(withDuration duration: Int) {
        // Set the timer duration in seconds
        self.remainingTime = duration
        self.isTimerStarted = false
        self.isFormDetected = false
        self.isFullBodyInFrame = false
        
        // Start the session (you can call your startTimer function from here)
        print("Session started with duration: \(remainingTime) seconds")
        startTimer()  // Start the timer
    }
}

extension GameViewController: PredictorDelegate {
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double) {
        print("Action detected: \(action), Confidence: \(confidence)")
        
        if action == "good_posture" && confidence > 0.90 {
            if isFullBodyInFrame {
                print("Full body detected: Starting timer")
                
                // Check and log if isTimerStarted is being properly toggled
                if !isTimerStarted {
                    print("Timer is NOT started. Now starting the timer...")
                    isTimerStarted = true
                    guidanceLabel.text = "" // Clear guidance message
                    blurView.isHidden = true // Remove blur
                    startTimer()
                } else {
                    print("Timer already started!")
                }
                
                if !isFormDetected {
                    isFormDetected = true
                    print("Good posture detected with confidence \(confidence)")
                    
                    // Haptic feedback
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    AudioServicesPlayAlertSound(SystemSoundID(1322))
                    
                    // Update score
                    score += 10
                    self.dailyScore += 10
                    DispatchQueue.main.async {
                        self.scoreLabel.text = "Score: \(self.score)"
                    }
                    
                    // Reset form detection after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.isFormDetected = false
                    }
                }
            } else {
                print("Full body NOT detected, can't start timer yet")
            }
        }
    }
    
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint]) {
        guard previewLayer != nil else { return }
        
        DispatchQueue.main.async {
            self.pointsLayer.path = nil
            let combinedPath = CGMutablePath()
            
            var visiblePointsCount = 0
            for point in points {
                let normalizedPoint = CGPoint(x: point.x * self.view.frame.width, y: point.y * self.view.frame.height)
                if self.view.bounds.contains(normalizedPoint) {
                    visiblePointsCount += 1
                }
                
                let circleRect = CGRect(x: normalizedPoint.x - 5, y: normalizedPoint.y - 5, width: 10, height: 10)
                combinedPath.addEllipse(in: circleRect)
            }
            self.pointsLayer.path = combinedPath
            
            // Debug log for points
            print("Visible Points Count: \(visiblePointsCount)")
            
            if visiblePointsCount >= 5 { // Full body detected (adjust this threshold if needed)
                self.isFullBodyInFrame = true
                self.guidanceLabel.text = "Good! Hold good posture to start."
                self.blurView.isHidden = true // Remove blur
            } else {
                self.isFullBodyInFrame = false
                self.guidanceLabel.text = "Please step back until your full body is in the frame."
                self.blurView.isHidden = false // Show blur
            }
        }
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
