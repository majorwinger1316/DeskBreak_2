//
//  GameSuccessViewController.swift
//  DeskBreak_Test
//
//  Created by admin44 on 17/11/24.
//

import UIKit
import FirebaseFirestore

class GameSuccessViewController: UIViewController {
    
    var finalScore : Int = 0
    var totalDuration : Int = 0
    var currentUser: User?
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var minutesLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = "\(finalScore)"
        minutesLabel.text = "\(totalDuration)"
        profileImage.image = UIImage(named: "defaultProfileImage")
        
        fetchTotalPoints()
        displayConfetti()
    }
    
    private func fetchTotalPoints() {
        guard let userId = currentUser?.userId else {
            print("Current user is not available.")
            return
        }
        
        print("Fetching totalPoints for userId: \(userId)")
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching totalPoints: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found for userId: \(userId)")
                return
            }
            
            print("Fetched data for userId \(userId): \(data)")
            
            if let totalPoints = data["totalPoints"] as? Int {
                DispatchQueue.main.async {
                    print("TotalPoints (Int): \(totalPoints)")
                }
            } else if let totalPoints = data["totalPoints"] as? Double {
                DispatchQueue.main.async {
                    print("TotalPoints (Double): \(totalPoints)")
                }
            } else {
                print("totalPoints field is missing or invalid for userId: \(userId)")
                DispatchQueue.main.async {
                }
            }
        }
    }
    
    private func displayConfetti() {
        let confettiEmitter = CAEmitterLayer()
        confettiEmitter.emitterPosition = CGPoint(x: view.bounds.midX, y: 0)
        confettiEmitter.emitterShape = .line
        confettiEmitter.emitterSize = CGSize(width: view.bounds.size.width, height: 1)

        let confettiCell = CAEmitterCell()
        confettiCell.birthRate = 50
        confettiCell.lifetime = 10
        confettiCell.lifetimeRange = 3
        confettiCell.velocity = 150
        confettiCell.velocityRange = 50
        confettiCell.emissionLongitude = .pi
        confettiCell.emissionRange = .pi / 4
        confettiCell.spin = 4
        confettiCell.spinRange = 2
        confettiCell.scale = 0.1
        confettiCell.scaleRange = 0.2

        confettiCell.contents = UIImage(named: "confetti")?.cgImage
        
        confettiEmitter.emitterCells = [confettiCell]
        view.layer.addSublayer(confettiEmitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            confettiEmitter.birthRate = 0
        }
    }

    private func generateCongratsMessage() -> String {
        switch finalScore {
        case 0..<50:
            return "Good effort! Keep trying!"
        case 50..<100:
            return "Well done! You're getting better!"
        case 100...:
            return "Amazing work! You're a star!"
        default:
            return "Keep it up!"
        }
    }
}
