//
//  createCommunityViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 19/03/25.
//

import UIKit
import FirebaseFirestore
import CoreLocation
import Foundation
import FirebaseStorage
import MapKit
import CoreLocation

struct Geohash {
    static let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")
    static let bits = [16, 8, 4, 2, 1]
    
    static func encode(latitude: Double, longitude: Double, precision: Int = 9) -> String {
        var isEven = true
        var bit = 0
        var currentChar = 0
        var geohash = ""
        
        var minLat = -90.0
        var maxLat = 90.0
        var minLon = -180.0
        var maxLon = 180.0
        
        while geohash.count < precision {
            if isEven {
                let mid = (minLon + maxLon) / 2
                if longitude > mid {
                    currentChar |= bits[bit]
                    minLon = mid
                } else {
                    maxLon = mid
                }
            } else {
                let mid = (minLat + maxLat) / 2
                if latitude > mid {
                    currentChar |= bits[bit]
                    minLat = mid
                } else {
                    maxLat = mid
                }
            }
            
            isEven.toggle()
            
            if bit < 4 {
                bit += 1
            } else {
                geohash.append(base32[currentChar])
                bit = 0
                currentChar = 0
            }
        }
        return geohash
    }
    
    // Generate a list of geohashes within a specific radius
    static func surroundingGeohashes(geohash: String, radiusInMeters: Double) -> [String] {
        // Example: In a real implementation, you would calculate neighboring geohashes based on the radius
        return [geohash] // For simplicity, we're just returning the geohash itself.
    }

    // Calculate bounds for querying
    static func queryBounds(latitude: Double, longitude: Double, radiusInMeters: Double) -> [String] {
        let geohash = encode(latitude: latitude, longitude: longitude, precision: 5) // Precision of 5 gives a good balance between region size and query efficiency
        let surrounding = surroundingGeohashes(geohash: geohash, radiusInMeters: radiusInMeters)
        return surrounding
    }
}

class createCommunityViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextViewDelegate {
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var userCommunities: [Community] = []
    var placeName: String?
    var lastGeocodingTimestamp: Date?
    var lastGeocodingLocation: CLLocation?
    var lastGeocodingPlaceName: String?
    private let placeholderText = "(Max 10 words)"
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var communityImage: UIImageView!
    @IBOutlet weak var communityTitle: UITextField!
    @IBOutlet weak var communityDescription: UITextView!
    @IBOutlet weak var communityImageSelector: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        communityImage.layer.cornerRadius = communityImage.frame.size.width / 2
        communityImage.clipsToBounds = true
        
        communityDescription.layer.cornerRadius = 8
        communityDescription.delegate = self
        communityDescription.text = placeholderText
        communityDescription.textColor = .lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allows table view selection while the keyboard is dismissed
        view.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = false // Disabled initially

        // Observe keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    @IBOutlet weak var wordCountLabel: UILabel!

    func textViewDidChange(_ textView: UITextView) {
        let words = textView.text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        wordCountLabel.text = "\(words.count)/10 words"
    }
    
    @objc func keyboardWillShow() {
        view.gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer })?.isEnabled = true
    }

    // Disable tap gesture when the keyboard disappears
    @objc func keyboardWillHide() {
        view.gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer })?.isEnabled = false
    }

    @objc func dismissKeyboard() {
        view.endEditing(true) // Hide keyboard
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .text
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
    
    var selectedImage: UIImage?

    @IBAction func communityImageSelectorTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image

            if let croppedImage = cropImageToCircle(image) {
                communityImage.image = croppedImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func cropImageToCircle(_ image: UIImage) -> UIImage? {
        let imageSize = image.size
        let diameter = min(imageSize.width, imageSize.height)
        let size = CGSize(width: diameter, height: diameter)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Create a circular clipping path
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
        path.addClip()

        // Draw the image within the circular path
        image.draw(in: CGRect(
            x: -(imageSize.width - diameter) / 2,
            y: -(imageSize.height - diameter) / 2,
            width: imageSize.width,
            height: imageSize.height
        ))

        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return croppedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        // Crop the image to a circle
        guard let croppedImage = cropImageToCircle(image) else {
            completion(nil)
            return
        }

        // Convert the cropped image to data
        guard let imageData = croppedImage.jpegData(compressionQuality: 0.75) else {
            completion(nil)
            return
        }

        // Upload the cropped image to Firebase Storage
        let storageRef = Storage.storage().reference().child("communityImages/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }
    
    func generateRandom4DigitCode() -> String {
        return String(format: "%04d", Int.random(in: 0..<10000))
    }
    
    @IBAction func createCommunityTapped(_ sender: UIBarButtonItem) {
        // Validate title
        guard let name = communityTitle.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a title for the community.")
            return
        }

        // Validate photo
        guard selectedImage != nil else {
            showAlert(title: "Error", message: "Please select a photo for the community.")
            return
        }

        // Validate description
        guard let description = communityDescription.text, !description.isEmpty, description != placeholderText else {
            showAlert(title: "Error", message: "Please enter a description for the community.")
            return
        }

        // Validate word count
        let words = description.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        if words.count > 10 {
            showAlert(title: "Error", message: "Description must be 10 words or fewer.")
            return
        }

        // Ensure place name is available
        guard let placeName = placeName else {
            showAlert(title: "Error", message: "Unable to fetch your location. Please try again.")
            return
        }

        // Start the activity indicator
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false // Disable user interaction

        // Generate a random 4-digit code
        let code = generateRandom4DigitCode()
        createCommunity(name: name, code: code, description: description, placeName: placeName)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          if let location = locations.last {
              userLocation = location
              fetchPlaceNameUsingMapKit(for: location)
          }
      }

      func fetchPlaceNameUsingMapKit(for location: CLLocation) {
          // Throttle requests: Only allow one request every 2 seconds
          if let lastTimestamp = lastGeocodingTimestamp, Date().timeIntervalSince(lastTimestamp) < 2 {
              print("Throttling reverse geocoding request")
              return
          }

          // Check if the location has changed significantly
          if let lastLocation = lastGeocodingLocation, location.distance(from: lastLocation) < 100 {
              // Reuse the cached place name if the location hasn't changed significantly
              self.placeName = lastGeocodingPlaceName ?? "Unknown Location"
              return
          }

          lastGeocodingTimestamp = Date()

          let geocoder = CLGeocoder()
          geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
              guard let self = self else { return }

              if let error = error {
                  print("Error reverse geocoding location: \(error.localizedDescription)")
                  self.placeName = "Unknown Location"

                  // Retry after a delay if the error is due to throttling
                  if (error as NSError).code == -3 {
                      DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                          self.fetchPlaceNameUsingMapKit(for: location)
                      }
                  }
                  return
              }

              if let placemark = placemarks?.first {
                  // Construct the place name from the placemark
                  self.placeName = self.formatPlaceName(from: placemark)
                  self.lastGeocodingPlaceName = self.placeName
                  self.lastGeocodingLocation = location
              } else {
                  self.placeName = "Unknown Location"
              }
          }
      }

    func formatPlaceName(from placemark: CLPlacemark) -> String {
        var placeName = ""

        // Add city or locality
        if let city = placemark.locality {
            placeName += city
        }

        // Add administrative area (e.g., state)
        if let state = placemark.administrativeArea {
            if !placeName.isEmpty {
                placeName += ", "
            }
            placeName += state
        }

        // Add country
        if let country = placemark.country {
            if !placeName.isEmpty {
                placeName += ", "
            }
            placeName += country
        }

        return placeName.isEmpty ? "Unknown Location" : placeName
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

        func createCommunity(name: String, code: String, description: String, placeName: String) {
            guard let userLocation = userLocation else {
                showAlert(title: "Error", message: "Unable to fetch your location. Please enable location services.")
                activityIndicator.stopAnimating() // Stop the activity indicator
                view.isUserInteractionEnabled = true // Re-enable user interaction
                return
            }

            guard let selectedImage = selectedImage else {
                showAlert(title: "Error", message: "Please select an image for the community.")
                activityIndicator.stopAnimating() // Stop the activity indicator
                view.isUserInteractionEnabled = true // Re-enable user interaction
                return
            }

            uploadImage(selectedImage) { imageUrl in
                guard let imageUrl = imageUrl else {
                    self.showAlert(title: "Error", message: "Failed to upload community image.")
                    self.activityIndicator.stopAnimating() // Stop the activity indicator
                    self.view.isUserInteractionEnabled = true // Re-enable user interaction
                    return
                }

                let db = Firestore.firestore()
                let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
                let communityId = UUID().uuidString

                let latitude = userLocation.coordinate.latitude
                let longitude = userLocation.coordinate.longitude
                let geohash = Geohash.encode(latitude: latitude, longitude: longitude)

                let communityData: [String: Any] = [
                    "communityId": communityId,
                    "communityName": name,
                    "communityCode": code,
                    "communityDescription": description,
                    "placeName": placeName,
                    "communityImageUrl": imageUrl,
                    "createdBy": userId,
                    "createdAt": Date(),
                    "latitude": latitude,
                    "longitude": longitude,
                    "geohash": geohash
                ]

                db.collection("communities").document(communityId).setData(communityData) { error in
                    if let error = error {
                        print("Error creating community: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to create community.")
                        self.activityIndicator.stopAnimating() // Stop the activity indicator
                        self.view.isUserInteractionEnabled = true // Re-enable user interaction
                    } else {
                        self.addMemberToCommunity(communityId: communityId, userId: userId) { membershipError in
                            if let membershipError = membershipError {
                                print("Error adding membership: \(membershipError.localizedDescription)")
                                self.showAlert(title: "Error", message: "Failed to add you as a member.")
                                self.activityIndicator.stopAnimating() // Stop the activity indicator
                                self.view.isUserInteractionEnabled = true // Re-enable user interaction
                            } else {
                                // Stop the activity indicator and re-enable user interaction
                                self.activityIndicator.stopAnimating()
                                self.view.isUserInteractionEnabled = true

                                // Dismiss the view controller
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the current text and the new text
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // Split the text into words
        let words = newText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

        // Allow the change if the word count is 10 or fewer
        return words.count <= 10
    }
    
    func addMemberToCommunity(communityId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        // Create the membership document in the community's "members" sub-collection
        let memberData: [String: Any] = [
            "userId": userId,
            "joinedAt": Date()
        ]

        db.collection("communities").document(communityId).collection("members").document(userId).setData(memberData) { error in
            completion(error) // Call the completion handler with the error (if any)
        }
    }
    
    func geohashEncode(latitude: Double, longitude: Double, precision: Int = 9) -> String {
        let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")
        var hash = ""
        var minLat = -90.0, maxLat = 90.0
        var minLon = -180.0, maxLon = 180.0
        var isEven = true
        var bit = 0
        var currentChar = 0

        while hash.count < precision {
            if isEven {
                let mid = (minLon + maxLon) / 2
                if longitude > mid {
                    currentChar |= (1 << (4 - bit))
                    minLon = mid
                } else {
                    maxLon = mid
                }
            } else {
                let mid = (minLat + maxLat) / 2
                if latitude > mid {
                    currentChar |= (1 << (4 - bit))
                    minLat = mid
                } else {
                    maxLat = mid
                }
            }

            isEven.toggle()
            if bit < 4 {
                bit += 1
            } else {
                hash.append(base32[currentChar])
                bit = 0
                currentChar = 0
            }
        }
        return hash
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
