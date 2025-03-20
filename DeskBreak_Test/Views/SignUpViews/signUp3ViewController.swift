//
//  signUp3ViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/12/24.
//

import FirebaseAuth
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseStorage

class signUp3ViewController: UIViewController {
    
    public var registrationData: UserRegistrationData!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fiveMinButton: UIButton!
    @IBOutlet weak var twelveMinButton: UIButton!
    @IBOutlet weak var twentyFiveMinButton: UIButton!
    
    var pickerView: UIPickerView!
    var pickerData: [Int] = Array(1...30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        setupButtons()
    }
    
    private func setupButtons() {
        let buttons = [fiveMinButton, twelveMinButton, twentyFiveMinButton]
        for button in buttons {
            button?.layer.cornerRadius = 10
            button?.layer.borderWidth = 1
            button?.layer.borderColor = UIColor.lightGray.cgColor
            button?.setTitleColor(.black, for: .normal)
            button?.backgroundColor = .clear
        }
        
        // Set 12 min as the default selected button
        twelveMinButton.layer.borderColor = UIColor.main.cgColor
        twelveMinButton.layer.borderWidth = 2
        twelveMinButton.setTitleColor(UIColor.main, for: .normal)
        
        // Set the default daily target value
        registrationData.dailyTarget = 12
    }
    
    @IBAction func dailyGoalSelected(_ sender: UIButton) {
        let buttons = [fiveMinButton, twelveMinButton, twentyFiveMinButton]
        
        for button in buttons {
            button?.backgroundColor = .clear
            button?.layer.borderColor = UIColor.lightGray.cgColor
            button?.setTitleColor(.black, for: .normal)
            button?.layer.borderWidth = 1
        }
        
        sender.layer.borderColor = UIColor.main.cgColor
        sender.layer.borderWidth = 2
        sender.setTitleColor(UIColor.main, for: .normal)

        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if sender == fiveMinButton {
            registrationData.dailyTarget = 5
        } else if sender == twelveMinButton {
            registrationData.dailyTarget = 12
        } else if sender == twentyFiveMinButton {
            registrationData.dailyTarget = 25
        }
    }
    
    @IBAction func RegisterButton(_ sender: UIButton) {
        guard registrationData.dailyTarget > 0 else {
            showAlert(message: "Please select a daily goal.")
            return
        }

        showLoadingIndicator()
        Auth.auth().createUser(withEmail: registrationData.email, password: registrationData.password) { authResult, error in
            if let error = error {
                self.hideLoadingIndicator()
                self.showAlert(message: "Registration failed: \(error.localizedDescription)")
                return
            }

            if let user = authResult?.user {
                if let profileImage = self.registrationData.profilePicture {
                    self.uploadProfilePicture(profileImage, userId: user.uid) { [weak self] imageURL in
                        guard let self = self else { return }
                        if let imageURL = imageURL {
                            self.registrationData.profilePictureURL = imageURL
                            self.saveUserData(userId: user.uid, profileImageUrl: imageURL)
                        } else {
                            self.hideLoadingIndicator()
                            self.showAlert(message: "Failed to upload profile picture.")
                        }
                    }
                } else {
                    self.saveUserData(userId: user.uid, profileImageUrl: "")
                }
            }
        }
    }

    private func saveUserData(userId: String, profileImageUrl: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        let userData: [String: Any] = [
            "userId": userId,
            "username": registrationData.username,
            "email": registrationData.email,
            "dailyTarget": registrationData.dailyTarget,
            "totalMinutes": 0,
            "totalPoints": 0,
            "dailyMinutes": 0,
            "dailyPoints": 0,
            "dateOfBirth": registrationData.dateOfBirth ?? Date(),
            "contactNumber": registrationData.contactNumber,
            "createdAt": Timestamp(date: Date()),
            "lastActivityDate": Timestamp(date: Date()),
            "profilePictureURL": profileImageUrl
        ]

        userRef.setData(userData) { error in
            if let error = error {
                self.hideLoadingIndicator()
                self.showAlert(message: "Failed to save user data: \(error.localizedDescription)")
            } else {
                // Automatically sign in the user after registration
                self.signInUser(email: self.registrationData.email, password: self.registrationData.password)
            }
        }
    }

    private func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.hideLoadingIndicator()
            if let error = error {
                self.showAlert(message: "Automatic login failed: \(error.localizedDescription)")
                return
            }

            // Fetch user data and navigate to the main screen
            if let userId = authResult?.user.uid {
                self.fetchUserData(userId: userId)
            }
        }
    }

    private func fetchUserData(userId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        userRef.getDocument { document, error in
            if let error = error {
                self.showAlert(message: "Failed to fetch user data: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let userData = document.data()
                self.saveUserSession(userData: userData)
                self.navigateToTabBarController()
            } else {
                self.showAlert(message: "User data not found.")
            }
        }
    }

    private func saveUserSession(userData: [String: Any]?) {
        let defaults = UserDefaults.standard

        defaults.set(userData?["userId"] as? String, forKey: "userId")
        defaults.set(userData?["username"] as? String, forKey: "userName")
        defaults.set(userData?["email"] as? String, forKey: "userEmail")
        defaults.set(userData?["dailyTarget"] as? Int, forKey: "dailyTarget")
        defaults.set(userData?["totalMinutes"] as? Int, forKey: "totalMinutes")
        defaults.set(userData?["totalPoints"] as? Int, forKey: "totalPoints")
        defaults.set(userData?["dateOfBirth"] as? Date, forKey: "dateOfBirth")
        defaults.set(userData?["contactNumber"] as? String, forKey: "contactNumber")
        defaults.set(userData?["profilePictureURL"] as? String, forKey: "profilePictureURL")
        defaults.set(true, forKey: "isLoggedIn")
    }

    private func navigateToTabBarController() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                
                // Set the selected index to 1 (second tab)
                tabBarController.selectedIndex = 2
                
                // Add a transition animation
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = tabBarController
                }, completion: nil)
            }
        }
    }

    private func uploadProfilePicture(_ image: UIImage, userId: String, completion: @escaping (String?) -> Void) {
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            completion(nil)
            return
        }

        // Reference to Firebase Storage with user_id
        let storageRef = Storage.storage().reference().child("profile_pictures/\(userId).jpg")

        // Upload the image
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Get download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get image URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                // Return the image URL
                completion(url?.absoluteString)
            }
        }
    }

    private func storeUserDataInFirestore(userRef: DocumentReference, userData: [String: Any]) {
        userRef.setData(userData) { error in
            if let error = error {
                self.showAlert(message: "Failed to save user data: \(error.localizedDescription)")
            } else {
                self.navigateToLoginScreen()
            }
        }
    }
    
    public func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    public func navigateToLoginScreen() {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? signInViewController {
            self.navigationController?.setViewControllers([loginVC], animated: true)
        }
    }

    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", regex)
        return emailTest.evaluate(with: email)
    }
    
    private func isValidURL(_ urlString: String) -> Bool {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }
}

extension UIImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage {
        let size = self.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
