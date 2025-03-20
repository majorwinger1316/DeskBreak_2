import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var detailTableView: UITableView!
    
    enum DetailType {
        case name, dateOfBirth, email, contactNumber, workShift
    }
    
    var details: [(type: DetailType, value: Any)] = []
    
    let pickerData = (1...30).map { "\($0) min" }
    
    let shiftOptions = [
        "9 AM - 5 PM",
        "10 AM - 6 PM",
        "11 AM - 7 PM",
        "12 PM - 8 PM",
        "1 PM - 9 PM"
        ]
    
    var selectedShift: String = UserDefaults.standard.string(forKey: "selectedShift") ?? "9 AM - 5 PM"
    
    let shiftPicker = UIPickerView()
    
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
        if let profileImage = ProfileImageCache.shared.profileImage {
            self.profilePicImage.image = profileImage
        } else {
            // Fetch again if not in cache (only needed in rare cases)
            self.profilePicImage.image = UIImage(named: "defaultProfileImage")
        }
        detailTableView.reloadData()
        setupUI()
        fetchUserData()
        setupProfileImageView()
    }
    
    private func setupShiftPicker() {
        shiftPicker.delegate = self
        shiftPicker.dataSource = self
        
        if let index = shiftOptions.firstIndex(of: selectedShift) {
            shiftPicker.selectRow(index, inComponent: 0, animated: false)
        }
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
    
    private func setupProfileImageView() {
        profilePicImage.layer.cornerRadius = profilePicImage.frame.width / 2
        profilePicImage.clipsToBounds = true
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

                    // Handle dateOfBirth if it's a Timestamp or a String
                    var dateOfBirth = ""
                    if let timestamp = document.data()?["dateOfBirth"] as? Timestamp {
                        let date = timestamp.dateValue()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMMM yyyy" // Example: "13 January 2003"
                        dateOfBirth = formatter.string(from: date)
                    } else if let dateString = document.data()?["dateOfBirth"] as? String {
                        dateOfBirth = dateString
                    }

                    self.details = [
                        (.name, name),
                        (.dateOfBirth, dateOfBirth),
                        (.email, email),
                        (.contactNumber, contactNumber),
                        (.workShift, self.selectedShift)
                    ]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
        
        switch detail.type {
        case .name:
            cell.configure(title: "Name", detail: detail.value as! String, textColor: .text)
        case .dateOfBirth:
            cell.configure(title: "Date of Birth", detail: detail.value as! String, textColor: .text)
        case .email:
            cell.configure(title: "Email", detail: detail.value as! String, textColor: .text)
        case .contactNumber:
            cell.configure(title: "Contact Number", detail: detail.value as! String, textColor: .text)
        case .workShift:
            cell.configure(title: "Work Shift", detail: selectedShift, textColor: .gray)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if details[indexPath.row].type == .workShift {
            let pickerVC = HalfModalDetailsView()
            pickerVC.selectedShift = selectedShift
            pickerVC.onShiftSelected = { [weak self] shift in
                self?.selectedShift = shift
                self?.detailTableView.reloadData()
            }
            pickerVC.modalPresentationStyle = .custom
            pickerVC.transitioningDelegate = self
            present(pickerVC, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1  // Number of columns in the picker
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shiftOptions.count  // Number of rows in the column
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shiftOptions[row]  // Title for each row
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

    func configure(title: String, detail: String, textColor: UIColor = .black) {
        titleLabel.text = title
        detailLabel.text = detail
        detailLabel.textColor = textColor
    }
}

extension DetailsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
