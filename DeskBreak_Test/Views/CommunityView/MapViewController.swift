//
//  MapViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 11/01/25.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

protocol MapViewControllerDelegate: AnyObject {
    func joinCommunityAlert(community: Community)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var userLocation: CLLocation!
    var communities: [Community] = []
    var filteredCommunities: [Community] = []
    
    weak var delegate: MapViewControllerDelegate?
    
    private var modalBackgroundView: UIView!
    
    // Constants for table view
    private let cellHeight: CGFloat = 44.0
    private let maxVisibleCells: Int = 5
    
    private var searchResultsTableView: UITableView!
    private var isShowingSearchResults = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchCommunityBar: UISearchBar!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true // This shows the blue dot for the user's current location
        
        // Setup search bar
        searchCommunityBar.delegate = self
        searchCommunityBar.placeholder = "Search for a community"
        
        // Setup modal background
        setupModalBackground()
        
        // Setup search results table view
        setupSearchResultsTableView()
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // Set an acceptable accuracy for location
        locationManager.requestWhenInUseAuthorization() // Ask for location permission
        locationManager.startUpdatingLocation() // Start updating the location
        
        fetchCommunities()
        
        // Add tap gesture to dismiss keyboard and search results when tapping on map
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSearchResults))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    private func setupModalBackground() {
        modalBackgroundView = UIView()
        modalBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        modalBackgroundView.alpha = 0
        modalBackgroundView.isHidden = true
        
        view.addSubview(modalBackgroundView)
        
        modalBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modalBackgroundView.topAnchor.constraint(equalTo: searchCommunityBar.bottomAnchor),
            modalBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add tap gesture to dismiss search when tapping on modal background
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSearchResults))
        modalBackgroundView.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchResultsTableView() {
        searchResultsTableView = UITableView()
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommunityCell")
        searchResultsTableView.layer.borderColor = UIColor.lightGray.cgColor
        searchResultsTableView.layer.borderWidth = 1
        searchResultsTableView.layer.cornerRadius = 8
        searchResultsTableView.isHidden = true
        searchResultsTableView.backgroundColor = .systemBackground
        searchResultsTableView.separatorStyle = .singleLine
        searchResultsTableView.rowHeight = cellHeight
        
        // Add table view above the modal but below other UI elements
        view.addSubview(searchResultsTableView)
        
        // Set constraints for the table view (below search bar)
        searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchResultsTableView.topAnchor.constraint(equalTo: searchCommunityBar.bottomAnchor, constant: 4),
            searchResultsTableView.leadingAnchor.constraint(equalTo: searchCommunityBar.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: searchCommunityBar.trailingAnchor)
            // Height constraint will be set dynamically
        ])
    }
    
    @objc func dismissSearchResults() {
        searchCommunityBar.resignFirstResponder()
        hideSearchResults()
    }
    
    // MARK: - Search Bar Delegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss keyboard
        
        if let selectedCommunity = filteredCommunities.first {
            focusOnCommunity(selectedCommunity)
        }
        
        hideSearchResults()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCommunities = []
            hideSearchResults()
            displayNearbyCommunitiesOnMap()
        } else {
            // Filter communities based on search text
            filteredCommunities = communities.filter {
                $0.communityName.lowercased().contains(searchText.lowercased())
            }
            
            // Update and show the search results table
            searchResultsTableView.reloadData()
            updateTableViewHeight()
            showSearchResults()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !filteredCommunities.isEmpty {
            updateTableViewHeight()
            showSearchResults()
        }
    }
    
    // MARK: - Table View Data Source and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCommunities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell", for: indexPath)
        let community = filteredCommunities[indexPath.row]
        
        // Configure the cell
        cell.textLabel?.text = community.communityName
        
        // Set background color to "modalComponents" style (using system background for modal-like effect)
        cell.backgroundColor = .secondarySystemBackground
        
        // Add selection style
        cell.selectionStyle = .default
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCommunity = filteredCommunities[indexPath.row]
        
        // Focus map on selected community
        focusOnCommunity(selectedCommunity)
        
        // Hide search results and keyboard
        searchCommunityBar.text = selectedCommunity.communityName
        searchCommunityBar.resignFirstResponder()
        hideSearchResults()
    }
    
    // MARK: - Helper Methods
    
    private func updateTableViewHeight() {
        // Remove existing height constraint if any
        searchResultsTableView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                searchResultsTableView.removeConstraint(constraint)
            }
        }
        
        // Calculate new height based on number of rows
        let numberOfRows = min(filteredCommunities.count, maxVisibleCells)
        let calculatedHeight = CGFloat(numberOfRows) * cellHeight
        
        // Set dynamic height constraint
        let heightConstraint = searchResultsTableView.heightAnchor.constraint(equalToConstant: calculatedHeight)
        heightConstraint.isActive = true
        
        // Update layout
        view.layoutIfNeeded()
    }
    
    private func showSearchResults() {
        if !filteredCommunities.isEmpty {
            // Show modal background with animation
            modalBackgroundView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.modalBackgroundView.alpha = 1.0
            }
            
            // Show table view
            searchResultsTableView.isHidden = false
            isShowingSearchResults = true
        }
    }
    
    private func hideSearchResults() {
        if isShowingSearchResults {
            // Hide modal background with animation
            UIView.animate(withDuration: 0.2, animations: {
                self.modalBackgroundView.alpha = 0.0
            }) { _ in
                self.modalBackgroundView.isHidden = true
            }
            
            // Hide table view
            searchResultsTableView.isHidden = true
            isShowingSearchResults = false
        }
    }
    
    private func focusOnCommunity(_ community: Community) {
        // Clear existing annotations except user location
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        // Create and add annotation for selected community
        let annotation = MKPointAnnotation()
        annotation.title = community.communityName
        annotation.coordinate = CLLocationCoordinate2D(latitude: community.latitude, longitude: community.longitude)
        mapView.addAnnotation(annotation)
        
        // Zoom to the community location
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        // Optional: select the annotation to show its callout
        mapView.selectAnnotation(annotation, animated: true)
    }

    // CLLocationManagerDelegate method to get the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        userLocation = latestLocation
        
        // After getting the user location, set the map region to center on the user location
        let region = MKCoordinateRegion(center: latestLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        // Stop updating location to save battery
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate method to handle location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }

    func fetchCommunities() {
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

                // Map Firestore documents to Community model
                var fetchedCommunities: [Community] = []
                for document in querySnapshot.documents {
                    if let community = Community(document: document) {
                        fetchedCommunities.append(community)
                    }
                }
                print("Fetched Communities: \(fetchedCommunities.count)") // Log fetched communities
                self.communities = fetchedCommunities // Update the local array
                self.displayNearbyCommunitiesOnMap() // Now add them to the map
            }
    }

    func displayNearbyCommunitiesOnMap() {
        // Clear existing annotations first
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        // Ensure we have a valid user location
        guard userLocation != nil else {
            print("User location is nil.")
            return
        }

        // Log communities to check if the data is being passed correctly
        print("Total Communities: \(communities.count)")
        
        for community in communities {
            print("Community: \(community.communityName), Latitude: \(community.latitude), Longitude: \(community.longitude)")
            
            if community.latitude == 0 || community.longitude == 0 {
                print("Skipping community \(community.communityName) due to invalid coordinates.")
                continue
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = community.communityName
            annotation.coordinate = CLLocationCoordinate2D(latitude: community.latitude, longitude: community.longitude)
            mapView.addAnnotation(annotation)
        }

        print("Total communities added to map: \(communities.count)")
    }

    // MapView Delegate to handle user tapping on an annotation
    func mapView(_ mapView: MKMapView, didSelect annotationView: MKAnnotationView) {
        if let title = annotationView.annotation?.title,
           let selectedCommunity = communities.first(where: { $0.communityName == title }) {
            
            // Show the alert with options to join or cancel
            showJoinCommunityAlert(for: selectedCommunity)
        }
    }

    // Show an alert to ask the user whether they want to join the community
    func showJoinCommunityAlert(for community: Community) {
        let alert = UIAlertController(title: "Join Community", message: "Would you like to join the community '\(community.communityName)'?", preferredStyle: .alert)
        
        // Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Join button
        alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { _ in
            self.joinCommunity(code: community.communityCode)
        }))
        
        present(alert, animated: true, completion: nil)
    }

    // Function to join the community using the community code
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

    // Function to show simple alerts
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
