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
    
    var members: [(userId: String, username: String, totalPoints: Int32)] = []
    
    var community: Community?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register the cell with the .value1 style
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
        guard let community = community else {
            print("Community is nil")
            return
        }

        let db = Firestore.firestore()

        db.collection("communities")
            .document(community.communityId)
            .collection("members")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching members: \(error.localizedDescription)")
                    return
                }

                print("Fetched members: \(querySnapshot?.documents.count ?? 0)")

                // Extract userIds and maintain the order
                var membersData = querySnapshot?.documents.compactMap { document -> (String, String, Int32)? in
                    if let userId = document.data()["userId"] as? String {
                        return (userId, "", 0) // Initialize with empty username and 0 points
                    }
                    return nil
                } ?? []

                print("Members data: \(membersData)")

                let userIds = membersData.map { $0.0 }
                self.selectedUserId = userIds // Preserve the exact order

                self.fetchUsernamesAndPoints(userIds: userIds) { usernames, totalPoints in
                    DispatchQueue.main.async {
                        print("Fetched usernames: \(usernames)")
                        print("Fetched totalPoints: \(totalPoints)")

                        // Ensure usernames and points align with the same order
                        for (index, username) in usernames.enumerated() {
                            if index < membersData.count {
                                membersData[index].1 = username
                                membersData[index].2 = totalPoints[index]
                            }
                        }

                        // Update the members array with userId, username, and totalPoints
                        self.members = membersData.map { (userId: $0.0, username: $0.1, totalPoints: $0.2) }

                        // Sort members by totalPoints in descending order
                        self.members.sort { $0.totalPoints > $1.totalPoints }

                        print("Updated and sorted members array: \(self.members)")

                        self.memberLabel.text = "Members: \(userIds.count)"
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    func fetchUsernamesAndPoints(userIds: [String], completion: @escaping ([String], [Int32]) -> Void) {
        let db = Firestore.firestore()
        var usernames: [String] = []
        var totalPoints: [Int32] = []

        let group = DispatchGroup()

        for userId in userIds {
            group.enter()
            db.collection("users").document(userId).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error fetching username and points for userId \(userId): \(error.localizedDescription)")
                } else if let document = documentSnapshot, document.exists,
                          let username = document.data()?["username"] as? String,
                          let points = document.data()?["totalPoints"] as? Int32 {
                    print("Fetched username: \(username), points: \(points) for userId: \(userId)")
                    usernames.append(username)
                    totalPoints.append(points)
                } else {
                    print("Document does not exist or username/points not found for userId \(userId)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            print("All usernames and points fetched: \(usernames), \(totalPoints)")
            completion(usernames, totalPoints)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell with the correct style
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "memberCell")
        
        if indexPath.row < members.count {
            let member = members[indexPath.row]
            cell.textLabel?.text = "\(indexPath.row + 1). \(member.username)" // Display rank and username
            cell.detailTextLabel?.text = "\(member.totalPoints)" // Display points on the right side
            cell.detailTextLabel?.textColor = .main
        } else {
            cell.textLabel?.text = "Unknown Member"
            cell.detailTextLabel?.text = ""
        }
        
        cell.backgroundColor = .clear
        cell.layer.masksToBounds = true

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
