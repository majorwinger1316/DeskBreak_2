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

class CommunityDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    var selectedUserId : Array<String> = []
    
    var members: [(userId: String, username: String)] = []
    
    var community: Community?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "memberCell")
        tableView.backgroundColor = .clear
        tableView.separatorColor = .lightGray
        
        // Update UI with community details
        if let community = community {
            titleLabel.text = community.communityName
            codeLabel.text = "Community Code: \(community.communityCode)"
            fetchMembers()
        }
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

                    // 3. Send a notification to other community members (optional)
                    self.sendNotificationToUsers(userIds: community.members, message: "A member has left the community.")
                    
                    // 4. Provide feedback to the user that they left the community
                    self.showAlert(message: "You have successfully left the community.")

                    // 5. Call fetchUserCommunities() in CommunityViewController
                    if let navController = self.navigationController {
                        // Navigate back to the previous view controller
                        navController.popViewController(animated: true)

                        // Ensure fetchUserCommunities is called in the previous view controller (CommunityViewController)
                        if let communityVC = navController.viewControllers.first(where: { $0 is communityViewController }) as? communityViewController {
                            communityVC.fetchUserCommunities()
                        }
                    }
                }
            }
    }
    
    func sendNotificationToUsers(userIds: [String], message: String) {
        let functions = Functions.functions()

        // Prepare the payload
        let data = [
            "userIds": userIds,
            "message": message
        ] as [String : Any]
        
        functions.httpsCallable("sendNotificationFunction").call(data) { result, error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else if let result = result {
                print("Notification sent: \(result)")
            }
        }
    }
    
    @IBAction func sendNotificationButton(_ sender: UIBarButtonItem) {
        guard let community = community else { return }

        // Fetch members' userIds and usernames
        fetchMembers1 { (usernames: [String]) in  // Explicitly define the type here
            // Construct the notification message
            let message = "Important Update from \(community.communityName). Stay competitive and check out the latest updates!"

            // Call your notification sending function with the fetched usernames
            self.sendNotificationToUsers(userIds: community.members, message: message)

            // Show alert after sending notifications
            self.showAlert(message: "Notifications sent successfully to all members.")
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

    func fetchMembers1(completion: @escaping ([String]) -> Void) {
        guard let community = community else { return }

        let db = Firestore.firestore()

        db.collection("communities")
            .document(community.communityId)  // fetching the community document
            .collection("members")  // accessing the "members" subcollection
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching members: \(error.localizedDescription)")
                    return
                }

                // Extract the userIds from the "members" subcollection
                let userIds = querySnapshot?.documents.compactMap { document in
                    return document.data()["userId"] as? String
                } ?? []

                print("Fetched userIds: \(userIds)")

                // Now fetch the usernames for each userId
                self.fetchUsernames(userIds: userIds) { usernames in
                    // Once we have usernames, pass them back via the completion block
                    completion(usernames)
                }
            }
    }
    
    func fetchMembers() {
        guard let community = community else { return }

        let db = Firestore.firestore()

        db.collection("communities")
            .document(community.communityId)  // fetching the community document
            .collection("members")  // accessing the "members" subcollection
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching members: \(error.localizedDescription)")
                    return
                }

                // Extract userIds and maintain the order
                var membersData = querySnapshot?.documents.compactMap { document -> (String, String)? in
                    if let userId = document.data()["userId"] as? String {
                        return (userId, "")
                    }
                    return nil
                } ?? []

                let userIds = membersData.map { $0.0 }
                self.selectedUserId = userIds // Preserve the exact order

                self.fetchUsernames(userIds: userIds) { usernames in
                    DispatchQueue.main.async {
                        // Ensure usernames align with the same order
                        for (index, username) in usernames.enumerated() {
                            if index < membersData.count {
                                membersData[index].1 = username
                            }
                        }

                        self.community?.members = membersData.map { $0.1 } // Populate community.members with usernames
                        self.memberLabel.text = "Members: \(userIds.count)"
                        self.tableView.reloadData()
                    }
                }
            }
    }

    
    func fetchUsernames(userIds: [String], completion: @escaping ([String]) -> Void) {
      let db = Firestore.firestore()
      var usernames: [String] = []

      let group = DispatchGroup()

      for userId in userIds {
        group.enter()
        db.collection("users").document(userId).getDocument { documentSnapshot, error in
          if let error = error {
            print("Error fetching username for userId \(userId): \(error.localizedDescription)")
          } else if let document = documentSnapshot, document.exists,
                    let username = document.data()?["username"] as? String {
            usernames.append(username)
          } else {
            print("Document does not exist or username not found for userId \(userId)")
          }
          group.leave()
        }
      }

      group.notify(queue: .main) {
        completion(usernames)
      }
    }

    func fetchUsers(userIds: [String], completion: @escaping ([User]) -> Void) {
      let db = Firestore.firestore()
      var users: [User] = []

      let group = DispatchGroup()

      for userId in userIds {
        group.enter()
        db.collection("users").document(userId).getDocument { documentSnapshot, error in
          if let error = error {
            print("Error fetching user data for userId \(userId): \(error.localizedDescription)")
          } else if let document = documentSnapshot, document.exists,
                    var data = document.data() {
            print("Fetched data for userId \(userId): \(data)")
            if let username = data["username"] as? String {
              data["username"] = username
            }

            // Create User from parsed data
            if let user = User(data: data) {
              users.append(user)
            } else {
              print("Failed to parse user data for userId \(userId)")
            }
          } else {
            print("Document does not exist or error occurred for userId \(userId)")
          }
          group.leave()
        }
      }

      group.notify(queue: .main) {
        completion(users)
      }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return community?.members.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
        
        if let member = community?.members[indexPath.row] {
            cell.textLabel?.text = "\(indexPath.row + 1). \(member)"
        }
        
        cell.backgroundColor = .clear
        cell.layer.masksToBounds = true
        cell.accessoryType = .detailButton

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row \(indexPath.row) tapped.")

        // Calculate the reversed index
        let reversedIndex = (selectedUserId.count - 1) - indexPath.row

        // Ensure the reversed index is within bounds
        guard reversedIndex >= 0 && reversedIndex < selectedUserId.count else {
            print("Reversed index out of bounds for members or selectedUserId array.")
            return
        }

        let memberId = selectedUserId[reversedIndex]  // Use reversed index

        fetchUsers(userIds: [memberId]) { users in
            guard let user = users.first else { return }

            if let memberDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "MemberDetailsViewController") as? MemberDetailsViewController {
                memberDetailsVC.memberId = user.userId
                self.present(memberDetailsVC, animated: true, completion: nil)
            }
        }
    }
}
