//
//  DescriptionViewController.swift
//  DeskBreak_Test
//
//  Created by admin44 on 17/11/24.
//

import UIKit
import Firebase
import AVKit

class DescriptionViewController: UIViewController {
    
    @IBOutlet weak var exerciseImage: UIImageView!
    
    @IBOutlet weak var exerciseDescription: UITextView!
    
    var game = Game(name: "High 5", description: "High 5 is a gamified DeskBreak Stretching Exercise—perfect for when you're feeling lazy or tired. Stretch to rejuvenate and boost your energy right at your desk!", points: "10", photo: "game1", time: "10")

    let db = Firestore.firestore()
    var gameDocPath: String {
        return "games/\(game.name)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = game.name
        exerciseDescription.text = game.description
        exerciseImage.image = UIImage(named: game.photo)
        checkAndResetPlayerCount()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        incrementPlayerCount()
    }
    
    @IBAction func TutorialButton(_ sender: UIButton) {
        playTutorialVideo()
    }
    
    private func playTutorialVideo() {
        guard let videoPath = Bundle.main.path(forResource: "HighV_Tutorial", ofType: "mp4") else {
            print("Video file not found")
            return
        }
        
        let videoURL = URL(fileURLWithPath: videoPath)
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        // Listen for video completion
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)

        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    @objc private func videoDidFinish() {
        dismiss(animated: true, completion: nil)
    }

    private func incrementPlayerCount() {
        let gameDoc = db.document(gameDocPath)
        
        gameDoc.getDocument { snapshot, error in
            if let error = error {
                print("Error checking game document: \(error.localizedDescription)")
                return
            }
            
            if snapshot?.exists == false {
                // Create the document if it doesn't exist
                gameDoc.setData([
                    "playerCountThisWeek": 1,
                    "lastResetDate": ""
                ]) { error in
                    if let error = error {
                        print("Error creating game document: \(error.localizedDescription)")
                    } else {
                        print("Game document created and player count initialized.")
                    }
                }
            } else {
                // Increment the player count if the document exists
                gameDoc.updateData([
                    "playerCountThisWeek": FieldValue.increment(Int64(1))
                ]) { error in
                    if let error = error {
                        print("Error incrementing player count: \(error.localizedDescription)")
                    } else {
                        print("Player count incremented successfully.")
                    }
                }
            }
        }
    }


    private func checkAndResetPlayerCount() {
        let gameDoc = db.document(gameDocPath)

        gameDoc.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching game document: \(error.localizedDescription)")
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let today = formatter.string(from: Date())

            if let lastResetDate = snapshot?.get("lastResetDate") as? String, lastResetDate == today {
                print("Player count has already been reset today.")
                return
            }

            // Check if today is Sunday
            let calendar = Calendar.current
            if calendar.component(.weekday, from: Date()) == 1 { // 1 = Sunday
                self.resetPlayerCount(today: today)
            }
        }
    }

    private func resetPlayerCount(today: String) {
        let gameDoc = db.document(gameDocPath)
        
        gameDoc.setData([
            "playerCountThisWeek": 0,
            "lastResetDate": today
        ], merge: true) { error in
            if let error = error {
                print("Error resetting player count: \(error.localizedDescription)")
            } else {
                print("Player count reset successfully.")
            }
        }
    }
}
