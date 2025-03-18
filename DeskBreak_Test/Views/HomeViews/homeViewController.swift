//
//  homeViewController.swift
//  DeskBreak_Test
//
//  Created by admin33 on 03/10/24.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabaseInternal

protocol ProfileUpdateDelegate: AnyObject {
    func updateProfileImage(_ image: UIImage)
}

class homeViewController: UIViewController, ProfileUpdateDelegate {
    
    var profileUpdateDelegate: ProfileUpdateDelegate?
    var userId: String?
    var dailyMinutes: String? = ""
    var dailyTarget: String? = ""
    
    private var db: Firestore!
    private var gameDocPath: String {
        return "games/High V"
    }
    
    
    @IBOutlet weak var flameImageView: UIImageView!
    @IBOutlet weak var homeCardSecondView: HomeCardSecond!
    @IBOutlet weak var homeCardView: HomeCard!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var profileBarButton: UIBarButtonItem!
    @IBOutlet weak var playersThisWeekLabel: UILabel!
    @IBOutlet weak var dailyMinsLabel: UILabel!
    @IBOutlet weak var dailyTargetLabel: UILabel!
    
    
    
    private let gradientLayer = CAGradientLayer()
    private let initialBackgroundColor = UIColor.bg
    @IBAction func unwindToHome(segue: UIStoryboardSegue){
        fetchDailyTargetandMinutesFromFirebase()
        fetchStreakFromFirebase()
        fetchStreakFromFirebase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        fetchDailyTargetandMinutesFromFirebase()
        fetchStreakFromFirebase()
//        setupNavigationBarWithProfileImage(image: UIImage(named: "profile"))
        fetchNameFromFirebase()
        animateFlameBounce()
        scheduleStretchNotifications()
        
        fetchProfileImage()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(homeCardTapped))
        homeCardView.addGestureRecognizer(tapGesture)
        homeCardView.isUserInteractionEnabled = true
    }
    
    private func fetchProfileImage() {
        // Always fetch fresh profile image, ignoring cache
        ProfileImageCache.shared.profileImage = nil

        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Error: userId not found in UserDefaults.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching profile picture URL: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists,
               let profilePictureURL = document.data()?["profilePictureURL"] as? String,
               let url = URL(string: profilePictureURL) {
                self.downloadImage(from: url)
            } else {
                print("Profile picture URL not found, using default image.")
                DispatchQueue.main.async {
                    let defaultImage = UIImage(named: "defaultProfileImage")
                    ProfileImageCache.shared.profileImage = defaultImage
                    self.setupNavigationBarWithProfileImage(image: defaultImage)
                }
            }
        }
    }

    private func downloadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading profile image: \(error.localizedDescription)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Store in memory cache
                    ProfileImageCache.shared.profileImage = image
                    
                    // Update UI
                    self.setupNavigationBarWithProfileImage(image: image)
                }
            }
        }
        task.resume()
    }
    
    @objc private func homeCardTapped() {
        if let userDetailsVC = storyboard?.instantiateViewController(withIdentifier: "userDetailsViewController") as? userDetailsViewController {
            let navController = UINavigationController(rootViewController: userDetailsVC)
            navController.modalPresentationStyle = .pageSheet
            userDetailsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissUserDetails))
            present(navController, animated: true)
        }
    }

    @objc private func dismissUserDetails() {
        dismiss(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .progressUpdated, object: nil)
    }
    
    private func animateFlameBounce() {
        let bounceAnimation = CABasicAnimation(keyPath: "position.y")
        bounceAnimation.fromValue = flameImageView.layer.position.y
        bounceAnimation.toValue = flameImageView.layer.position.y - 10
        bounceAnimation.duration = 0.6
        bounceAnimation.repeatCount = .infinity
        bounceAnimation.autoreverses = true
        bounceAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.5
        opacityAnimation.duration = 0.6
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.autoreverses = true
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Add animations to the layer
        flameImageView.layer.add(bounceAnimation, forKey: "bounce")
        flameImageView.layer.add(opacityAnimation, forKey: "opacity")
    }
    
    private func fetchDailyTargetandMinutesFromFirebase() {
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching daily target: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    let dailyTarget = document.data()?["dailyTarget"] as? Int16 ?? 1
                    let dailyMinutes = document.data()?["dailyMinutes"] as? Int16 ?? 1
                    print("daily min = \(dailyMinutes)")
                    print("daily tar = \(dailyTarget)")
                    DispatchQueue.main.async {
                        self.homeCardView.setProgress(minutes: CGFloat(dailyMinutes), dailyTarget: CGFloat(dailyTarget))
                        self.dailyMinsLabel.text = String(dailyMinutes)
                        self.dailyTargetLabel.text = String(dailyTarget)
                    }
                }
            }
        }
    }
    
    private func fetchNameFromFirebase() {
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching daily target: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    let userName = document.data()?["username"] as? String
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hey \(userName ?? "user")"
                    }
                }
            }
        }
    }
    
    private func fetchStreakFromFirebase() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Error: userId not found in UserDefaults.")
            return
        }

        let db = Firestore.firestore()

        // Get the current month in the format "yyyy-MM"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonth = formatter.string(from: Date())

        // Reference to the specific month's document in the monthlyStats collection
        let monthDocument = db.collection("users").document(userId).collection("monthlyStats").document(currentMonth)

        // Fetch streak from monthlyStats for the current month
        monthDocument.getDocument { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching monthlyStats: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let streak = data["streak"] as? Int else {
                print("Error: Missing or invalid streak data in monthlyStats.")
                return
            }

            print("Fetched streak: \(streak)")

            // Update the UI with the fetched streak
            DispatchQueue.main.async {
                self.playersThisWeekLabel.text = "\(streak)"
            }
        }
    }
    
    func updateHomeCard(totalMinutes: Float, dailyTarget: Float) {
        print("Updating home card with totalMinutes: \(totalMinutes), dailyTarget: \(dailyTarget)")
        homeCardView.setProgress(minutes: CGFloat(totalMinutes), dailyTarget: CGFloat(dailyTarget))
    }
    
    func updateProfileImage(_ image: UIImage) {
        profileBarButton?.image = image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layoutIfNeeded()
        animateFlameBounce()
    }

    private func setupNavigationBarWithProfileImage(image: UIImage?) {
        let profileImageView = UIImageView(image: image)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.clear.cgColor
        profileImageView.layer.borderWidth = 1
        profileImageView.isUserInteractionEnabled = true
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileButtonTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Set a fixed size using Auto Layout
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        let profileBarButtonItem = UIBarButtonItem(customView: profileImageView)
        self.navigationItem.rightBarButtonItem = profileBarButtonItem
    }

    @objc private func profileButtonTapped() {
        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            let navController = UINavigationController(rootViewController: profileVC)
            navController.modalPresentationStyle = .pageSheet
            present(navController, animated: true)
        }
    }
    
    private func setupGradientLayer() {
        let mainColor = UIColor.main
        
        gradientLayer.colors = [
            mainColor.withAlphaComponent(1.0).cgColor,
            mainColor.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        view.layer.addSublayer(gradientLayer)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxFadeOffset: CGFloat = 100
        let opacity = max(0, 1 - offset / maxFadeOffset)
        gradientLayer.opacity = Float(opacity)
    }
    
    func loginUser() {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")

        fetchProfileImage()
    }

    func logoutUser() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")

        ProfileImageCache.shared.profileImage = nil
    }
}
