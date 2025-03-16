//
//  forgotPasswordViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 15/03/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class forgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailForgotTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func sendEmailButtonPressed(_ sender: UIButton) {
        guard let email = emailForgotTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email to reset the password.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showAlert(message: "Error: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "A password reset link has been sent to your email.")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
