import UIKit
import Firebase
import FirebaseAuth

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var detailTableView: UITableView!
    
    enum DetailType {
        case name, dateOfBirth, email, contactNumber, changePassword
    }
    
    var details: [(type: DetailType, value: Any)] = []
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if profilePicImage == nil {
            print("profilePicImage outlet is nil.")
        }
        
        if detailTableView == nil {
            print("detailTableView outlet is nil.")
        }
        profilePicImage.image = UIImage(named: "defaultProfileImage")
        setupUI()
        fetchUserData()
    }
    
    private func setupUI() {
        title = "Details"
        view.backgroundColor = .modal
        
        detailTableView.layer.cornerRadius = 12
        detailTableView.layer.masksToBounds = true
        
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailTableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
        detailTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChangePasswordCell")
    }
    
    private func fetchUserData() {
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching daily target: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    let name = document.data()?["username"] as? String ?? ""
                    let email = document.data()?["email"] as? String ?? ""
                    let contactNumber = document.data()?["contactNumber"] as? String ?? ""
                    let dateOfBirth = document.data()?["dateOfBirth"] as? String ?? ""
                    self.details = [
                        (.name, name),
                        (.dateOfBirth, dateOfBirth),
                        (.email, email),
                        (.contactNumber, contactNumber)
                    ]
                    // Add the "Change Password" row conditionally
                    self.details.append((.changePassword, "Change Password"))
                    self.detailTableView.reloadData()
                }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detail = details[indexPath.row]
        
        if detail.type == .changePassword {
            // Change password cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePasswordCell", for: indexPath)
            cell.textLabel?.text = detail.value as? String
            cell.textLabel?.textColor = .text
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
        switch detail.type {
        case .name:
            cell.configure(title: "Name", detail: detail.value as! String)
        case .dateOfBirth:
            cell.configure(title: "Date of Birth", detail: detail.value as! String)
        case .email:
            cell.configure(title: "Email", detail: detail.value as! String)
        case .contactNumber:
            cell.configure(title: "Contact Number", detail: detail.value as! String)
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = details[indexPath.row]

        if detail.type == .changePassword {
            presentChangePasswordAlert()
        }
    }

    private func presentChangePasswordAlert() {
        let alert = UIAlertController(title: "Change Password", message: "Enter your new password.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "New password"
        }
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Confirm password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let newPassword = alert.textFields?[0].text, !newPassword.isEmpty,
                  let confirmPassword = alert.textFields?[1].text, !confirmPassword.isEmpty else {
                self.showAlert(message: "Please enter both new password and confirm password.")
                return
            }
            
            if newPassword == confirmPassword {
                self.updatePassword(newPassword)
            } else {
                self.showAlert(message: "Passwords do not match.")
            }
        })
        present(alert, animated: true)
    }

    private func updatePassword(_ newPassword: String) {
        // Firebase password update logic here
        if let user = Auth.auth().currentUser {
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlert(message: "Password update failed: \(error.localizedDescription)")
                } else {
                    self.showAlert(message: "Password updated successfully.")
                }
            }
        }
    }

    private func downloadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading profile picture: \(error.localizedDescription)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profilePicImage.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.profilePicImage.image = UIImage(named: "defaultProfileImage")
                }
            }
        }.resume()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


class DetailCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)

        detailLabel.textAlignment = .right
        contentView.addSubview(detailLabel)
        
        contentView.backgroundColor = .modalComponents

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = .text
        detailLabel.textColor = .text
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            detailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }
}
