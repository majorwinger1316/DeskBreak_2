//
//  communityViewController.swift
//  DeskBreak_Test
//
//  Created by admin33 on 03/10/24.
//

import UIKit
import FirebaseFirestore
import CoreLocation
import Foundation
import MapKit

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

class communityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, MapViewControllerDelegate{
    
    func joinCommunityAlert(community: Community) {
        let alertController = UIAlertController(title: "Join Community", message: "Do you want to join the community \(community.communityName)?", preferredStyle: .alert)
        
        let joinAction = UIAlertAction(title: "Join", style: .default) { [weak self] _ in
            self?.joinCommunity(code: community.communityCode) // Assume `communityCode` is available in the `Community` model
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(joinAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var communityTable: UITableView!
    var userCommunities: [Community] = []
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    @IBAction func unwindToCommunity(segue : UIStoryboardSegue){
        fetchUserCommunities()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        communityTable.delegate = self
        communityTable.dataSource = self
        communityTable.register(UITableViewCell.self, forCellReuseIdentifier: "CommunityCell")
        communityTable.layer.cornerRadius = 12
        communityTable.layer.masksToBounds = true
        
        fetchUserCommunities()
        
        locationManager.delegate = self
    }
    
    func fetchUserCommunities() {
        let db = Firestore.firestore()
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""

        db.collection("communities")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching communities: \(error.localizedDescription)")
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    print("No communities found.")
                    return
                }
                
                var communityIds: [String] = []
                let group = DispatchGroup()
                
                // Iterate through communities to find the ones the user belongs to
                for document in querySnapshot.documents {
                    let communityId = document.documentID
                    group.enter()
                    
                    db.collection("communities").document(communityId)
                        .collection("members")
                        .document(userId)
                        .getDocument { memberSnapshot, error in
                            if let error = error {
                                print("Error checking member in community \(communityId): \(error.localizedDescription)")
                            } else if let memberSnapshot = memberSnapshot, memberSnapshot.exists {
                                // If the user is found in the "members" sub-collection, add the communityId
                                communityIds.append(communityId)
                            }
                            group.leave()
                        }
                }
                
                group.notify(queue: .main) {
                    // After checking all communities, fetch the details
                    self.fetchCommunityDetails(communityIds: communityIds) { communities in
                        self.userCommunities = communities
                        self.communityTable.reloadData() // Reload table with updated data
                    }
                }
            }
    }

    func fetchCommunityDetails(communityIds: [String], completion: @escaping ([Community]) -> Void) {
        let db = Firestore.firestore()
        var communities: [Community] = []

        let group = DispatchGroup()

        for communityId in communityIds {
            group.enter()
            
            db.collection("communities").document(communityId).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error fetching community details: \(error.localizedDescription)")
                } else if let document = documentSnapshot, document.exists {
                    if let community = Community(document: document) {
                        communities.append(community)
                    } else {
                        print("Failed to parse community data for \(communityId)")
                    }
                }

                group.leave()
            }
        }

        // Once all community details are fetched, pass them to the completion handler
        group.notify(queue: .main) {
            completion(communities)
        }
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCommunities.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showCommunityDetails", sender: userCommunities[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCommunityDetails",
           let destinationVC = segue.destination as? CommunityDetailsViewController,
           let selectedCommunity = sender as? Community {
            destinationVC.community = selectedCommunity
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell", for: indexPath)
        let community = userCommunities[indexPath.row]
        
        cell.textLabel?.text = community.communityName
        cell.textLabel?.textColor = .main
        cell.imageView?.image = UIImage(systemName: "person.3")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        cell.contentView.layer.masksToBounds = true
        cell.backgroundColor = .card
        
        let chevronImage = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImage.tintColor = .systemGray
        cell.accessoryView = chevronImage
        
        return cell
    }

    
    @IBAction func nearbyCommunitiesButtonPressed(_ sender: UIButton) {
    }
    
    func showNearbyCommunitiesAlert(community: Community) {
        let alertController = UIAlertController(title: "Nearby Community", message: "Do you want to join this community?", preferredStyle: .alert)
        
        let joinAction = UIAlertAction(title: "Join", style: .default) { _ in
            self.joinCommunity(code: community.communityCode) // Adjust if communityCode isn't directly available
        }
        
        alertController.addAction(joinAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addCommunityButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let segmentedControl = UISegmentedControl(items: ["Create", "Join"])
        segmentedControl.selectedSegmentIndex = 0
        alertController.view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 15),
            segmentedControl.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])

        alertController.addTextField { textField in
            textField.placeholder = "Enter community name"
            textField.clearButtonMode = .whileEditing
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.keyboardType = .default
        }

        let doneAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self = self, let textFieldInput = alertController.textFields?.first?.text, !textFieldInput.isEmpty else { return }

            if segmentedControl.selectedSegmentIndex == 0 {
                // Create Community
                let communityCode = String(Int.random(in: 1000...9999))
                self.createCommunity(name: textFieldInput, code: communityCode)
            } else {
                // Join Community
                if let communityCode = alertController.textFields?.first?.text {
                    self.joinCommunity(code: communityCode)
                }
            }
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(doneAction)
        alertController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        present(alertController, animated: true, completion: nil)

        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            // Update the placeholder text based on the selected segment
            if let alertController = presentedViewController as? UIAlertController,
               let textField = alertController.textFields?.first {
                if sender.selectedSegmentIndex == 0 {
                    textField.placeholder = "Enter community name"
                } else {
                    textField.placeholder = "Enter community code"
                }
            }
        }

    // MARK: - Create Community
    func createCommunity(name: String, code: String) {
        let db = Firestore.firestore()
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let communityId = UUID().uuidString

        guard let userLocation = userLocation else {
            showAlert(title: "Error", message: "Unable to fetch your location. Please enable location services.")
            return
        }

        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let geohash = geohashEncode(latitude: latitude, longitude: longitude)

        let communityData: [String: Any] = [
            "communityId": communityId,
            "communityName": name,
            "communityCode": code,
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
            } else {
                self.addMemberToCommunity(communityId: communityId, userId: userId) { membershipError in
                    if let membershipError = membershipError {
                        print("Error adding membership: \(membershipError.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to add you as a member.")
                    } else {
                        self.showAlert(title: "Community Created", message: "Community code is \(code). Share it with others.")
                        self.fetchUserCommunities()
                    }
                }
            }
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

    func joinCommunity(code: String) {
        let db = Firestore.firestore()
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""

        // Check if the user is already a member of any community with the provided code
        db.collection("communities")
            .whereField("communityCode", isEqualTo: code)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to check community: \(error.localizedDescription)")
                    return
                }

                guard let communityDocument = querySnapshot?.documents.first else {
                    self.showAlert(title: "Error", message: "Community with the code \(code) not found.")
                    return
                }

                let communityId = communityDocument.documentID

                // Now check if the user is already a member of the community
                self.checkIfUserIsMember(communityId: communityId, userId: userId) { isMember in
                    if isMember {
                        self.showAlert(title: "Already a Member", message: "You are already a member of this community.")
                    } else {
                        // Add the user as a member if they're not already
                        self.addMemberToCommunity(communityId: communityId, userId: userId) { membershipError in
                            if let membershipError = membershipError {
                                self.showAlert(title: "Error", message: "Failed to join community: \(membershipError.localizedDescription)")
                            } else {
                                self.showAlert(title: "Success", message: "You have successfully joined the community!")
                                self.fetchUserCommunities() // Refresh the list of user communities
                            }
                        }
                    }
                }
            }
    }

    func checkIfUserIsMember(communityId: String, userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()

        db.collection("communities").document(communityId).collection("members")
            .document(userId).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error checking membership: \(error.localizedDescription)")
                    completion(false)
                } else {
                    // If the document exists, the user is already a member
                    completion(documentSnapshot?.exists ?? false)
                }
            }
    }

    func addMembership(userId: String, communityId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let membershipId = UUID().uuidString

        let membershipData: [String: Any] = [
            "membershipId": membershipId,
            "userId": userId,
            "communityId": communityId,
            "joinedAt": Date()
        ]

        db.collection("communityMemberships").document(membershipId).setData(membershipData) { error in
            completion(error) // Call the completion handler with the error (if any)
        }
    }

    // MARK: - Alert Helper
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    }
