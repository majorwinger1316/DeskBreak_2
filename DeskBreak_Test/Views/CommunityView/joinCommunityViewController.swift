//
//  joinCommunityViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 19/03/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol JoinCommunityDelegate: AnyObject {
    func didJoinCommunity()
}

class joinCommunityViewController: UIViewController {
    
    weak var delegate: JoinCommunityDelegate?
    
    @IBOutlet weak var communityCodeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard Auth.auth().currentUser != nil else {
            showAlert(title: "Error", message: "User not authenticated. Please log in.")
            return
        }
        
        communityCodeTextField.placeholder = "Enter Community Code"
        communityCodeTextField.delegate = self
        communityCodeTextField.autocapitalizationType = .allCharacters
        communityCodeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func joinButton(_ sender: UIBarButtonItem) {
        guard let code = communityCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid community code.")
            return
        }
        
        joinCommunity(code: code)
    }
    
    func addMemberToCommunity(communityId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let memberData: [String: Any] = [
            "userId": userId,
            "joinedAt": Date()
        ]
        
        db.collection("communities").document(communityId).collection("members").document(userId).setData(memberData) { error in
            if let error = error {
                print("Error adding member: \(error.localizedDescription)")
            } else {
                print("Member added successfully.")
            }
            completion(error)
        }
    }
    
    func joinCommunity(code: String) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "User not authenticated. Please log in.")
            return
        }

        db.collection("communities")
            .whereField("communityCode", isEqualTo: code)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to check community: \(error.localizedDescription)")
                    return
                }

                guard let communityDocument = querySnapshot?.documents.first else {
                    self.showAlert(title: "Error", message: "Community with the code \(code) not found.")
                    return
                }

                let communityId = communityDocument.documentID

                self.checkIfUserIsMember(communityId: communityId, userId: userId) { isMember in
                    if isMember {
                        self.showAlert(title: "Already a Member", message: "You are already a member of this community.")
                    } else {
                        self.addMemberToCommunity(communityId: communityId, userId: userId) { membershipError in
                            if let membershipError = membershipError {
                                self.showAlert(title: "Error", message: "Failed to join community: \(membershipError.localizedDescription)")
                            } else {
                                self.showAlert(title: "Success", message: "You have successfully joined the community!") {
                                    // Notify the delegate that a community was joined
                                    self.delegate?.didJoinCommunity()
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func checkIfUserIsMember(communityId: String, userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("communities").document(communityId).collection("members")
            .document(userId).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error checking membership: \(error.localizedDescription)")
                    completion(false)
                } else {
                    // If the document exists, the user is already a member
                    completion(documentSnapshot?.exists ?? false)
                }
            }
    }
    
    // MARK: - Helper Methods
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Optional: Add validation or formatting for the community code
        if let text = textField.text {
            textField.text = text.uppercased() // Ensure the code is in uppercase
        }
    }
}

// MARK: - UITextFieldDelegate
extension joinCommunityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
}
