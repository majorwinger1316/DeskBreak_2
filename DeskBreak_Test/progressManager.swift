//
//  progressManager.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 11/12/24.
//

import Foundation
import FirebaseFirestore

class ProgressManager {
    static let shared = ProgressManager()
    private let db = Firestore.firestore()
    
    func updateUserProgress(userId: String, minutes: Int, points: Int, completion: ((Error?) -> Void)? = nil) {
        db.collection("users").document(userId).updateData([
            "dailyMinutes": FieldValue.increment(Int64(minutes)),
            "dailyPoints": FieldValue.increment(Int64(points))
        ]) { error in
            completion?(error)
        }
    }
    
    func fetchUserProgress(userId: String, completion: @escaping (Float, Int) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let dailyMinutes = data["dailyMinutes"] as? Float,
               let dailyPoints = data["dailyPoints"] as? Int {
                completion(dailyMinutes, dailyPoints)
            } else {
                print("Error fetching user progress: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func observeUserProgress(userId: String, onUpdate: @escaping (Float, Int) -> Void) {
        db.collection("users").document(userId).addSnapshotListener { snapshot, error in
            if let data = snapshot?.data(),
               let dailyMinutes = data["dailyMinutes"] as? Float,
               let dailyPoints = data["dailyPoints"] as? Int {
                onUpdate(dailyMinutes, dailyPoints)
            } else {
                print("Error observing user progress: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
