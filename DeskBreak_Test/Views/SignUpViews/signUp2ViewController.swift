//
//  signUp2ViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class signUp2ViewController: UIViewController {
    
    @IBOutlet weak var userEmailText: UITextField!
    
    @IBOutlet weak var userContactText: UITextField!
    
    @IBOutlet weak var userPasswordText: UITextField!
    
    @IBOutlet weak var userConfirmPasswordText: UITextField!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var registrationData: UserRegistrationData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // Hide keyboard when tapping outside
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        if registrationData == nil {
            registrationData = UserRegistrationData()
        }

        guard let email = userEmailText.text, !email.isEmpty,
              let contactNumber = userContactText.text, !contactNumber.isEmpty,
              let password = userPasswordText.text, !password.isEmpty,
              let confirmPassword = userConfirmPasswordText.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }

        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address.")
            return
        }

        if password != confirmPassword {
            showAlert(message: "Passwords do not match.")
            return
        }

        // Check if email exists before proceeding
        checkIfEmailExists(email) { [weak self] exists in
            guard let self = self else { return }

            if exists {
                self.showAlert(message: "This email is already registered. Please use a different email.")
            } else {
                self.registrationData.email = email
                self.registrationData.contactNumber = contactNumber
                self.registrationData.password = password

                if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController1") as? signUp1ViewController {
                    nextVC.registrationData = self.registrationData
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }
    }
    
    private func checkIfEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")

        // Start loading indicator
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }

        usersRef.whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            // Stop loading indicator
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }

            if let error = error {
                print("Error checking email existence: \(error.localizedDescription)")
                completion(false) // Assume email doesn’t exist if there's an error
            } else {
                completion(!querySnapshot!.documents.isEmpty) // If documents exist, email exists
            }
        }
    }

    // Function to validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func setupDoneButton(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)

        textField.inputAccessoryView = toolbar
    }

    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
}
