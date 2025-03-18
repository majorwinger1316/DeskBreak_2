//
//  signUp2ViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/12/24.
//

import UIKit

class signUp2ViewController: UIViewController {
    
    @IBOutlet weak var userEmailText: UITextField!
    
    @IBOutlet weak var userContactText: UITextField!
    
    @IBOutlet weak var userPasswordText: UITextField!
    
    @IBOutlet weak var userConfirmPasswordText: UITextField!
    
    var registrationData: UserRegistrationData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDoneButton(for: userEmailText)
        setupDoneButton(for: userContactText)
        setupDoneButton(for: userPasswordText)
        setupDoneButton(for: userConfirmPasswordText)
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

        registrationData.email = email
        registrationData.contactNumber = contactNumber
        registrationData.password = password

        if let nextVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController1") as? signUp1ViewController {
            nextVC.registrationData = registrationData
            navigationController?.pushViewController(nextVC, animated: true)
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
