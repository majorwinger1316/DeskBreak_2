//
//  signInViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 06/11/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class signInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var eyeIconClick = false
    let imageIcon = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        setupDoneButton(for: emailTextField)
        setupDoneButton(for: passwordTextField)
        
        imageIcon.image = UIImage(systemName: "eye.slash.circle.fill")
        
        let contentView = UIView()
        contentView.addSubview(imageIcon)
        
        contentView.frame = CGRect(x: 0, y: 0, width: Int(UIImage(systemName: "eye.slash.circle.fill")!.size.width), height: Int(UIImage(systemName: "eye.slash.circle.fill")!.size.height))
        imageIcon.frame = CGRect(x: -10, y: 0, width: Int(UIImage(systemName: "eye.slash.circle.fill")!.size.width), height: Int(UIImage(systemName: "eye.slash.circle.fill")!.size.height))
        
        passwordTextField.rightView = contentView
        passwordTextField.rightViewMode = .always
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPassword(tapGestureRecognizer:)))
        imageIcon.isUserInteractionEnabled = true
        imageIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func showPassword(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        if eyeIconClick {
            eyeIconClick = false
            tappedImage.image = UIImage(systemName: "eye.circle.fill")
            passwordTextField.isSecureTextEntry = false
        }
        else {
            eyeIconClick = true
            tappedImage.image = UIImage(systemName: "eye.slash.circle.fill")
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    private func saveUserSession(user: User) {
        let defaults = UserDefaults.standard

        defaults.set(user.userId, forKey: "userId")
        defaults.set(user.username, forKey: "userName")
        defaults.set(user.email, forKey: "userEmail")
        defaults.set(user.passwordHash, forKey: "passwordHash")
        defaults.set(user.profilePicture, forKey: "profilePicture")
        defaults.set(user.dailyTarget, forKey: "dailyTarget")
        defaults.set(user.totalMinutes, forKey: "totalMinutes")
        defaults.set(user.totalPoints, forKey: "totalPoints")
        defaults.set(user.createdAt.timeIntervalSince1970, forKey: "createdAt")
        defaults.set(user.dateOfBirth.timeIntervalSince1970, forKey: "dateOfBirth")
        defaults.set(user.contactNumber, forKey: "contactNumber")
        
        defaults.set(true, forKey: "isLoggedIn")
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter email and password.")
            return
        }
        activityIndicator.startAnimating()
        
        // Firebase Authentication Sign-In
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
            }
            
            // Retrieve userId and fetch user data from Firestore
            guard let userId = authResult?.user.uid else {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Error retrieving user information.")
                return
            }

            fetchUserData(userId: userId, viewController: self)
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue){
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
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
    
    public func animateToTabBarController() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = tabBarController
                }, completion: { _ in
                    window.makeKeyAndVisible()
                })
            }
        }
    }
    
    @IBAction func signUpViewButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController1") as? signUp1ViewController {
            let navigationController = UINavigationController(rootViewController: signUpVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    public func downloadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading profile picture: \(error.localizedDescription)")
                return
            }

            if let data = data {
                let base64String = data.base64EncodedString()
                UserDefaults.standard.set(base64String, forKey: "userProfilePic")
            }

            DispatchQueue.main.async {
                self.navigateToTabBarController()
            }
        }.resume()
    }

    
    private func navigateToTabBarController() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController

                if let homeVC = tabBarController.viewControllers?.first(where: { $0 is homeViewController }) as? homeViewController {
                    // Pass the user data to the home view controller
                    homeVC.profileUpdateDelegate = self  // Set the delegate
                    
                    // Retrieve user data from UserDefaults
                    let defaults = UserDefaults.standard
                    let totalMinutes = defaults.float(forKey: "totalMinutes")
                    let dailyTarget = defaults.float(forKey: "dailyTarget")
                    
                    // Pass the data to the HomeCard via homeVC
                    homeVC.updateHomeCard(totalMinutes: totalMinutes, dailyTarget: dailyTarget)
                }

                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }
        }
    }
    
    public func showAlert(message: String) {
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
        view.endEditing(true) // Dismiss the keyboard
    }
}

// MARK: - ProfileUpdateDelegate Implementation
extension signInViewController: ProfileUpdateDelegate {
    func updateProfileImage(_ image: UIImage) {
        print("Profile image updated successfully.")
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            UserDefaults.standard.set(imageData, forKey: "userProfilePic")
        }
    }
}
