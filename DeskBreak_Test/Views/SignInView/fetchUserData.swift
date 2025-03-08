//
//  fetchUserData.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 27/02/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

func fetchUserData(userId: String, viewController: signInViewController) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userId)
    
    userRef.getDocument { (documentSnapshot, error) in
        if let error = error {
            viewController.activityIndicator.stopAnimating()
            viewController.showAlert(message: "Error fetching user data: \(error.localizedDescription)")
            return
        }

        guard let document = documentSnapshot, document.exists, let userData = document.data() else {
            viewController.activityIndicator.stopAnimating()
            viewController.showAlert(message: "User data not found.")
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: "userId")
        defaults.set(userData["username"] as? String ?? "Unknown", forKey: "userName")
        defaults.set(userData["email"] as? String ?? "", forKey: "userEmail")
        defaults.set(userData["dailyTarget"] as? Int16 ?? 0, forKey: "dailyTarget")
        defaults.set(userData["totalMinutes"] as? Int32 ?? 0, forKey: "totalMinutes")
        defaults.set(userData["totalPoints"] as? Int32 ?? 0, forKey: "totalPoints")
        
        defaults.set(true, forKey: "isLoggedIn")
        
        if let profilePictureURLString = userData["profilePicture"] as? String,
           let profilePictureURL = URL(string: profilePictureURLString) {
            viewController.downloadProfileImage(from: profilePictureURL)
        }

        viewController.activityIndicator.stopAnimating()
        viewController.animateToTabBarController()
    }
}
