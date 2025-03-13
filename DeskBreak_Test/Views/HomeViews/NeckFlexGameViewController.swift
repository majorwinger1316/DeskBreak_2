//
//  NeckFlexGameViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 19/02/25.
//

import UIKit
import ARKit
import Vision
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabaseInternal

class NeckFlexGameViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    private var instructionLabel: UILabel!
    private var timerLabel: UILabel!
    private var sessionTimerLabel: UILabel!
    private var pointsLabel: UILabel!
    private var startButton: UIButton!
    private var stepper: UIStepper!
    private var durationLabel: UILabel!
    private var timer: Timer?
    private var restTimer: Timer?
    private var sessionTimer: Timer?
    private var timeLeft = 5
    private var originalSessionTime: Int = 0
    private var restTime = 5
    private var sessionTime = 0
    private var currentStep = 0
    private let stretches = ["Look Up", "Look Down", "Look Right", "Look Left", "Tilt Right", "Tilt Left"]
    private var isPaused = false
    private var isResting = false
    private var synthesizer = AVSpeechSynthesizer()
    private var totalPoints = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupUI()
        
        // Fetch the current user's ID
        if let user = Auth.auth().currentUser {
            print("User ID: \(user.uid)")
        } else {
            print("User is not logged in.")
        }
    }
    
    private func setupSceneView() {
        sceneView.session.delegate = self
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        // Gradient Background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0).cgColor, UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Instruction Label with Background
        instructionLabel = UILabel(frame: CGRect(x: 20, y: 50, width: view.frame.width - 40, height: 100))
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        instructionLabel.textColor = .white
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        instructionLabel.layer.cornerRadius = 15
        instructionLabel.clipsToBounds = true
        instructionLabel.numberOfLines = 2
        instructionLabel.isHidden = true
        view.addSubview(instructionLabel)
        
        // Duration Selection (Stepper and Label)
        let durationContainer = UIView(frame: CGRect(x: 20, y: 220, width: view.frame.width - 40, height: 50))
        durationContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        durationContainer.layer.cornerRadius = 15
        durationContainer.clipsToBounds = true
        view.addSubview(durationContainer)
        
        // Session Timer Label
        sessionTimerLabel = UILabel(frame: CGRect(x: 10, y: 12, width: view.frame.width - 40, height: 40))
        sessionTimerLabel.textAlignment = .center
        sessionTimerLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        sessionTimerLabel.textColor = .white
        durationContainer.addSubview(sessionTimerLabel)
        
        // Bottom Container for Timer and Points
        let bottomContainer = UIView(frame: CGRect(x: 0, y: view.frame.height - 200, width: view.frame.width, height: 100))
        bottomContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        bottomContainer.layer.cornerRadius = 15
        bottomContainer.clipsToBounds = true
        view.addSubview(bottomContainer)
        
        // Timer Label
        timerLabel = UILabel(frame: CGRect(x: 20, y: 10, width: bottomContainer.frame.width - 40, height: 30))
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        timerLabel.textColor = .white
        timerLabel.isHidden = true
        bottomContainer.addSubview(timerLabel)
        
        // Points Label
        pointsLabel = UILabel(frame: CGRect(x: 20, y: 50, width: bottomContainer.frame.width - 40, height: 30))
        pointsLabel.textAlignment = .center
        pointsLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        pointsLabel.textColor = .main
        pointsLabel.text = "Points 0"
        pointsLabel.isHidden = true
        bottomContainer.addSubview(pointsLabel)
        
        durationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 30))
        durationLabel.text = "5 min"
        durationLabel.textAlignment = .left
        durationLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        durationLabel.textColor = .white
        durationContainer.addSubview(durationLabel)
        
        stepper = UIStepper(frame: CGRect(x: durationContainer.frame.width - 120, y: 10, width: 100, height: 30))
        stepper.minimumValue = 1
        stepper.maximumValue = 60
        stepper.value = 5
        stepper.tintColor = .systemBlue
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        durationContainer.addSubview(stepper)
        
        // Start Session Button
        startButton = UIButton(frame: CGRect(x: (view.frame.width - 200) / 2, y: view.frame.height - 175, width: 200, height: 50))
        startButton.setTitle("Start Session", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        startButton.backgroundColor = UIColor.systemBlue
        startButton.layer.cornerRadius = 12
        startButton.clipsToBounds = true
        startButton.addTarget(self, action: #selector(startSession), for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    @objc private func stepperValueChanged(_ stepper: UIStepper) {
        durationLabel.text = "\(Int(stepper.value)) min"
    }
    
    @objc private func startSession() {
        originalSessionTime = Int(stepper.value) * 60
        sessionTime = originalSessionTime
        sessionTimerLabel.text = "Session Time \(Int(stepper.value)) min"
        durationLabel.isHidden = true
        stepper.isHidden = true
        startButton.isHidden = true
        timerLabel.isHidden = false
        pointsLabel.isHidden = false
        instructionLabel.isHidden = false
        currentStep = 0
        totalPoints = 0
        pointsLabel.text = "Points 0"
        startStretchSequence()
    }
    
    private func endSession() {
        sessionTimer?.invalidate()
        timer?.invalidate()
        restTimer?.invalidate()
        updateInstruction("Session Over")
        speak("Session Over")
        timerLabel.text = ""
        sessionTimerLabel.text = "Session Time 0:00"
        startButton.isHidden = false
        originalSessionTime /= 60
        
        // Use originalSessionTime instead of sessionTime
        updateUserProgressInFirebase(duration: originalSessionTime, score: totalPoints)
        updateMonthlyStatsInFirebase(minutes: originalSessionTime)
        presentSuccessViewController(duration: originalSessionTime, score: totalPoints)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func startStretchSequence() {
        if sessionTime > 0 {
            let instruction = stretches[currentStep]
            updateInstruction(instruction)
            speak(instruction)
            timeLeft = 5
            isPaused = true
            updateTimerLabel()
            startSessionTimer()
        } else {
            endSession()
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
    
    private func startSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSessionTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateSessionTimer() {
        if sessionTime > 0 {
            sessionTime -= 1
            sessionTimerLabel.text = "Session Time \(sessionTime / 60):\(String(format: "%02d", sessionTime % 60))"
        } else {
            endSession()
        }
    }
    
    private func updateUserProgressInFirebase(duration: Int, score: Int) {
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
                    }
                }
            } else {
                print("Document does not exist or failed to fetch data.")
            }
        }
    }

    func presentSuccessViewController(duration: Int, score: Int) {
        let successVC = storyboard?.instantiateViewController(withIdentifier: "GameSuccessViewController") as! GameSuccessViewController
        successVC.totalDuration = duration
        successVC.finalScore = score
        present(successVC, animated: true, completion: nil)
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let faceAnchor = frame.anchors.first as? ARFaceAnchor else { return }
        let transform = faceAnchor.transform
        let rotation = SCNMatrix4(transform).toEulerAngles()
        detectHeadPosition(pitch: rotation.x, yaw: rotation.y, roll: rotation.z)
    }
    
    private func detectHeadPosition(pitch: Float, yaw: Float, roll: Float) {
        let threshold: Float = 0.3
        
        var detectedPose = ""

        if pitch < -threshold {
            detectedPose = "Look Up"
        } else if pitch > threshold {
            detectedPose = "Look Down"
        } else if yaw > threshold {
            detectedPose = "Look Right"
        } else if yaw < -threshold {
            detectedPose = "Look Left"
        } else if roll > threshold {
            detectedPose = "Tilt Left"
        } else if roll < -threshold {
            detectedPose = "Tilt Right"
        } else {
            detectedPose = "Face Forward"
        }

        if detectedPose == stretches[currentStep] {
            if isPaused {
                isPaused = false
                startTimer()
            }
        } else {
            if !isPaused && !isResting {
                isPaused = true
                timer?.invalidate()
                updateInstruction("Fix \(stretches[currentStep])")
                speak("Fix your posture. \(stretches[currentStep])")
            }
        }
    }

    private func startTimer() {
        updateTimerLabel()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        if timeLeft > 0 {
            timeLeft -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            totalPoints += 10
            pointsLabel.text = "Points \(totalPoints)"
            startRestPeriod()
        }
    }
    
    private func startRestPeriod() {
        isResting = true
        updateInstruction("Rest")
        speak("Break")
        restTime = 5
        updateRestTimerLabel()
        restTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRestTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateRestTimer() {
        if restTime > 0 {
            restTime -= 1
            updateRestTimerLabel()
        } else {
            restTimer?.invalidate()
            isResting = false
            currentStep = (currentStep + 1) % stretches.count
            startStretchSequence()
        }
    }
    
    private func updateInstruction(_ instruction: String) {
        DispatchQueue.main.async {
            self.instructionLabel.text = instruction
        }
    }
    
    private func updateTimerLabel() {
        DispatchQueue.main.async {
            self.timerLabel.text = "Time \(self.timeLeft)s"
        }
    }
    
    private func updateRestTimerLabel() {
        DispatchQueue.main.async {
            self.timerLabel.text = "Rest \(self.restTime)s"
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.postUtteranceDelay = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

extension SCNMatrix4 {
    func toEulerAngles() -> (x: Float, y: Float, z: Float) {
        let x = atan2(self.m23, self.m33)
        let y = atan2(-self.m13, sqrt(self.m23 * self.m23 + self.m33 * self.m33))
        let z = atan2(self.m12, self.m11)
        return (x, y, z)
    }
}

