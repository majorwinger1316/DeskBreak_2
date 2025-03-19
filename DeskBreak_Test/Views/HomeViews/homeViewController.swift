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
        fetchProfileImage()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layoutIfNeeded()
        animateFlameBounce()
        
        // Add a subtle entrance animation for content
        let originalTransform = contentView.transform
        contentView.transform = originalTransform.translatedBy(x: 0, y: 20)
        contentView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.contentView.transform = originalTransform
            self.contentView.alpha = 1
        }, completion: nil)
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

            // Check if the document exists and has streak data
            if let data = snapshot?.data(), let streak = data["streak"] as? Int {
                print("Fetched streak: \(streak)")

                // Update the UI with the fetched streak
                DispatchQueue.main.async {
                    self.playersThisWeekLabel.text = "\(streak)"
                    self.removeBlurMask() // Remove blur mask if it exists
                }
            } else {
                // If no streak data is found, display the blur mask with the message
                DispatchQueue.main.async {
                    self.addBlurMask(withMessage: "To start a streak, perform any stretching")
                }
            }
        }
    }

    // MARK: - Blur Mask Setup

    private func addBlurMask(withMessage message: String) {
        // Remove existing blur mask if any
        removeBlurMask()

        // Create a blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = homeCardSecondView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = homeCardSecondView.layer.cornerRadius
        blurView.clipsToBounds = true
        blurView.tag = 1001 // Tag to identify the blur view later

        // Add a semi-transparent background
        let tintView = UIView(frame: blurView.bounds)
        tintView.backgroundColor = UIColor.card.withAlphaComponent(0.1)
        tintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.contentView.addSubview(tintView)

        // Add an info icon
        let iconImageView = UIImageView(image: UIImage(systemName: "info.circle.fill"))
        iconImageView.tintColor = .lightGray
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(iconImageView)

        // Add the message label
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .lightGray
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(messageLabel)

        // Add constraints for the icon and label
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            messageLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
        ])

        // Add the blur view to the home card
        homeCardSecondView.addSubview(blurView)
    }

    private func removeBlurMask() {
        if let blurView = homeCardSecondView.viewWithTag(1001) {
            blurView.removeFromSuperview()
        }
    }
    
    func updateHomeCard(totalMinutes: Float, dailyTarget: Float) {
        print("Updating home card with totalMinutes: \(totalMinutes), dailyTarget: \(dailyTarget)")
        homeCardView.setProgress(minutes: CGFloat(totalMinutes), dailyTarget: CGFloat(dailyTarget))
    }
    
    func updateProfileImage(_ image: UIImage) {
        profileBarButton?.image = image
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
        
        // Configure the gradient layer
        gradientLayer.colors = [
            mainColor.withAlphaComponent(1.0).cgColor,
            mainColor.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 500)
        
        // Make sure the gradient is behind all content but still visible
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Ensure the scrollView is above the gradient
        if let scrollView = scrollView {
            view.bringSubviewToFront(scrollView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient frame to match the view's current bounds
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
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
