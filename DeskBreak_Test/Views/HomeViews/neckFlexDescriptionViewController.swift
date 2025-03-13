//
//  neckFlexDescriptionViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 18/02/25.
//

import Firebase
import UIKit

class neckFlexDescriptionViewController: UIViewController {
    
    @IBOutlet weak var gamePic: UIImageView!
    
    var game = Game(name: "NeckFlex", description: "NeckFlex is a DeskBreak stretching exercise designed to relieve neck stiffness and discomfort. Perfect for quick breaks, it helps improve flexibility and reduce tension.", points: "10", photo: "NeckFlex_info", time: "1-10")

    let db = Firestore.firestore()
    var gameDocPath: String {
        return "games/\(game.name)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = game.name
        gamePic.image = UIImage(named: game.photo)
        checkAndResetPlayerCount()
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
