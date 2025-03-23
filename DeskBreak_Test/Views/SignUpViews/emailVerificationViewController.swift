//
//  emailVerificationViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 23/03/25.
//

import UIKit
import FirebaseAuth

class emailVerificationViewController: UIViewController {
    
    @IBOutlet weak var otpStackView: UIStackView!
    @IBOutlet weak var resendOtpButton: UIButton!
    
    var email: String! // Email passed from the previous view controller
    var otpTextFields: [UITextField] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOTPStackView()
        sendOTP()
    }

    // MARK: - Setup OTP Stack View
    private func setupOTPStackView() {
        for i in 0..<6 {
            let textField = UITextField()
            textField.delegate = self
            textField.textAlignment = .center
            textField.font = UIFont.systemFont(ofSize: 24)
            textField.keyboardType = .numberPad
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textField.layer.cornerRadius = 8
            textField.textColor = .main
            textField.widthAnchor.constraint(equalToConstant: 40).isActive = true
            textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
            otpStackView.addArrangedSubview(textField)
            otpStackView.distribution = .fillEqually
            otpTextFields.append(textField)
        }
    }

    // MARK: - Send OTP
    private func sendOTP() {
        guard let email = email else { return }

        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://yourapp.page.link")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)

        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(message: "Failed to send OTP: \(error.localizedDescription)")
                return
            }
            self.showAlert(message: "OTP sent to your email.")
        }
    }

    private func verifyOTP() {
        let otp = otpTextFields.map { $0.text ?? "" }.joined()
        showAlert(message: "OTP verified successfully!")
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController1") as? signUp1ViewController {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        verifyOTP()
    }
    
    @IBAction func resentOtpButtonPressed(_ sender: UIButton) {
        sendOTP()
    }

    // MARK: - Show Alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension emailVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Move to the next text field after entering a digit
        if string.count == 1 {
            if let index = otpTextFields.firstIndex(of: textField), index < otpTextFields.count - 1 {
                otpTextFields[index + 1].becomeFirstResponder()
            } else if let index = otpTextFields.firstIndex(of: textField), index == (otpTextFields.count - 1) {

                textField.resignFirstResponder()
                verifyOTP() // Auto-verify when the last digit is entered
            }
            return true
        } else if string.isEmpty { // Handle backspace
            if let index = otpTextFields.firstIndex(of: textField), index > 0 {
                otpTextFields[index - 1].becomeFirstResponder()
            }
            return true
        }
        return false
    }
}
