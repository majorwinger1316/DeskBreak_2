//
//  secondGameViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 10/01/25.
//

import UIKit
import ARKit
import Vision


class secondGameViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    var sceneView: ARSCNView!
    var tutorialLabel: UILabel!
    
    var workoutTimer: Timer?
    var workoutTimeRemaining = 300 // 5 minutes
    var score = 0
    var scoreLabel: UILabel!
    var feedbackLabel: UILabel!
    var timerLabel: UILabel!
    
    var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    var bodyPoseObservation: VNHumanBodyPoseObservation?
    
    var isStretching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
        setupUI()
        startARSession()
        showTutorialAnimation()
    }
    
    func setupSceneView() {
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(sceneView)
        
        // Add ambient lighting for better visibility
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        sceneView.scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func setupUI() {
        // Score Label
        scoreLabel = UILabel(frame: CGRect(x: 16, y: 50, width: 200, height: 40))
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.view.addSubview(scoreLabel)
        
        // Feedback Label
        feedbackLabel = UILabel(frame: CGRect(x: 16, y: self.view.bounds.height / 2 - 50, width: self.view.bounds.width - 32, height: 80))
        feedbackLabel.text = ""
        feedbackLabel.textColor = .white
        feedbackLabel.font = UIFont.boldSystemFont(ofSize: 28)
        feedbackLabel.textAlignment = .center
        feedbackLabel.alpha = 0 // Hidden by default
        self.view.addSubview(feedbackLabel)
        
        // Timer Label
        timerLabel = UILabel(frame: CGRect(x: self.view.bounds.width - 150, y: 50, width: 120, height: 40))
        timerLabel.text = "Time: \(workoutTimeRemaining)"
        timerLabel.textColor = .white
        timerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.view.addSubview(timerLabel)
        
        // Tutorial Label
        tutorialLabel = UILabel(frame: CGRect(x: 16, y: self.view.bounds.height / 2 - 150, width: self.view.bounds.width - 32, height: 80))
        tutorialLabel.text = ""
        tutorialLabel.textColor = .yellow
        tutorialLabel.font = UIFont.boldSystemFont(ofSize: 24)
        tutorialLabel.textAlignment = .center
        tutorialLabel.alpha = 0 // Hidden by default
        self.view.addSubview(tutorialLabel)
        
        // Start Button
        let startButton = UIButton(type: .system)
        startButton.frame = CGRect(x: (self.view.bounds.width - 200) / 2, y: self.view.bounds.height - 100, width: 200, height: 50)
        startButton.setTitle("Start Workout", for: .normal)
        startButton.addTarget(self, action: #selector(resetWorkout), for: .touchUpInside)
        self.view.addSubview(startButton)
    }
    
    func startARSession() {
        guard ARFaceTrackingConfiguration.isSupported else {
            feedbackLabel.text = "Face tracking is not supported on this device."
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        
        // Create a request handler and perform body pose detection
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try requestHandler.perform([bodyPoseRequest])
            if let observation = bodyPoseRequest.results?.first {
                self.bodyPoseObservation = observation
                processPose(observation)
            }
        } catch {
            print("Error performing body pose request: \(error)")
        }
    }
    
    func processPose(_ observation: VNHumanBodyPoseObservation) {
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
            print("Failed to retrieve recognized points")
            return
        }
        
        guard let leftWrist = recognizedPoints[.leftWrist], leftWrist.confidence > 0.6,
              let rightWrist = recognizedPoints[.rightWrist], rightWrist.confidence > 0.6,
              let leftShoulder = recognizedPoints[.leftShoulder], leftShoulder.confidence > 0.6,
              let rightShoulder = recognizedPoints[.rightShoulder], rightShoulder.confidence > 0.6 else {
            print("Key points not confidently detected")
            return
        }
        
        // Debugging positions
        print("Left Wrist: \(leftWrist.location), Right Wrist: \(rightWrist.location)")
        print("Left Shoulder: \(leftShoulder.location), Right Shoulder: \(rightShoulder.location)")
        
        // Detect stretching pose: arms raised above shoulders
        let isStretchingPose = leftWrist.location.y > leftShoulder.location.y &&
                               rightWrist.location.y > rightShoulder.location.y
        
        if isStretchingPose {
            if !isStretching {
                isStretching = true
                score += 10
                DispatchQueue.main.async {
                    self.scoreLabel.text = "Score: \(self.score)"
                    self.showPositiveFeedback("Great Stretch! Keep it up!")
                }
            }
        } else {
            isStretching = false
        }
    }

    
    func showPositiveFeedback(_ message: String) {
        feedbackLabel.text = message
        feedbackLabel.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.feedbackLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                self.feedbackLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    func showTutorialAnimation() {
        let tutorialSteps = [
            "Step 1: Stand back so your full body is visible.",
            "Step 2: Start with your arms by your sides.",
            "Step 3: Stretch your arms over your head to complete a stretch!"
        ]
        
        var stepIndex = 0
        tutorialLabel.text = tutorialSteps[stepIndex]
        tutorialLabel.alpha = 0
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            if stepIndex < tutorialSteps.count {
                self.tutorialLabel.text = tutorialSteps[stepIndex]
                UIView.animate(withDuration: 0.5, animations: {
                    self.tutorialLabel.alpha = 1.0
                }) { _ in
                    UIView.animate(withDuration: 0.5, delay: 1.5, options: [], animations: {
                        self.tutorialLabel.alpha = 0
                    }, completion: nil)
                }
                stepIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    @objc func resetWorkout() {
        workoutTimeRemaining = 300
        score = 0
        scoreLabel.text = "Score: \(score)"
        feedbackLabel.text = ""
        startWorkoutTimer()
    }
    
    func startWorkoutTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.workoutTimeRemaining -= 1
            self.timerLabel.text = "Time: \(self.workoutTimeRemaining)"
            if self.workoutTimeRemaining <= 0 {
                self.endWorkout()
            }
        }
    }
    
    func endWorkout() {
        workoutTimer?.invalidate()
        workoutTimer = nil
        showPositiveFeedback("Workout Complete! Final Score: \(score)")
    }
}
