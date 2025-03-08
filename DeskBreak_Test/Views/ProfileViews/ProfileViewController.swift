//
//  ProfileViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 08/11/24.
//

import UIKit
import FirebaseFirestore

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    let sections = ["Profile"]
    let profileItems = ["Details", "Dashboard", "Daily Goal"]
    let pickerData = (1...30).map { "\($0) min" }
    var selectedTime: String? = ""
    
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure Table View
        profileTableView.dataSource = self
        profileTableView.delegate = self
        profileTableView.backgroundColor = .card
        profileTableView.separatorColor = .gray
        profileTableView.layer.cornerRadius = 12
        profileTableView.layer.masksToBounds = true

        setupProfileImageView()
        setupUsernameLabel()

        // Load Profile Image
        fetchUserProfileFromFirebase()

        // Fetch Daily Target from Firebase
        fetchDailyTargetFromFirebase()
    }

    private func fetchDailyTargetFromFirebase() {
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching daily target: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    let dailyTarget = document.data()?["dailyTarget"] as? Int16 ?? 1
                    self.selectedTime = "\(dailyTarget) min"
                    DispatchQueue.main.async {
                        self.profileTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        // Show logout confirmation alert
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Confirm logout action
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            self?.logout()
        }))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    
    private func fetchUserProfileFromFirebase() {
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching user profile: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    // Fetch Daily Target
                    let dailyTarget = document.data()?["dailyTarget"] as? Int16 ?? 1
                    self.selectedTime = "\(dailyTarget) min"
                    
                    // Fetch Profile Picture URL
                    if let profilePictureURLString = document.data()?["profilePicture"] as? String {
                        self.loadProfileImage(from: profilePictureURLString)
                    }

                    DispatchQueue.main.async {
                        self.profileTableView.reloadData()
                    }
                }
            }
        }
    }
    
        private func setupProfileImageView() {
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.clipsToBounds = true
        }

        private func setupUsernameLabel() {
            if let username = UserDefaults.standard.string(forKey: "userName") {
                profileLabel.text = username
            } else {
                profileLabel.text = "User"
            }
        }

    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            self.profileImageView.image = UIImage(named: "defaultProfileImage")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil, let image = UIImage(data: data) {
                DispatchQueue.main.async { self.profileImageView.image = image }
            } else {
                DispatchQueue.main.async { self.profileImageView.image = UIImage(named: "defaultProfileImage") }
            }
        }.resume()
    }

        // MARK: - TableView DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count // Just 1 section for "Profile"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileItems.count // Three items in the profile section
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        let item = profileItems[indexPath.row]
        cell.textLabel?.text = item
        cell.backgroundColor = .modalComponents
        cell.contentView.backgroundColor = .clear

        if item == "Daily Goal" {
            let timeLabel = UILabel()
            timeLabel.text = selectedTime
            timeLabel.textColor = .lightGray
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.font = UIFont.systemFont(ofSize: 16)
            cell.contentView.addSubview(timeLabel)

            NSLayoutConstraint.activate([
                timeLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                timeLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
        } else {
            let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevron.tintColor = .lightGray
            cell.accessoryView = chevron
        }
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = profileItems[indexPath.row]
        
        switch item {
        case "Details":
            navigateToDetailsViewController()
        case "Daily Goal":
            let pickerVC = HalfModalPickerViewController()
            pickerVC.selectedTime = selectedTime
            pickerVC.onTimeSelected = { [weak self] time in
                self?.selectedTime = time
                self?.profileTableView.reloadData()
            }
            pickerVC.modalPresentationStyle = .custom
            pickerVC.transitioningDelegate = self
            present(pickerVC, animated: true)
        case "Dashboard":
            navigateToUserDetailsViewController()
        default:
            break
        }
    }
    
    private func logout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "userEmail")
        defaults.removeObject(forKey: "profilePicture")
        defaults.removeObject(forKey: "dailyTarget")
        defaults.removeObject(forKey: "totalMinutes")
        defaults.removeObject(forKey: "totalPoints")
        defaults.removeObject(forKey: "createdAt")
        defaults.removeObject(forKey: "dateOfBirth")
        defaults.removeObject(forKey: "contactNumber")
        defaults.set(false, forKey: "isLoggedIn")

        // Navigate to SignInViewController
        if let window = UIApplication.shared.windows.first {
            let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
            window.rootViewController = signInVC
            window.makeKeyAndVisible()
        }
    }
    
    func navigateToDetailsViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
            navigationController?.pushViewController(detailsVC, animated: true)
        } else {
            print("Failed to instantiate DetailsViewController.")
        }
    }

    func navigateToUserDetailsViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userDetailsVC = storyboard.instantiateViewController(withIdentifier: "userDetailsViewController") as? userDetailsViewController {
            navigationController?.pushViewController(userDetailsVC, animated: true)
        } else {
            print("Failed to instantiate UserDetailsViewController.")
        }
    }


    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1  // Number of columns in the picker
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count  // Number of rows in the column
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]  // Title for each row
    }
    }

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
