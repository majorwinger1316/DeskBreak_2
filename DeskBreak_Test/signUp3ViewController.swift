//
//  signUp3ViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class signUp3ViewController: UIViewController {
    
    @IBOutlet weak var dailyTargetButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var registrationData: UserRegistrationData!
    var pickerView: UIPickerView!
    var pickerData: [Int] = Array(1...30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
    }
    
    @IBAction func dailyTargetButtonTapped(_ sender: UIButton) {
        presentPickerView()
    }
    
    @IBAction func RegisterButton(_ sender: UIButton) {
        guard let dailyTargetText = dailyTargetButton.title(for: .normal),
              let dailyTarget = Int16(dailyTargetText) else {
            showAlert(message: "Please select a daily target.")
            return
        }

        registrationData.dailyTarget = dailyTarget
        showLoadingIndicator()
        
        // Create a user with Firebase Authentication
        Auth.auth().createUser(withEmail: registrationData.email, password: registrationData.password) { authResult, error in
            self.hideLoadingIndicator()

            if let error = error {
                self.showAlert(message: "Registration failed: \(error.localizedDescription)")
                return
            }

            if let userId = authResult?.user.uid {
                // Upload profile picture and save user data to Firestore
                self.uploadProfileImage(userId: userId)
            }
        }
    }
    
    private func uploadProfileImage(userId: String) {
        guard let profileImage = registrationData.profilePicture else {
            self.showAlert(message: "No profile picture found.")
            return
        }

        // Compress the image
        let maxDimension: CGFloat = 300 // Resize to a maximum of 300x300 pixels
        let resizedImage = profileImage.resized(toMaxDimension: maxDimension)
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            self.showAlert(message: "Failed to compress image.")
            return
        }

        // Generate a unique file name using UUID
        let uniqueFileName = UUID().uuidString + ".jpg"
        let storagePath = "profile_images/\(uniqueFileName)"
        print("Uploading to path: \(storagePath)")
        
        // Create a reference to Firebase Storage
        let storageRef = Storage.storage().reference().child(storagePath)

        // Upload the compressed image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                self.showAlert(message: "Failed to upload profile image: \(error.localizedDescription)")
                return
            }

            // Image upload succeeded, get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    self.showAlert(message: "Failed to get image URL: \(error.localizedDescription)")
                    return
                }

                if let imageURL = url?.absoluteString {
                    print("Profile image uploaded successfully. URL: \(imageURL)")
                    self.saveUserData(userId: userId, profileImageUrl: imageURL)
                }
            }
        }
    }
    
    private func saveUserData(userId: String, profileImageUrl: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        var userData: [String: Any] = [
            "userId": userId,
            "username": registrationData.username,
            "email": registrationData.email,
            "dailyTarget": registrationData.dailyTarget,
            "totalMinutes": 0,
            "totalPoints": 0,
            "dailyMinutes": 0,
            "dailyPoints": 0,
            "dateOfBirth": registrationData.dateOfBirth,
            "contactNumber": registrationData.contactNumber,
            "createdAt": Timestamp(date: Date()),
            "lastActivityDate": Timestamp(date: Date()),
            "profilePictureURL": profileImageUrl
        ]
        
        // Save user data to Firestore
        userRef.setData(userData) { error in
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

    private func navigateToLoginScreen() {
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

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        // Simple email validation regex
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", regex)
        return emailTest.evaluate(with: email)
    }
    
    private func isValidURL(_ urlString: String) -> Bool {
        // Check if the URL is valid
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }
}

extension signUp3ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func presentPickerView() {
        let pickerViewController = UIViewController()
        pickerViewController.modalPresentationStyle = .pageSheet
        pickerViewController.sheetPresentationController?.detents = [.medium()]
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        pickerView.backgroundColor = UIColor.card

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePickerView))
        toolbar.setItems([doneButton], animated: true)

        pickerViewController.view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: pickerViewController.view.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: pickerViewController.view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: pickerViewController.view.trailingAnchor)
        ])
        
        pickerViewController.view.addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: pickerViewController.view.centerXAnchor),
            pickerView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            pickerView.widthAnchor.constraint(equalTo: pickerViewController.view.widthAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        present(pickerViewController, animated: true, completion: nil)
    }
    
    @objc func donePickerView() {
        let selectedValue = pickerData[pickerView.selectedRow(inComponent: 0)]
        dailyTargetButton.setTitle("\(selectedValue)", for: .normal)
        dismiss(animated: true, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row]) minutes"
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
