//
//  signUp1ViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/12/24.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class signUp1ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var userNameText: UITextField!
    
    @IBOutlet weak var userDateOfBirth: UITextField!
    
    var registrationData = UserRegistrationData()

    private var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        setupProfileImageView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // Hide keyboard when tapping outside
    }
    
    private func setupProfileImageView() {
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
        userProfileImageView.clipsToBounds = true
        userProfileImageView.contentMode = .scaleAspectFill
    }
    
    private func setupDatePicker() {
        userDateOfBirth.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDatePicker))
        toolbar.setItems([doneButton], animated: true)
        userDateOfBirth.inputAccessoryView = toolbar
    }
    
    @objc private func doneDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy" // Desired format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures month names are in English

        let selectedDate = datePicker.date
        userDateOfBirth.text = dateFormatter.string(from: selectedDate) // Display formatted string
        registrationData.dateOfBirth = selectedDate // Store as Date object (without time zone issues)
        
        userDateOfBirth.resignFirstResponder()
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        guard let username = userNameText.text, !username.isEmpty,
              let dateOfBirthString = userDateOfBirth.text, !dateOfBirthString.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }

        // Convert dateOfBirth to Date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        guard let dateOfBirth = dateFormatter.date(from: dateOfBirthString) else {
            showAlert(message: "Invalid date format.")
            return
        }

        // Assign user details
        registrationData.username = username
        registrationData.dateOfBirth = dateOfBirth

        // Check if a profile picture is selected
        if let profileImage = userProfileImageView.image {
            registrationData.profilePicture = profileImage // Pass the UIImage object
        } else {
            showAlert(message: "Please select a profile picture.")
            return
        }

        // Proceed to the next screen
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController3") as? signUp3ViewController {
            nextVC.registrationData = self.registrationData
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func uploadProfilePicture(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated")
            completion(nil)
            return
        }

        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            completion(nil)
            return
        }

        // Reference to Firebase Storage
        let storageRef = Storage.storage().reference().child("profile_pictures/\(user.uid).jpg")

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

    
    @IBAction func selectProfilePicButtonPressed(_ sender: Any){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            let circularImage = selectedImage.circularCropped()
            userProfileImageView.image = circularImage
            registrationData.profilePicture = circularImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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

extension UIImage {
    func circularCropped() -> UIImage {
        let minDimension = min(size.width, size.height)
        let squareSize = CGSize(width: minDimension, height: minDimension)
        let squareRect = CGRect(origin: CGPoint(x: (size.width - minDimension) / 2, y: (size.height - minDimension) / 2), size: squareSize)

        UIGraphicsBeginImageContextWithOptions(squareSize, false, scale)
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: squareSize))
        path.addClip()
        draw(in: CGRect(origin: CGPoint(x: -squareRect.origin.x, y: -squareRect.origin.y), size: size))
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return circularImage ?? self
    }
}
