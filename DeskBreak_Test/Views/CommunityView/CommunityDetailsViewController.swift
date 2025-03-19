//
//  CommunityDetailsViewController.swift
//  DeskBreak_Test
//
//  Created by admin44 on 17/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseFunctions
import FirebaseAuth
import FirebaseStorage

class CommunityDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var popUpButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    var selectedUserId : Array<String> = []
    var members: [(userId: String, username: String, totalPoints: Int32)] = []
    var filteredMembers: [(userId: String, username: String, totalPoints: Int32)] = []
    var profilePictures: [String: UIImage] = [:] // Dictionary to store profile pictures
    
    enum SortType {
        case pointsDescending, pointsAscending, nameAscending, nameDescending
    }
    
    var community: Community?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.register(MemberTableViewCell.self, forCellReuseIdentifier: MemberTableViewCell.identifier)
        
        tableView.backgroundColor = .clear
        tableView.separatorColor = .lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allows table view selection while the keyboard is dismissed
        view.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = false // Disabled initially

        // Observe keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Update UI with community details
        if let community = community {
            titleLabel.text = community.communityName
            codeLabel.text = "Community Code: \(community.communityCode)"
            fetchMembers()
            
            // Check if the current user is the admin (createdBy user) or if createdBy is nil
            if let currentUserId = Auth.auth().currentUser?.uid {
                if community.createdBy == nil || currentUserId == community.createdBy {
                    // Enable delete button for admin or if createdBy is nil
                    navigationItem.rightBarButtonItems?.append(UIBarButtonItem(
                        title: "Delete",
                        style: .plain,
                        target: self,
                        action: #selector(deleteCommunityButtonPressed)
                    ))
                }
            }
        }
        configurePopUpButton()
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tabBarController = self.tabBarController,
           let navigationController = self.navigationController {
            
            // Check if this view is not the topmost view controller
            if navigationController.viewControllers.last !== self {
                navigationController.popToRootViewController(animated: false)
            }
        }

        tableView.register(MemberTableViewCell.self, forCellReuseIdentifier: MemberTableViewCell.identifier)
        configurePopUpButton()
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
    
    @objc func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMembers = members // Reset filter when empty
        } else {
            filteredMembers = members.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }

    @objc func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredMembers = members
        tableView.reloadData()
    }
    
    func configurePopUpButton() {
        let sortByPointsDescending = UIAction(title: "Points (High to Low)", image: UIImage(systemName: "arrow.down")) { _ in
            self.sortMembers(by: .pointsDescending)
        }

        let sortByPointsAscending = UIAction(title: "Points (Low to High)", image: UIImage(systemName: "arrow.up")) { _ in
            self.sortMembers(by: .pointsAscending)
        }

        let sortByNameAscending = UIAction(title: "Name (A-Z)", image: UIImage(systemName: "textformat.abc")) { _ in
            self.sortMembers(by: .nameAscending)
        }

        let sortByNameDescending = UIAction(title: "Name (Z-A)", image: UIImage(systemName: "textformat.abc")) { _ in
            self.sortMembers(by: .nameDescending)
        }

        let menu = UIMenu(title: "Sort By", children: [
            sortByPointsDescending,
            sortByPointsAscending,
            sortByNameAscending,
            sortByNameDescending
        ])

        popUpButton.menu = menu
        popUpButton.showsMenuAsPrimaryAction = true
    }

    func sortMembers(by sortType: SortType) {
        switch sortType {
        case .pointsDescending:
            filteredMembers.sort { $0.totalPoints > $1.totalPoints }
        case .pointsAscending:
            filteredMembers.sort { $0.totalPoints < $1.totalPoints }
        case .nameAscending:
            filteredMembers.sort { $0.username.lowercased() < $1.username.lowercased() }
        case .nameDescending:
            filteredMembers.sort { $0.username.lowercased() > $1.username.lowercased() }
        }
        tableView.reloadData()
    }
    
    @IBAction func leaveCommunityButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Leave Community?",
            message: "Are you sure you want to leave this community?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            self.leaveCommunity()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func leaveCommunity() {
        guard let community = community, let currentUserId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        // 1. Remove the current user from the "members" subcollection of the community
        db.collection("communities")
            .document(community.communityId)
            .collection("members")
            .document(currentUserId)
            .delete { error in
                if let error = error {
                    print("Error removing user from community: \(error.localizedDescription)")
                    return
                }

                print("User successfully removed from community.")
                
                // 2. Optionally, decrement the member count in the community document
                let communityRef = db.collection("communities").document(community.communityId)
                
                communityRef.updateData([
                    "memberCount": FieldValue.increment(Int64(-1))
                ]) { error in
                    if let error = error {
                        print("Error updating member count: \(error.localizedDescription)")
                        return
                    }
                    
                    // 4. Provide feedback to the user that they left the community
                    self.showAlert(message: "You have successfully left the community.")

                    if let navController = self.navigationController {

                        navController.popViewController(animated: true)
                        
                        if let communityVC = navController.viewControllers.first(where: { $0 is communityViewController }) as? communityViewController {
                            communityVC.fetchUserCommunities()
                        }
                    }
                }
            }
    }
    
    @IBAction func deleteCommunityButton(_ sender: UIBarButtonItem) {
    }

    @objc func deleteCommunityButtonPressed() {
        guard let community = community else { return }

        let alertController = UIAlertController(
            title: "Delete Community?",
            message: "Are you sure you want to delete this community? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteCommunity()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func deleteCommunity() {
        guard let community = community else { return }

        let db = Firestore.firestore()

        // Delete the community document
        db.collection("communities").document(community.communityId).delete { error in
            if let error = error {
                print("Error deleting community: \(error.localizedDescription)")
                self.showAlert(message: "Failed to delete the community. Please try again.")
                return
            }

            print("Community successfully deleted.")
            
            // Provide feedback to the user
            self.showAlert(message: "The community has been successfully deleted.")

            // Navigate back to the previous screen
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
                
                // Refresh the community list in the previous view controller
                if let communityVC = navController.viewControllers.first(where: { $0 is communityViewController }) as? communityViewController {
                    communityVC.fetchUserCommunities()
                }
            }
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        guard let community = community else { return }

        // Construct the shareable link or message
        let communityCode = community.communityCode
        let shareableMessage = """
        Join my community on DeskBreak! Use this code to join: \(communityCode)
        Download the app and get started!
        """

        // Create an instance of UIActivityViewController with the message
        let activityViewController = UIActivityViewController(activityItems: [shareableMessage], applicationActivities: nil)

        // Exclude certain activity types if necessary
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .print
        ]

        // Present the activity view controller
        present(activityViewController, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func fetchMembers() {
        guard let community = community else {
            print("Community is nil")
            return
        }

        let db = Firestore.firestore()

        // Start the loading animation
        activityIndicator.startAnimating()
        tableView.isHidden = true  // Hide table until data is loaded

        db.collection("communities")
            .document(community.communityId)
            .collection("members")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching members: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    return
                }

                let userIds = querySnapshot?.documents.compactMap { $0.data()["userId"] as? String } ?? []
                self.selectedUserId = userIds

                self.fetchUserDetails(userIds: userIds) { userDetails in
                    self.members = userDetails.map { (userId: $0.userId, username: $0.username, totalPoints: $0.totalPoints) }
                    self.filteredMembers = self.members

                    for detail in userDetails {
                        self.profilePictures[detail.userId] = detail.profilePicture
                    }

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.tableView.isHidden = false

                        // Animate table view appearance
                        self.animateTableView()
                    }
                }
            }
    }
    
    func animateTableView() {
        tableView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.alpha = 1
        })
    }

    func fetchUserDetails(userIds: [String], completion: @escaping ([(userId: String, username: String, totalPoints: Int32, profilePicture: UIImage)]) -> Void) {
        let db = Firestore.firestore()
        var userDetails: [(userId: String, username: String, totalPoints: Int32, profilePicture: UIImage)] = []
        
        let group = DispatchGroup()
        
        for userId in userIds {
            group.enter()
            
            // Fetch user details from Firestore
            db.collection("users").document(userId).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error fetching user details for userId \(userId): \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                guard let document = documentSnapshot, document.exists,
                      let username = document.data()?["username"] as? String,
                      let totalPoints = document.data()?["totalPoints"] as? Int32,
                      let profilePictureURL = document.data()?["profilePictureURL"] as? String else {
                    print("Document does not exist or username/totalPoints/profilePictureURL not found for userId \(userId)")
                    group.leave()
                    return
                }
                
                // Fetch profile picture using the URL
                if !profilePictureURL.isEmpty {
                    if let url = URL(string: profilePictureURL) {
                        URLSession.shared.dataTask(with: url) { data, response, error in
                            if let error = error {
                                print("Error downloading profile picture for \(userId): \(error.localizedDescription)")
                                // Use default profile picture if download fails
                                let defaultProfilePicture = UIImage(named: "defaultProfileImage")!
                                userDetails.append((userId: userId, username: username, totalPoints: totalPoints, profilePicture: defaultProfilePicture))
                                group.leave()
                                return
                            }
                            
                            if let data = data, let profilePicture = UIImage(data: data) {
                                userDetails.append((userId: userId, username: username, totalPoints: totalPoints, profilePicture: profilePicture))
                            } else {
                                // Use default profile picture if data is invalid
                                let defaultProfilePicture = UIImage(named: "defaultProfileImage")!
                                userDetails.append((userId: userId, username: username, totalPoints: totalPoints, profilePicture: defaultProfilePicture))
                            }
                            group.leave()
                        }.resume()
                    } else {
                        // Use default profile picture if URL is invalid
                        let defaultProfilePicture = UIImage(named: "defaultProfileImage")!
                        userDetails.append((userId: userId, username: username, totalPoints: totalPoints, profilePicture: defaultProfilePicture))
                        group.leave()
                    }
                } else {
                    // Use default profile picture if profilePictureURL is empty
                    let defaultProfilePicture = UIImage(named: "defaultProfileImage")!
                    userDetails.append((userId: userId, username: username, totalPoints: totalPoints, profilePicture: defaultProfilePicture))
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            // Sort userDetails to match the order of userIds
            let sortedUserDetails = userIds.compactMap { userId in
                userDetails.first { $0.userId == userId }
            }
            completion(sortedUserDetails)
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMembers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemberTableViewCell.identifier, for: indexPath) as! MemberTableViewCell

        if indexPath.row < filteredMembers.count {
            let member = filteredMembers[indexPath.row]
            cell.nameLabel.text = "\(member.username)"
            cell.pointsLabel.text = "\(member.totalPoints)"
            
            // Fetch profile picture from the dictionary
            if let profilePicture = self.profilePictures[member.userId] {
                cell.profileImageView.image = profilePicture
            } else {
                cell.profileImageView.image = UIImage(named: "defaultProfileImage")
            }
            
            // Mark the admin (createdBy user) if createdBy exists
            if let community = community{
                
                if member.userId == community.createdBy {
                    cell.nameLabel.text = "👑 \(member.username)" 
                }
            }
        }

        cell.backgroundColor = .clear
        cell.alpha = 0
         UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: .curveEaseInOut, animations: {
             cell.alpha = 1
         }, completion: nil)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row \(indexPath.row) tapped.")

        // Ensure the index is within bounds
        guard indexPath.row < filteredMembers.count else {
            print("Index out of bounds for filteredMembers array.")
            return
        }

        // Get the selected member
        let selectedMember = filteredMembers[indexPath.row]
        let memberId = selectedMember.userId

        fetchUserDetails(userIds: [memberId]) { userDetails in
            guard let user = userDetails.first else { return }

            if let memberDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "MemberDetailsViewController") as? MemberDetailsViewController {
                memberDetailsVC.memberId = user.userId
                self.present(memberDetailsVC, animated: true, completion: nil)
            }
        }
    }
}
