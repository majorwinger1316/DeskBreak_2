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

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        setupDoneButton(for: emailTextField)
        setupDoneButton(for: passwordTextField)
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

        // Start Activity Indicator
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

            self.fetchUserData(userId: userId)
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue){
    }
    
    private func fetchUserData(userId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                self.activityIndicator.stopAnimating() // Stop activity indicator
                self.showAlert(message: "Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let document = documentSnapshot, document.exists, let userData = document.data() else {
                self.activityIndicator.stopAnimating() // Stop activity indicator
                self.showAlert(message: "User data not found.")
                return
            }
            
            // Parse user data and save to UserDefaults
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
                self.downloadProfileImage(from: profilePictureURL)
            }

            // Navigate to the TabBarController with animation
            self.activityIndicator.stopAnimating() // Stop activity indicator
            self.animateToTabBarController()
        }
    }
    
    private func animateToTabBarController() {
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
            navigationController.modalPresentationStyle = .fullScreen // Optional: If you want full-screen presentation
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    private func downloadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading profile picture: \(error.localizedDescription)")
                return
            }

            if let data = data {
                // Convert image data to Base64 and store in UserDefaults
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
        view.endEditing(true) // Dismiss the keyboard
    }
}

// MARK: - ProfileUpdateDelegate Implementation
extension signInViewController: ProfileUpdateDelegate {
    func updateProfileImage(_ image: UIImage) {
        print("Profile image updated successfully.")

        // Optionally, store the image in UserDefaults or update UI here
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            UserDefaults.standard.set(imageData, forKey: "userProfilePic")
        }
    }
}
