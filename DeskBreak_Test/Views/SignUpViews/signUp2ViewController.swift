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
        guard let email = userEmailText.text, !email.isEmpty,
              let contactNumber = userContactText.text, !contactNumber.isEmpty,
              let password = userPasswordText.text, !password.isEmpty,
              let confirmPassword = userConfirmPasswordText.text, !confirmPassword.isEmpty,
              password == confirmPassword else {
            showAlert(message: "Please fill in all fields and make sure passwords match.")
            return
        }
        registrationData.email = email
        registrationData.contactNumber = contactNumber
        registrationData.password = password

        if let nextVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController3") as? signUp3ViewController {
            nextVC.registrationData = registrationData
            navigationController?.pushViewController(nextVC, animated: true)
        }
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
