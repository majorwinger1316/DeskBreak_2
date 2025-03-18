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
    }
    
    private func setupButtons() {
        let buttons = [fiveMinButton, twelveMinButton, twentyFiveMinButton]
        for button in buttons {
            button?.layer.cornerRadius = 10
            button?.layer.borderWidth = 2
            button?.setTitleColor(.black, for: .normal)
        }
    }
    
    @IBAction func dailyGoalSelected(_ sender: UIButton) {
        let buttons = [fiveMinButton, twelveMinButton, twentyFiveMinButton]
        for button in buttons {
            button?.backgroundColor = .black.withAlphaComponent(0.8)
            button?.layer.borderColor = UIColor.main.cgColor
        }
        
        sender.backgroundColor = UIColor.systemBlue
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        sender.setTitleColor(.white, for: .normal)
        
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
            self.hideLoadingIndicator()
            if let error = error {
                self.showAlert(message: "Failed to save user data: \(error.localizedDescription)")
            } else {
                self.navigateToLoginScreen()
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
