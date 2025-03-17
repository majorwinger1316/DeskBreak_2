//
//  GameViewController.swift
//  DeskBreak_Test
//
//  Created by admin44 on 17/11/24.
//

//
//import UIKit
//import FirebaseFirestore
//import FirebaseAuth
//import FirebaseDatabaseInternal
//import AVFoundation
//import Vision
//
//extension Notification.Name {
//    static let progressUpdated = Notification.Name("progressUpdated")
//}
//
//class GameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
//    var userId: String? // Make sure you have the current user's ID
//    var dailyDuration: Int = 0
//    var dailyScore: Int = 0
//    
//    //MARK: - Game Variable
//    
//    var duration = 0
//    
//    private var captureSession: AVCaptureSession!
//    private var score = 0
//    private var timer: Timer?
//    private var exerciseTimer: Timer?
//    private var secondsElapsed = 0
//    private let speechSynthesizer = AVSpeechSynthesizer()
//    private var isPaused = false
//    private var isCalibrated = false
//    private var stretchThreshold: CGFloat = 0.1
//    private var currentExerciseIndex = 0
//    private var currentExercise: Sequence? = nil
//    private var exerciseDuration = 10 // Seconds per exercise
//    private var exerciseTimeRemaining = 0
//    private var exerciseSuccessCounter = 0
//    private var currentExerciseStartTime = 0
//    private var hasScoredForCurrentExercise = false
//    var isCorrectPosition = false
//    
//    private lazy var durationStepper: UIStepper = {
//           let stepper = UIStepper()
//           stepper.minimumValue = 1
//           stepper.maximumValue = 10
//           stepper.stepValue = 1
//           stepper.value = 3  // Default value
//           stepper.translatesAutoresizingMaskIntoConstraints = false
//           return stepper
//       }()
//       
//       private lazy var durationLabel: UILabel = {
//           let label = UILabel()
//           label.font = UIFont.boldSystemFont(ofSize: 20)
//           label.textColor = .white
//           label.textAlignment = .center
//           label.translatesAutoresizingMaskIntoConstraints = false
//           return label
//       }()
//       
//       private lazy var stepperContainer: UIView = {
//           let view = UIView()
//           view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//           view.layer.cornerRadius = 12
//           view.translatesAutoresizingMaskIntoConstraints = false
//           return view
//       }()
//       
//       private lazy var stepperTitleLabel: UILabel = {
//           let label = UILabel()
//           label.text = "Select Workout Duration"
//           label.font = UIFont.boldSystemFont(ofSize: 24)
//           label.textColor = .white
//           label.textAlignment = .center
//           label.translatesAutoresizingMaskIntoConstraints = false
//           return label
//       }()
//       
//       private lazy var startCalibrationButton: UIButton = {
//           let button = UIButton(type: .system)
//           button.setTitle("Start Calibration", for: .normal)
//           button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//           button.backgroundColor = .main
//           button.tintColor = .white
//           button.layer.cornerRadius = 10
//           button.translatesAutoresizingMaskIntoConstraints = false
//           return button
//       }()
//    
//    private let exerciseView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        view.layer.cornerRadius = 8
//        view.isHidden = true
//        return view
//    }()
//    
//    private let exerciseIcon: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFit
//        iv.tintColor = .cyan
//        return iv
//    }()
//    
//    private let exerciseLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 24)
//        label.textColor = .white
//        label.textAlignment = .center
//        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        label.layer.cornerRadius = 8
//        label.numberOfLines = 0
//        label.clipsToBounds = true
//        return label
//    }()
//    private let exerciseTimerLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 60)
//        label.textColor = .red
//        label.clipsToBounds = true
//        label.textAlignment = .center
//        return label
//    }()
//    private let calibrationOverlay: UIView = {
//        let overlay = UIView()
//        overlay.backgroundColor = UIColor.red.withAlphaComponent(0.5)
//        overlay.layer.cornerRadius = 20
//        overlay.isHidden = false
//        return overlay
//    }()
//    private let calibrationLabel: UILabel = {
//        let label = UILabel()
//        label.text = "⚠️ Adjust yourself to the center of screen, stand with your entire body visible!"
//        label.textAlignment = .center
//        label.font = UIFont.boldSystemFont(ofSize: 20)
//        label.textColor = .white
//        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        label.layer.cornerRadius = 10
//        label.numberOfLines=0
//        label.clipsToBounds = true
//        label.isHidden = true
//        return label
//    }()
//    private let pauseResumeButton: UIButton = {
//        let button = UIButton(type: .system)
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
//        button.setImage(UIImage(systemName: "pause", withConfiguration: config), for: .normal)
//        button.tintColor = .white
//        button.backgroundColor = .systemGray
//        button.layer.cornerRadius = 20
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.isHidden = true
//        return button
//    }()
//    private let scoreLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Score : 0"
//        label.font = UIFont.boldSystemFont(ofSize: 24)
//        label.textColor = .cyan
//        label.textAlignment = .center
//        label.layer.cornerRadius = 8
//        label.layer.masksToBounds = true
//        label.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
//        label.isHidden = true
//        return label
//    }()
//    private func speak(_ text: String) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            let utterance = AVSpeechUtterance(string: text)
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//            utterance.rate = 0.3
//            self.speechSynthesizer.speak(utterance)
//        }
//    }
//
//    private var countdownLayer: CAShapeLayer!
//    private let timerProgressBar: UIProgressView = {
//        let progressBar = UIProgressView(progressViewStyle: .default)
//        progressBar.progressTintColor = .systemGreen
//        progressBar.trackTintColor = .systemGray
//        progressBar.isHidden = true
//        return progressBar
//    }()
//    
//    private let countdownLabel: UILabel = {
//        let label = UILabel()
//        label.text = ""
//        label.font = UIFont.boldSystemFont(ofSize: 48)
//        label.textAlignment = .center
//        label.isHidden = true
//        return label
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .clear
//        setupCamera()
//        setupUI()
//        showDurationStepper()
//        setupCircularCountdownLayer()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//        }
//    }
//    
//    private func showDurationStepper() {
//           // Create a container view for the stepper UI
//           let stepperContainer = UIView()
//           stepperContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//           stepperContainer.layer.cornerRadius = 12
//           stepperContainer.translatesAutoresizingMaskIntoConstraints = false
//           
//           let titleLabel = UILabel()
//           titleLabel.text = "Select Workout Duration"
//           titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
//           titleLabel.textColor = .white
//           titleLabel.textAlignment = .center
//           titleLabel.translatesAutoresizingMaskIntoConstraints = false
//           
//           let startButton = UIButton(type: .system)
//           startButton.setTitle("Start Calibration", for: .normal)
//           startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
//           startButton.backgroundColor = .main
//           startButton.tintColor = .white
//           startButton.layer.cornerRadius = 10
//           startButton.translatesAutoresizingMaskIntoConstraints = false
//           
//           stepperContainer.addSubview(titleLabel)
//           stepperContainer.addSubview(durationStepper)
//           stepperContainer.addSubview(durationLabel)
//           stepperContainer.addSubview(startButton)
//           view.addSubview(stepperContainer)
//           
//           NSLayoutConstraint.activate([
//               stepperContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//               stepperContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//               stepperContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
//               stepperContainer.heightAnchor.constraint(equalToConstant: 200),
//               
//               titleLabel.topAnchor.constraint(equalTo: stepperContainer.topAnchor, constant: 20),
//               titleLabel.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
//               
//               durationStepper.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
//               durationStepper.centerYAnchor.constraint(equalTo: stepperContainer.centerYAnchor, constant: -10),
//               
//               durationLabel.topAnchor.constraint(equalTo: durationStepper.bottomAnchor, constant: 5),
//               durationLabel.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
//               
//               startButton.bottomAnchor.constraint(equalTo: stepperContainer.bottomAnchor, constant: -20),
//               startButton.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
//               startButton.widthAnchor.constraint(equalTo: stepperContainer.widthAnchor, multiplier: 0.8),
//               startButton.heightAnchor.constraint(equalToConstant: 44)
//           ])
//           
//           // Add target actions
//           durationStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
//           startButton.addTarget(self, action: #selector(startCalibrationTapped), for: .touchUpInside)
//           
//           // Set initial duration label
//           stepperValueChanged(durationStepper)
//       }
//       
//       @objc private func stepperValueChanged(_ sender: UIStepper) {
//           let minutes = Int(sender.value)
//           durationLabel.text = "\(minutes) Minute\(minutes > 1 ? "s" : "")"
//           duration = minutes * 60  // Convert to seconds
//       }
//       
//       @objc private func startCalibrationTapped() {
//           // Hide stepper container
//           if let stepperContainer = durationStepper.superview {
//               UIView.animate(withDuration: 0.3) {
//                   stepperContainer.alpha = 0
//               } completion: { _ in
//                   stepperContainer.removeFromSuperview()
//                   // Start calibration
//                   self.startCalibration()
//               }
//           }
//       }
//
//    @objc private func durationChanged(_ sender: UIStepper) {
//        if let alert = presentedViewController as? UIAlertController,
//           let durationLabel = alert.view.viewWithTag(101) as? UILabel {
//            let minutes = Int(sender.value)
//            durationLabel.text = "Duration: \(minutes) Minute\(minutes > 1 ? "s" : "")"
//            self.duration = minutes*60  // Convert minutes to seconds and store it
//        }
//    }
//    
//
//    private func setupUI() {
//        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
//        timerProgressBar.translatesAutoresizingMaskIntoConstraints = false
//        //        startButton.translatesAutoresizingMaskIntoConstraints = false
//        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(scoreLabel)
//        view.addSubview(timerProgressBar)
//        //        view.addSubview(startButton)
//        view.addSubview(countdownLabel)
//        view.addSubview(pauseResumeButton)
//        calibrationLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(calibrationLabel)
//        calibrationOverlay.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(calibrationOverlay)
//        view.addSubview(calibrationLabel)
//        view.addSubview(exerciseView)
//        exerciseView.addSubview(exerciseIcon)
//        exerciseView.addSubview(exerciseLabel)
//        view.addSubview(exerciseTimerLabel)
//        
//        exerciseView.translatesAutoresizingMaskIntoConstraints = false
//        exerciseIcon.translatesAutoresizingMaskIntoConstraints = false
//        exerciseLabel.translatesAutoresizingMaskIntoConstraints = false
//        exerciseTimerLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            
//            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            scoreLabel.widthAnchor.constraint(equalToConstant: 150),
//            scoreLabel.heightAnchor.constraint(equalToConstant: 50),
//            
//            pauseResumeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            pauseResumeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            pauseResumeButton.widthAnchor.constraint(equalToConstant: 40),
//            pauseResumeButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            timerProgressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
//            timerProgressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            timerProgressBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
//            
//            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
//            
//            calibrationOverlay.topAnchor.constraint(equalTo: view.topAnchor),
//            calibrationOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            calibrationOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            calibrationOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            calibrationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            calibrationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            calibrationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            calibrationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            exerciseView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            exerciseView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 60),
//            exerciseView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            exerciseView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            exerciseIcon.centerYAnchor.constraint(equalTo: exerciseView.centerYAnchor),
//            exerciseIcon.leadingAnchor.constraint(equalTo: exerciseView.leadingAnchor, constant: 10),
//            exerciseIcon.widthAnchor.constraint(equalToConstant: 60),
//            exerciseIcon.heightAnchor.constraint(equalToConstant: 60),
//            
//            exerciseLabel.centerYAnchor.constraint(equalTo: exerciseView.centerYAnchor),
//            exerciseLabel.leadingAnchor.constraint(equalTo: exerciseIcon.trailingAnchor, constant: 20),
//            exerciseLabel.trailingAnchor.constraint(equalTo: exerciseView.trailingAnchor, constant: -20),
//            
//            exerciseTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            exerciseTimerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//        ])
//        
//        pauseResumeButton.addTarget(self, action: #selector(togglePauseResume), for: .touchUpInside)
//    }
//    
//    private func setupCircularCountdownLayer() {
//        let radius: CGFloat = 100
//        let center = CGPoint(x: view.center.x, y: view.center.y - 100)
//        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(.pi / 2), endAngle: 1.5 * .pi, clockwise: true)
//        
//        countdownLayer = CAShapeLayer()
//        countdownLayer.path = circularPath.cgPath
//        countdownLayer.fillColor = UIColor.clear.cgColor
//        countdownLayer.strokeColor = UIColor.white.cgColor
//        countdownLayer.lineWidth = 10
//        countdownLayer.strokeEnd = 1
//        countdownLayer.isHidden = true
//        
//        view.layer.addSublayer(countdownLayer)
//    }
//    
//    private func setupCamera() {
//        captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .medium
//        
//        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
//            print("Front camera not available.")
//            return
//        }
//        
//        do {
//            let input = try AVCaptureDeviceInput(device: frontCamera)
//            captureSession.addInput(input)
//        } catch {
//            print("Error accessing front camera: \(error)")
//            return
//        }
//        
//        let output = AVCaptureVideoDataOutput()
//        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//        captureSession.addOutput(output)
//        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = view.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.insertSublayer(previewLayer, at: 0)
//        // Start capture session on a background thread to avoid UI blocking
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            self?.captureSession.startRunning()
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.startCalibration()
//        }
//    }
//    
//    private func startCalibration() {
//        speak("Calibration starting")
//        calibrationLabel.isHidden = false
//        calibrationLabel.text = "⚠️ Adjust yourself to the center of screen, stand upright!"
//    }
//    
//    private func startWorkout() {
//        countdownLabel.isHidden = false
//        calibrationLabel.isHidden = true
//        countdownLayer.isHidden = false
//        var countdown = 5
//        countdownLabel.text = "\(countdown)"
//        let totalTime: CGFloat = 5.0
//        var _: CGFloat = totalTime
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = 1.0
//        animation.toValue = 0.0
//        animation.duration = CFTimeInterval(totalTime)
//        animation.repeatCount = 1
//        calibrationOverlay.isHidden = true
//        countdownLayer.add(animation, forKey: "circularCountdown")
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
//            guard let self = self else { return }
//            countdown -= 1
//            self.countdownLabel.text = "\(countdown)"
//            if countdown == 0 {
//                timer.invalidate()
//                self.countdownLabel.isHidden = true
//                self.countdownLayer.isHidden = true
//                self.scoreLabel.isHidden = false
//                self.timerProgressBar.isHidden = false
//                self.pauseResumeButton.isHidden = false
//                self.startGameTimer(duration: self.duration)
//            }
//        }
//    }
//    
//    private func updateExerciseDisplay() {
//           guard let exercise = currentExercise else { return }
//           exerciseView.isHidden = false
//           exerciseTimerLabel.isHidden = false
//           exerciseIcon.image = UIImage(systemName: exercise.iconName)
//           exerciseLabel.text = exercise.displayName
//           exerciseTimerLabel.text = "\(exerciseDuration)s"
//    }
//    
//    private func startGameTimer(duration: Int) {
//        self.duration = duration  // Ensure the duration is set correctly
//        secondsElapsed = 0
//        currentExerciseIndex = 0
//        currentExerciseStartTime = 0
//        print("Game started with duration: \(duration) seconds")
//        currentExercise = Sequence.allCases[currentExerciseIndex]
//        updateExerciseDisplay()
//
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
//            guard let self = self, !self.isPaused else { return }
//            
//            self.secondsElapsed += 1
//            let progress = Float(self.secondsElapsed)/Float(duration)
//            self.timerProgressBar.progress = progress
//            
//            // Handle exercise transitions
//            let exerciseDuration = self.secondsElapsed - self.currentExerciseStartTime
//            if exerciseDuration >= 10 {
//                self.currentExerciseStartTime = self.secondsElapsed
//                self.currentExerciseIndex = (self.currentExerciseIndex + 1) % Sequence.allCases.count
//                self.currentExercise = Sequence.allCases[self.currentExerciseIndex]
//                self.updateExerciseDisplay()
//                self.speak(self.currentExercise?.instructions ?? "Next exercise")
//
//                self.exerciseSuccessCounter = 0
//                self.hasScoredForCurrentExercise = false
//            }
//            
//            self.exerciseTimerLabel.text = "\(10 - (exerciseDuration % 10))s"
//            
//            if self.secondsElapsed >= duration {
//                timer.invalidate()
//                self.endSession()
//            }
//        }
//        RunLoop.main.add(timer!, forMode: .common)
//    }
//    @objc private func togglePauseResume() {
//        isPaused.toggle()
//        
//        if isPaused {
//            timer?.invalidate()
//            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
//            pauseResumeButton.setImage(UIImage(systemName: "play", withConfiguration: config), for: .normal)
//        } else {
//            startGameTimer(duration: self.duration) // Restarts timing with current state
//            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
//            pauseResumeButton.setImage(UIImage(systemName: "pause", withConfiguration: config), for: .normal)
//        }
//    }
//    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        
//        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
//            guard let observations = request.results as? [VNHumanBodyPoseObservation],
//                  let self = self else { return }
//            
//            for observation in observations {
//                self.processPose(observation)
//            }
//        }
//        
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
//        
//        do {
//            try handler.perform([request])
//        } catch {
//            print("Pose detection error: \(error)")
//        }
//    }
//    
//    private func processPose(_ observation: VNHumanBodyPoseObservation) {
//        guard let leftWrist = try? observation.recognizedPoint(.leftWrist),
//              leftWrist.confidence > 0.5,
//              let leftElbow = try? observation.recognizedPoint(.leftElbow),
//              leftElbow.confidence > 0.5,
//              let leftShoulder = try? observation.recognizedPoint(.leftShoulder),
//              leftShoulder.confidence > 0.5,
//              let rightWrist = try? observation.recognizedPoint(.rightWrist),
//              rightWrist.confidence > 0.5,
//              let rightElbow = try? observation.recognizedPoint(.rightElbow),
//              rightElbow.confidence > 0.5,
//              let rightShoulder = try? observation.recognizedPoint(.rightShoulder),
//              rightShoulder.confidence > 0.5,
//              let leftHip = try? observation.recognizedPoint(.leftHip),
//              leftHip.confidence > 0.5,
//              let rightHip = try? observation.recognizedPoint(.rightHip),
//              rightHip.confidence > 0.5 else {
//            return
//        }
//        if !isCalibrated {
//            let midX = (leftShoulder.x + rightShoulder.x) / 2
//            let verticalAlignment = abs(leftShoulder.y - rightShoulder.y)
//            
//            if abs(midX - 0.5) < 0.1 && verticalAlignment < 0.1 {
//                DispatchQueue.main.async {
//                    self.handleSuccessfulCalibration()
//               }
//            } else {
//               DispatchQueue.main.async {
//                    self.handleCalibrationWarning()
//                }
//            }
//        return
//        }
//        guard let currentExercise = currentExercise else { return }
//        let leftWristDifference = leftWrist.y - leftShoulder.y
//        let rightWristDifference = rightWrist.y - rightShoulder.y
//        let leftArmAngle = calculateArmAngle(wrist: leftWrist, elbow: leftElbow, shoulder: leftShoulder)
//        let rightArmAngle = calculateArmAngle(wrist: rightWrist, elbow: rightElbow, shoulder: rightShoulder)
//        let verticalLeftAngle = calculateVerticalAngle(wrist: leftWrist, shoulder: leftShoulder)
//        let verticalRightAngle = calculateVerticalAngle(wrist: rightWrist, shoulder: rightShoulder)
//        
//        switch currentExercise {
//        case .leftArmUp:
//           if leftWristDifference > stretchThreshold && rightArmAngle < 45 {
//                print("\(leftWristDifference),\(rightArmAngle)")
//                self.isCorrectPosition = true
//            }
//            
//        case .rightArmUp:
//            if rightWristDifference > stretchThreshold {
//                print("\(rightWristDifference)")
//                self.isCorrectPosition = true
//            }
//        case .bothArms45:
//            let leftValid = (30...60).contains(abs(verticalLeftAngle))
//            let rightValid = (30...60).contains(abs(verticalRightAngle))
//            print("vertical angle:\(verticalLeftAngle), \(verticalRightAngle)")
//            self.isCorrectPosition = leftValid && rightValid
//            
//        case .bothArmsUp:
//            if leftWristDifference > stretchThreshold && rightWristDifference > stretchThreshold {
//                print("\(leftWristDifference), \(rightWristDifference)")
//                self.isCorrectPosition = true
//            }
//            
//        case .bothArmsDown:
//            let leftArmDown = leftArmAngle < 30 && leftWrist.y > leftHip.y
//            let rightArmDown = rightArmAngle < 30 && rightWrist.y > rightHip.y
//            self.isCorrectPosition = leftArmDown && rightArmDown
//        }
//        if isCorrectPosition {
//                    exerciseSuccessCounter += 1
//                } else {
//                    exerciseSuccessCounter = max(exerciseSuccessCounter - 1, 0)
//                }
//        if !hasScoredForCurrentExercise && exerciseSuccessCounter >= 6 {
//            DispatchQueue.main.async {
//                self.score += 10
//                self.dailyScore += 10
//                self.scoreLabel.text = "Score: \(self.score)"
//                print(self.score)
//                self.hasScoredForCurrentExercise = true
//            }
//        }
//        DispatchQueue.main.async {
//            self.updateExerciseUI(isCorrect: self.isCorrectPosition)
//                }
//            }
//
//    private func handleSuccessfulCalibration() {
//        calibrationLabel.text = "✅ Calibrated! Ready to start."
//        calibrationLabel.textColor = .white
//        calibrationOverlay.backgroundColor = UIColor.green.withAlphaComponent(0.4)
//        calibrationOverlay.isHidden = false
//        calibrationOverlay.alpha = 1
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            UIView.animate(withDuration: 0.5, animations: {
//                self.calibrationOverlay.alpha = 0
//            }) { _ in
//                self.calibrationOverlay.isHidden = true
//                self.isCalibrated = true
//                self.startWorkout()
//                
//            }
//        }
//    }
//
//    private func handleCalibrationWarning() {
//        calibrationLabel.text = "⚠️ Adjust your position"
//        calibrationLabel.textColor = .white
//        calibrationOverlay.backgroundColor = UIColor.red.withAlphaComponent(0.4)
//        calibrationOverlay.isHidden = false
//        calibrationOverlay.alpha = 1
//    }
//
//    private func updateExerciseUI(isCorrect: Bool) {
//        let backgroundColor = isCorrect ?
//            UIColor.systemGreen.withAlphaComponent(0.3) :
//            UIColor.systemRed.withAlphaComponent(0.3)
//            self.exerciseView.backgroundColor = backgroundColor
//    }
//    
//    private func calculateArmAngle(wrist: VNRecognizedPoint, elbow: VNRecognizedPoint, shoulder: VNRecognizedPoint) -> CGFloat {
//           let vector1 = CGVector(dx: elbow.x - shoulder.x, dy: elbow.y - shoulder.y)
//           let vector2 = CGVector(dx: wrist.x - elbow.x, dy: wrist.y - elbow.y)
//           
//           let angle = atan2(vector2.dy, vector2.dx) - atan2(vector1.dy, vector1.dx)
//           let degrees = abs(angle * 180 / .pi)
//           return degrees > 180 ? 360 - degrees : degrees
//        }
//    
//    private func calculateVerticalAngle(wrist: VNRecognizedPoint, shoulder: VNRecognizedPoint) -> CGFloat {
//                let deltaY = wrist.y - shoulder.y
//                let deltaX = wrist.x - shoulder.x
//                return atan2(deltaY, deltaX) * 180 / .pi
//            }
//    
//    private func endSession() {
//        // Show final score
//        captureSession?.stopRunning()
//        captureSession = nil
//        timer?.invalidate()
//        exerciseTimer?.invalidate()
//        exerciseView.isHidden = true
//        exerciseTimerLabel.isHidden = true
//        timerProgressBar.isHidden = true
//        speak("Great job! You scored \(score) points!")
//        let alert = UIAlertController(title: "Time's Up!", message: "Your score: \(score)", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//            self.dailyScore += self.score
//            self.dailyDuration += self.duration / 60
//            
//            print("Score after OVER tapped: \(self.dailyScore)")
//            
//            self.updateUserProgressInFirebase(duration: self.duration, score: self.dailyScore)
//
//            self.updateMonthlyStatsInFirebase(minutes: self.dailyDuration)
//            
//            self.presentSuccessViewController(duration: self.dailyDuration, score: self.dailyScore)
//            self.navigationController?.popToRootViewController(animated: true)
//        }))
//        present(alert, animated: true, completion: nil)
//    }
//
//    func updateUserProgressInFirebase(duration: Int, score: Int) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User is not logged in.")
//            return
//        }
//        
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(userId)
//        
//        userRef.getDocument { (document, error) in
//            if let error = error {
//                print("Error fetching document: \(error.localizedDescription)")
//                return
//            }
//            
//            if let document = document, document.exists {
//                var totalMinutes = document.get("totalMinutes") as? Int ?? 0
//                var totalPoints = document.get("totalPoints") as? Int ?? 0
//                var dailyMinutes = document.get("dailyMinutes") as? Int ?? 0
//                var dailyPoints = document.get("dailyPoints") as? Int ?? 0
//                let lastUpdateDate = document.get("lastUpdateDate") as? Timestamp ?? Timestamp(date: Date())
//                
//                let currentDate = Date()
//                if !self.isSameDay(currentDate, lastUpdateDate.dateValue()) {
//                    dailyMinutes = 0
//                    dailyPoints = 0
//                }
//                
//                // Update daily and total values
//                dailyMinutes += duration/60
//                dailyPoints += score
//                totalMinutes += duration/60
//                totalPoints += score
//                
//                // Log the data we're updating
//                print("Updating user data: \(totalMinutes) minutes, \(totalPoints) points")
//                
//                // Update Firestore with new values
//                userRef.updateData([
//                    "totalMinutes": totalMinutes,
//                    "totalPoints": totalPoints,
//                    "dailyMinutes": dailyMinutes,
//                    "dailyPoints": dailyPoints,
//                    "lastUpdateDate": Timestamp(date: currentDate)
//                ]) { error in
//                    if let error = error {
//                        print("Error updating Firestore: \(error.localizedDescription)")
//                    } else {
//                        print("User progress updated successfully in Firestore.")
//                        NotificationCenter.default.post(name: .progressUpdated, object: nil)
//                    }
//                }
//            } else {
//                print("Document does not exist or failed to fetch data.")
//            }
//        }
//    }
//    
//    func updateMonthlyStatsInFirebase(minutes: Int) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User is not logged in.")
//            return
//        }
//        
//        let db = Firestore.firestore()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM"
//        let monthString = dateFormatter.string(from: Date())
//        
//        let dayFormatter = DateFormatter()
//        dayFormatter.dateFormat = "dd"
//        let dayString = dayFormatter.string(from: Date())
//        
//        let monthlyStatsRef = db.collection("users").document(userId).collection("monthlyStats").document(monthString)
//        
//        monthlyStatsRef.getDocument { (document, error) in
//            if let error = error {
//                print("Error fetching monthlyStats: \(error.localizedDescription)")
//                return
//            }
//            
//            var dailyMinutes = [String: Int]()
//            var streak = 0
//            var lastActiveDay: Int?
//            
//            if let data = document?.data(), let existingDailyMinutes = data["dailyMinutes"] as? [String: Int] {
//                dailyMinutes = existingDailyMinutes
//                
//                // Get the last active day if available
//                lastActiveDay = existingDailyMinutes.keys.compactMap { Int($0) }.sorted().last
//                streak = data["streak"] as? Int ?? 0
//            }
//            
//            // Update minutes for the current day
//            if let currentDayMinutes = dailyMinutes[dayString] {
//                dailyMinutes[dayString] = currentDayMinutes + minutes
//            } else {
//                dailyMinutes[dayString] = minutes
//            }
//            
//            // Check if the current day is consecutive to the last active day
//            if let lastActive = lastActiveDay, let currentDay = Int(dayString), currentDay == lastActive + 1 {
//                streak += 1
//            } else {
//                // Reset the streak if the current day is not consecutive
//                streak = 1
//            }
//            
//            let totalMinutes = dailyMinutes.values.reduce(0, +)
//            
//            // Update Firestore with new data
//            monthlyStatsRef.setData([
//                "month": monthString,
//                "dailyMinutes": dailyMinutes,
//                "totalMinutes": totalMinutes,
//                "streak": streak
//            ], merge: true) { error in
//                if let error = error {
//                    print("Error updating monthlyStats: \(error.localizedDescription)")
//                } else {
//                    print("Monthly stats updated successfully in Firestore.")
//                }
//            }
//        }
//    }
//        
//        
//        func showAlert(title: String, message: String) {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alert, animated: true)
//        }
//        
//        func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
//            let calendar = Calendar.current
//            return calendar.isDate(date1, inSameDayAs: date2)
//        }
//        
//        func presentSuccessViewController(duration: Int, score: Int) {
//            let successVC = storyboard?.instantiateViewController(withIdentifier: "GameSuccessViewController") as! GameSuccessViewController
//            successVC.totalDuration = duration
//            successVC.finalScore = score
//            present(successVC, animated: true, completion: nil)
//        }
//    }

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

extension Notification.Name {
    static let progressUpdated = Notification.Name("progressUpdated")
}

class GameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var userId: String? // Make sure you have the current user's ID
    var dailyDuration: Int = 0
    var dailyScore: Int = 0
    
    //MARK: - Game Variable
    
    var duration = 0
    
    private var captureSession: AVCaptureSession!
    private var score = 0
    private var timer: Timer?
    private var exerciseTimer: Timer?
    private var secondsElapsed = 0
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var isPaused = false
    private var isCalibrated = false
    private var stretchThreshold: CGFloat = 0.1
    private var currentExerciseIndex = 0
    private var currentExercise: Sequence? = nil
    private var exerciseDuration = 10 // Seconds per exercise
    private var exerciseTimeRemaining = 0
    private var exerciseSuccessCounter = 0
    private var currentExerciseStartTime = 0
    private var hasScoredForCurrentExercise = false
    var isCorrectPosition = false
    
    private lazy var durationStepper: UIStepper = {
           let stepper = UIStepper()
           stepper.minimumValue = 1
           stepper.maximumValue = 10
           stepper.stepValue = 1
           stepper.value = 3  // Default value
           stepper.translatesAutoresizingMaskIntoConstraints = false
           return stepper
       }()
       
       private lazy var durationLabel: UILabel = {
           let label = UILabel()
           label.font = UIFont.boldSystemFont(ofSize: 20)
           label.textColor = .white
           label.textAlignment = .center
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
       }()
       
       private lazy var stepperContainer: UIView = {
           let view = UIView()
           view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
           view.layer.cornerRadius = 12
           view.translatesAutoresizingMaskIntoConstraints = false
           return view
       }()
       
       private lazy var stepperTitleLabel: UILabel = {
           let label = UILabel()
           label.text = "Select Workout Duration"
           label.font = UIFont.boldSystemFont(ofSize: 24)
           label.textColor = .white
           label.textAlignment = .center
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
       }()
       
       private lazy var startCalibrationButton: UIButton = {
           let button = UIButton(type: .system)
           button.setTitle("Start Calibration", for: .normal)
           button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
           button.backgroundColor = .main
           button.tintColor = .white
           button.layer.cornerRadius = 10
           button.translatesAutoresizingMaskIntoConstraints = false
           return button
       }()
    
    private let exerciseView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let exerciseIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .cyan
        return iv
    }()
    
    private let exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 8
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
    }()
    private let exerciseTimerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 60)
        label.textColor = .red
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    private let calibrationOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        overlay.layer.cornerRadius = 20
        overlay.isHidden = false
        return overlay
    }()
    private let calibrationLabel: UILabel = {
        let label = UILabel()
        label.text = "⚠️ Adjust yourself to the center of screen, stand with your entire body visible!"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 10
        label.numberOfLines=0
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    private let pauseResumeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        button.setImage(UIImage(systemName: "pause", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Score : 0"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .cyan
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        label.isHidden = true
        return label
    }()
    private func speak(_ text: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.3
            self.speechSynthesizer.speak(utterance)
        }
    }

    private var countdownLayer: CAShapeLayer!
    private let timerProgressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progressTintColor = .systemGreen
        progressBar.trackTintColor = .systemGray
        progressBar.isHidden = true
        return progressBar
    }()
    
    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 48)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupCamera()
        setupUI()
        showDurationStepper()
        setupCircularCountdownLayer()
    }
    
    // MARK: - CHANGED: Smooth countdown with CADisplayLink
    private var displayLink: CADisplayLink?
    private var countdownStartTime: CFTimeInterval = 0
    var isCountdownActive = false

    private func startWorkout() {
        guard !isCountdownActive else { return }
        isCountdownActive = true
        calibrationLabel.isHidden = true
        countdownLabel.isHidden = false
        
        // Reset animation state
        countdownLayer.removeAllAnimations()
        countdownStartTime = CACurrentMediaTime()
        
        // Configure circular path
        let radius: CGFloat = 100
        let center = CGPoint(x: view.center.x, y: view.center.y - 100)
        let circularPath = UIBezierPath(arcCenter: center, radius: radius,
                                      startAngle: -(.pi/2), endAngle: 1.5 * .pi, clockwise: true)
        
        // Configure countdown layer
        countdownLayer.path = circularPath.cgPath
        countdownLayer.strokeEnd = 1.0
        countdownLayer.isHidden = false
        
        // Animation setup
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 5.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        countdownLayer.add(animation, forKey: "circularCountdown")
        
        // Start display link
        displayLink = CADisplayLink(target: self, selector: #selector(updateCountdown))
        displayLink?.add(to: .main, forMode: .common)
        
        // Final transition
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.transitionToWorkout()
        }
    }

    @objc private func updateCountdown() {
        let elapsed = CACurrentMediaTime() - countdownStartTime
        let remaining = 5.0 - elapsed
        countdownLabel.text = String(format: "%d", Int(ceil(remaining)))
    }

    private func transitionToWorkout() {
        displayLink?.invalidate()
        countdownLabel.isHidden = true
        countdownLayer.isHidden = true
        scoreLabel.isHidden = false
        timerProgressBar.isHidden = false
        pauseResumeButton.isHidden = false
        startGameTimer(duration: duration)
        isCountdownActive = false
    }
    private func showDurationStepper() {
           // Create a container view for the stepper UI
           let stepperContainer = UIView()
           stepperContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
           stepperContainer.layer.cornerRadius = 12
           stepperContainer.translatesAutoresizingMaskIntoConstraints = false
           
           let titleLabel = UILabel()
           titleLabel.text = "Select Workout Duration"
           titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
           titleLabel.textColor = .white
           titleLabel.textAlignment = .center
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           
           let startButton = UIButton(type: .system)
           startButton.setTitle("Start Calibration", for: .normal)
           startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
           startButton.backgroundColor = .main
           startButton.tintColor = .white
           startButton.layer.cornerRadius = 10
           startButton.translatesAutoresizingMaskIntoConstraints = false
           
           stepperContainer.addSubview(titleLabel)
           stepperContainer.addSubview(durationStepper)
           stepperContainer.addSubview(durationLabel)
           stepperContainer.addSubview(startButton)
           view.addSubview(stepperContainer)
           
           NSLayoutConstraint.activate([
               stepperContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               stepperContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
               stepperContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
               stepperContainer.heightAnchor.constraint(equalToConstant: 200),
               
               titleLabel.topAnchor.constraint(equalTo: stepperContainer.topAnchor, constant: 20),
               titleLabel.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
               
               durationStepper.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
               durationStepper.centerYAnchor.constraint(equalTo: stepperContainer.centerYAnchor, constant: -10),
               
               durationLabel.topAnchor.constraint(equalTo: durationStepper.bottomAnchor, constant: 5),
               durationLabel.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
               
               startButton.bottomAnchor.constraint(equalTo: stepperContainer.bottomAnchor, constant: -20),
               startButton.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
               startButton.widthAnchor.constraint(equalTo: stepperContainer.widthAnchor, multiplier: 0.8),
               startButton.heightAnchor.constraint(equalToConstant: 44)
           ])
           
           // Add target actions
           durationStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
           startButton.addTarget(self, action: #selector(startCalibrationTapped), for: .touchUpInside)
           
           // Set initial duration label
           stepperValueChanged(durationStepper)
       }
       
       @objc private func stepperValueChanged(_ sender: UIStepper) {
           let minutes = Int(sender.value)
           durationLabel.text = "\(minutes) Minute\(minutes > 1 ? "s" : "")"
           duration = minutes * 60  // Convert to seconds
       }
       

    @objc private func durationChanged(_ sender: UIStepper) {
        if let alert = presentedViewController as? UIAlertController,
           let durationLabel = alert.view.viewWithTag(101) as? UILabel {
            let minutes = Int(sender.value)
            durationLabel.text = "Duration: \(minutes) Minute\(minutes > 1 ? "s" : "")"
            self.duration = minutes*60  // Convert minutes to seconds and store it
        }
    }
    

    private func setupUI() {
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        timerProgressBar.translatesAutoresizingMaskIntoConstraints = false
        //        startButton.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scoreLabel)
        view.addSubview(timerProgressBar)
        //        view.addSubview(startButton)
        view.addSubview(countdownLabel)
        view.addSubview(pauseResumeButton)
        calibrationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calibrationLabel)
        calibrationOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calibrationOverlay)
        view.addSubview(calibrationLabel)
        view.addSubview(exerciseView)
        exerciseView.addSubview(exerciseIcon)
        exerciseView.addSubview(exerciseLabel)
        view.addSubview(exerciseTimerLabel)
        
        exerciseView.translatesAutoresizingMaskIntoConstraints = false
        exerciseIcon.translatesAutoresizingMaskIntoConstraints = false
        exerciseLabel.translatesAutoresizingMaskIntoConstraints = false
        exerciseTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.widthAnchor.constraint(equalToConstant: 150),
            scoreLabel.heightAnchor.constraint(equalToConstant: 50),
            
            pauseResumeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pauseResumeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pauseResumeButton.widthAnchor.constraint(equalToConstant: 40),
            pauseResumeButton.heightAnchor.constraint(equalToConstant: 40),
            
            timerProgressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            timerProgressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerProgressBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            
            calibrationOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            calibrationOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calibrationOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calibrationOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            calibrationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            calibrationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calibrationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calibrationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            exerciseView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exerciseView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 60),
            exerciseView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exerciseView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            exerciseIcon.centerYAnchor.constraint(equalTo: exerciseView.centerYAnchor),
            exerciseIcon.leadingAnchor.constraint(equalTo: exerciseView.leadingAnchor, constant: 10),
            exerciseIcon.widthAnchor.constraint(equalToConstant: 60),
            exerciseIcon.heightAnchor.constraint(equalToConstant: 60),
            
            exerciseLabel.centerYAnchor.constraint(equalTo: exerciseView.centerYAnchor),
            exerciseLabel.leadingAnchor.constraint(equalTo: exerciseIcon.trailingAnchor, constant: 20),
            exerciseLabel.trailingAnchor.constraint(equalTo: exerciseView.trailingAnchor, constant: -20),
            
            exerciseTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exerciseTimerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        pauseResumeButton.addTarget(self, action: #selector(togglePauseResume), for: .touchUpInside)
    }
    
    private func setupCircularCountdownLayer() {
        let radius: CGFloat = 100
        let center = CGPoint(x: view.center.x, y: view.center.y - 100)
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(.pi / 2), endAngle: 1.5 * .pi, clockwise: true)
        
        countdownLayer = CAShapeLayer()
        countdownLayer.path = circularPath.cgPath
        countdownLayer.fillColor = UIColor.clear.cgColor
        countdownLayer.strokeColor = UIColor.white.cgColor
        countdownLayer.lineWidth = 10
        countdownLayer.strokeEnd = 1
        countdownLayer.isHidden = true
        
        view.layer.addSublayer(countdownLayer)
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Front camera not available.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            captureSession.addInput(input)
        } catch {
            print("Error accessing front camera: \(error)")
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(output)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        // Start capture session on a background thread to avoid UI blocking
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.startCalibration()
//        }
    }
    
    private func startCalibration() {
        speak("Calibration starting")
        calibrationLabel.isHidden = false
        calibrationLabel.text = "⚠️ Adjust yourself to the center of screen, stand upright!"
        calibrationOverlay.isHidden = false
    }
    
    @objc private func startCalibrationTapped() {
        if let stepperContainer = durationStepper.superview {
            UIView.animate(withDuration: 0.3) {
                stepperContainer.alpha = 0
            } completion: { _ in
                stepperContainer.removeFromSuperview()
                self.startCalibration()
            }
        }
    }
    
    private func updateExerciseDisplay() {
           guard let exercise = currentExercise else { return }
           exerciseView.isHidden = false
           exerciseTimerLabel.isHidden = false
           exerciseIcon.image = UIImage(systemName: exercise.iconName)
           exerciseLabel.text = exercise.displayName
           exerciseTimerLabel.text = "\(exerciseDuration)s"
    }
    
    private func resetExerciseTracking() {
        exerciseSuccessCounter = 0
        hasScoredForCurrentExercise = false
        isCorrectPosition = false
        updateExerciseUI(isCorrect: false)
    }

    // MARK: - Updated game timer setup
    private func startGameTimer(duration: Int) {
        self.duration = duration
        secondsElapsed = 0
        currentExerciseIndex = 0
        currentExerciseStartTime = 0
        currentExercise = Sequence.allCases[currentExerciseIndex]
        resetExerciseTracking()
        
        // ADDED: Speak first exercise instructions immediately
        speak(currentExercise?.instructions ?? "Start exercise")
        updateExerciseDisplay()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, !self.isPaused else { return }
            
            self.secondsElapsed += 1
            let exerciseDuration = self.secondsElapsed - self.currentExerciseStartTime
            
            // Update timer display
            self.exerciseTimerLabel.text = "\(10 - (exerciseDuration % 10))s"
            self.timerProgressBar.progress = Float(self.secondsElapsed)/Float(duration)
            
            // Exercise transition logic
            if exerciseDuration >= 10 {
                self.switchToNextExercise()
            }
            
            // Session completion
            if self.secondsElapsed >= duration {
                timer.invalidate()
                self.endSession()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func switchToNextExercise() {
        currentExerciseStartTime = secondsElapsed
        currentExerciseIndex = (currentExerciseIndex + 1) % Sequence.allCases.count
        currentExercise = Sequence.allCases[currentExerciseIndex]
        
        // Ensure voice instructions
        speak(currentExercise?.instructions ?? "Next exercise")
        updateExerciseDisplay()
        resetExerciseTracking()
    }
    @objc private func togglePauseResume() {
        isPaused.toggle()
        
        if isPaused {
            timer?.invalidate()
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            pauseResumeButton.setImage(UIImage(systemName: "play", withConfiguration: config), for: .normal)
        } else {
            startGameTimer(duration: self.duration) // Restarts timing with current state
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            pauseResumeButton.setImage(UIImage(systemName: "pause", withConfiguration: config), for: .normal)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            guard let observations = request.results as? [VNHumanBodyPoseObservation],
                  let self = self else { return }
            
            for observation in observations {
                self.processPose(observation)
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Pose detection error: \(error)")
        }
    }
    
    private func processPose(_ observation: VNHumanBodyPoseObservation) {
        guard let leftWrist = try? observation.recognizedPoint(.leftWrist),
              leftWrist.confidence > 0.5,
              let leftElbow = try? observation.recognizedPoint(.leftElbow),
              leftElbow.confidence > 0.5,
              let leftShoulder = try? observation.recognizedPoint(.leftShoulder),
              leftShoulder.confidence > 0.5,
              let rightWrist = try? observation.recognizedPoint(.rightWrist),
              rightWrist.confidence > 0.5,
              let rightElbow = try? observation.recognizedPoint(.rightElbow),
              rightElbow.confidence > 0.5,
              let rightShoulder = try? observation.recognizedPoint(.rightShoulder),
              rightShoulder.confidence > 0.5,
              let leftHip = try? observation.recognizedPoint(.leftHip),
              leftHip.confidence > 0.5,
              let rightHip = try? observation.recognizedPoint(.rightHip),
              rightHip.confidence > 0.5 else {
            return
        }
        if !isCalibrated {
            let midX = (leftShoulder.x + rightShoulder.x) / 2
            let verticalAlignment = abs(leftShoulder.y - rightShoulder.y)
            
            if abs(midX - 0.5) < 0.1 && verticalAlignment < 0.1 {
                DispatchQueue.main.async {
                    self.handleSuccessfulCalibration()
               }
            } else {
               DispatchQueue.main.async {
                    self.handleCalibrationWarning()
                }
            }
        return
        }
        guard let currentExercise = currentExercise else { return }
        let leftWristDifference = leftWrist.y - leftShoulder.y
        let rightWristDifference = rightWrist.y - rightShoulder.y
        let leftArmAngle = calculateArmAngle(wrist: leftWrist, elbow: leftElbow, shoulder: leftShoulder)
        let rightArmAngle = calculateArmAngle(wrist: rightWrist, elbow: rightElbow, shoulder: rightShoulder)
        let verticalLeftAngle = calculateVerticalAngle(wrist: leftWrist, shoulder: leftShoulder)
        let verticalRightAngle = calculateVerticalAngle(wrist: rightWrist, shoulder: rightShoulder)
        
        switch currentExercise {
        case .leftArmUp:
           if leftWristDifference > stretchThreshold && rightArmAngle < 45 {
                print("left :\(leftWristDifference),\(rightArmAngle)")
                self.isCorrectPosition = true
            }
            
        case .rightArmUp:
            if rightWristDifference > stretchThreshold {
                print("right: \(rightWristDifference)")
                self.isCorrectPosition = true
            }
        case .bothArms45:
            let leftValid = (30...60).contains(abs(verticalLeftAngle))
            let rightValid = (30...60).contains(abs(verticalRightAngle))
            print("vertical angle:\(verticalLeftAngle), \(verticalRightAngle)")
            self.isCorrectPosition = leftValid && rightValid
            
        case .bothArmsUp:
            if leftWristDifference > stretchThreshold && rightWristDifference > stretchThreshold {
                print("both arms up : \(leftWristDifference), \(rightWristDifference)")
                self.isCorrectPosition = true
            }
            
        case .bothArmsDown:
            let leftArmDown = leftArmAngle < 30 && leftWrist.y > leftHip.y
            let rightArmDown = rightArmAngle < 30 && rightWrist.y > rightHip.y
            self.isCorrectPosition = leftArmDown && rightArmDown
            print("both arms down")
            
        }
        if isCorrectPosition {
                    exerciseSuccessCounter += 1
                } else {
                    exerciseSuccessCounter = max(exerciseSuccessCounter - 1, 0)
                }
        if !hasScoredForCurrentExercise && exerciseSuccessCounter >= 6 {
            DispatchQueue.main.async {
                self.score += 10
                self.dailyScore += 10
                self.scoreLabel.text = "Score: \(self.score)"
                print(self.score)
                self.hasScoredForCurrentExercise = true
            }
        }
        DispatchQueue.main.async {
            self.updateExerciseUI(isCorrect: self.isCorrectPosition)
                }
            }

    private func handleSuccessfulCalibration() {
        calibrationLabel.text = "✅ Calibrated! Ready to start."
        calibrationLabel.textColor = .white
        calibrationOverlay.backgroundColor = UIColor.green.withAlphaComponent(0.4)
        calibrationOverlay.isHidden = false
        calibrationOverlay.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.5, animations: {
                self.calibrationOverlay.alpha = 0
            }) { _ in
                self.calibrationOverlay.isHidden = true
                self.isCalibrated = true
                self.startWorkout()
                
            }
        }
    }

    private func handleCalibrationWarning() {
        calibrationLabel.text = "⚠️ Adjust your position"
        calibrationLabel.textColor = .white
        calibrationOverlay.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        calibrationOverlay.isHidden = false
        calibrationOverlay.alpha = 1
    }

    private func updateExerciseUI(isCorrect: Bool) {
        let backgroundColor = isCorrect ?
            UIColor.systemGreen.withAlphaComponent(0.3) :
            UIColor.systemRed.withAlphaComponent(0.3)
            self.exerciseView.backgroundColor = backgroundColor
    }
    
    private func calculateArmAngle(wrist: VNRecognizedPoint, elbow: VNRecognizedPoint, shoulder: VNRecognizedPoint) -> CGFloat {
           let vector1 = CGVector(dx: elbow.x - shoulder.x, dy: elbow.y - shoulder.y)
           let vector2 = CGVector(dx: wrist.x - elbow.x, dy: wrist.y - elbow.y)
           
           let angle = atan2(vector2.dy, vector2.dx) - atan2(vector1.dy, vector1.dx)
           let degrees = abs(angle * 180 / .pi)
           return degrees > 180 ? 360 - degrees : degrees
        }
    
    private func calculateVerticalAngle(wrist: VNRecognizedPoint, shoulder: VNRecognizedPoint) -> CGFloat {
                let deltaY = wrist.y - shoulder.y
                let deltaX = wrist.x - shoulder.x
                return atan2(deltaY, deltaX) * 180 / .pi
            }
    
    private func endSession() {
        // Show final score
        captureSession?.stopRunning()
        captureSession = nil
        timer?.invalidate()
        exerciseTimer?.invalidate()
        exerciseView.isHidden = true
        exerciseTimerLabel.isHidden = true
        timerProgressBar.isHidden = true
        speak("Great job! You scored \(score*2) points!")
        let alert = UIAlertController(title: "Time's Up!", message: "Your score: \(score*2)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dailyScore += self.score
            self.dailyDuration += self.duration / 60
            
            print("Score after OVER tapped: \(self.dailyScore)")
            
            self.updateUserProgressInFirebase(duration: self.duration, score: self.dailyScore)

            self.updateMonthlyStatsInFirebase(minutes: self.dailyDuration)
            
            self.presentSuccessViewController(duration: self.dailyDuration, score: self.dailyScore)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
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
                dailyMinutes += duration/60
                dailyPoints += score
                totalMinutes += duration/60
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
