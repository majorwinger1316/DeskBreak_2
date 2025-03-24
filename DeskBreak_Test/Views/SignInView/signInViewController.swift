//
//  signInViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 06/11/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Security
import FirebaseStorage
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class signInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var eyeIconClick = false
    let imageIcon = UIImageView()
    var googleUser: GIDGoogleUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        setupDoneButton(for: emailTextField)
        setupDoneButton(for: passwordTextField)
        
        imageIcon.image = UIImage(systemName: "eye.slash.circle.fill")
        
        let contentView = UIView()
        contentView.addSubview(imageIcon)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        contentView.frame = CGRect(x: 0, y: 0, width: Int(UIImage(systemName: "eye.slash.circle.fill")!.size.width), height: Int(UIImage(systemName: "eye.slash.circle.fill")!.size.height))
        imageIcon.frame = CGRect(x: -10, y: 0, width: Int(UIImage(systemName: "eye.slash.circle.fill")!.size.width), height: Int(UIImage(systemName: "eye.slash.circle.fill")!.size.height))
        
        passwordTextField.rightView = contentView
        passwordTextField.rightViewMode = .always
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPassword(tapGestureRecognizer:)))
        imageIcon.isUserInteractionEnabled = true
        imageIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func showPassword(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        if eyeIconClick {
            eyeIconClick = false
            tappedImage.image = UIImage(systemName: "eye.circle.fill")
            passwordTextField.isSecureTextEntry = false
        }
        else {
            eyeIconClick = true
            tappedImage.image = UIImage(systemName: "eye.slash.circle.fill")
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    private func saveUserSession(user: User) {
        let defaults = UserDefaults.standard
        
        defaults.set(user.userId, forKey: "userId")
        defaults.set(user.username, forKey: "userName")
        defaults.set(user.email, forKey: "userEmail")
        defaults.set(user.profilePicture, forKey: "profilePicture")
        defaults.set(user.dailyTarget, forKey: "dailyTarget")
        defaults.set(user.totalMinutes, forKey: "totalMinutes")
        defaults.set(user.totalPoints, forKey: "totalPoints")
        defaults.set(user.createdAt.timeIntervalSince1970, forKey: "createdAt")
        defaults.set(user.dateOfBirth.timeIntervalSince1970, forKey: "dateOfBirth")
        defaults.set(user.contactNumber, forKey: "contactNumber")
        defaults.set(true, forKey: "isLoggedIn")
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter email and password.")
            return
        }
        activityIndicator.startAnimating()

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
            }

            guard let userId = authResult?.user.uid else {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Error retrieving user information.")
                return
            }
            
            if let userId = authResult?.user.uid {
                self.saveToKeychain(email: email, password: password)
                fetchUserData(userId: userId, viewController: self)
            }
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue){
    }
    
    func saveToKeychain(email: String, password: String) {
        let credentials: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecValueData as String: password.data(using: .utf8)!
        ]
        SecItemAdd(credentials as CFDictionary, nil)
    }
    
    public func animateToTabBarController() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = tabBarController
                }, completion: { _ in
                    window.makeKeyAndVisible()
                })
            }
        }
    }
    
    @IBAction func signUpViewButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController2") as? signUp2ViewController {
            let navigationController = UINavigationController(rootViewController: signUpVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    func fetchAndCacheProfileImage(userId: String, completion: @escaping (Bool) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let imageData = data {
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("profile_image.jpg")
                do {
                    try imageData.write(to: fileURL)
                    UserDefaults.standard.set(fileURL.path, forKey: "cachedProfileImagePath")
                    completion(true)
                } catch {
                    print("Error saving image to cache: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    @IBAction func continueWithGoogleButtonPressed(_ sender: UIButton) {
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            // Stop the activity indicator regardless of the outcome
            defer {
                self.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                self.showAlert(message: "Google Sign-In failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = signInResult?.user, let idToken = user.idToken?.tokenString else {
                self.showAlert(message: "Failed to retrieve Google user information.")
                return
            }
            
            // Retrieve profile data from Google
            let googleIDToken = idToken
            let googleAccessToken = user.accessToken.tokenString
            let email = user.profile?.email ?? ""
            let fullName = user.profile?.name ?? ""
            let profilePicURL = user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "" // High-resolution profile picture
            
            print("Google User Data:")
            print("Email: \(email)")
            print("Name: \(fullName)")
            print("Profile Picture URL: \(profilePicURL)")
            
            // Check if the user exists in Firestore
            self.checkIfUserExistsInFirestore(email: email) { exists, userId in
                if exists, let userId = userId {
                    // User exists, fetch their data and log them in
                    fetchUserData(userId: userId, viewController: self)
                } else {
                    // User does not exist, proceed to registration
                    self.navigateToSignUp1ViewController(
                        with: googleIDToken,
                        googleAccessToken: googleAccessToken,
                        googleUser: user
                    )
                }
            }
        }
    }
    
    private func checkIfUserExistsInFirestore(email: String, completion: @escaping (Bool, String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.showAlert(message: "Failed to check user existence: \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    // User exists, return their ID
                    let userId = documents[0].documentID
                    completion(true, userId)
                } else {
                    // User does not exist
                    completion(false, nil)
                }
            }
    }
    
    private func navigateToSignUpWithApple(firebaseUser: FirebaseAuth.User, appleIDToken: String, fullName: PersonNameComponents?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController1") as? signUp1ViewController else {
            return
        }
        
        // Create registration data
        var registrationData = UserRegistrationData()
        registrationData.email = firebaseUser.email
        registrationData.appleIDToken = appleIDToken
        registrationData.appleUserIdentifier = firebaseUser.uid
        
        // Extract name components
        if let givenName = fullName?.givenName {
            registrationData.username = givenName
            if let familyName = fullName?.familyName {
                registrationData.username += " \(familyName)"
            }
        } else {
            registrationData.username = "User"
        }
        
        signUpVC.registrationData = registrationData
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    private func navigateToSignUp1ViewController(with googleIDToken: String, googleAccessToken: String, googleUser: GIDGoogleUser) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUp1VC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController1") as? signUp1ViewController {
            // Initialize and populate registrationData
            signUp1VC.registrationData = UserRegistrationData()
            signUp1VC.registrationData.email = googleUser.profile?.email ?? ""
            signUp1VC.registrationData.username = googleUser.profile?.name ?? ""
            signUp1VC.registrationData.password = "defaultPassword" // Set a default password for Google users
            signUp1VC.registrationData.contactNumber = "" // Leave phone number empty
            signUp1VC.registrationData.googleIDToken = googleIDToken // Pass the Google ID token
            signUp1VC.registrationData.googleAccessToken = googleAccessToken // Pass the Google access token
            
            // Pass the profile picture URL
            if let profilePicURL = googleUser.profile?.imageURL(withDimension: 200)?.absoluteString {
                signUp1VC.registrationData.profilePictureURL = profilePicURL
            }
            
            self.navigationController?.pushViewController(signUp1VC, animated: true)
        }
    }
    
    // Helper for Apple Sign-In
    public func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private var currentNonce: String?  // Store the nonce for verification
    
    @IBAction func continueWithAppleButton(_ sender: Any) {
        activityIndicator.startAnimating()
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)  // Securely hash the nonce
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // Helper to hash the nonce
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    private func saveUserSession(userData: [String: Any]?) {
        let defaults = UserDefaults.standard

        defaults.set(userData?["userId"] as? String, forKey: "userId")
        defaults.set(userData?["username"] as? String, forKey: "userName")
        defaults.set(userData?["email"] as? String, forKey: "userEmail")
        defaults.set(userData?["dailyTarget"] as? Int, forKey: "dailyTarget")
        defaults.set(userData?["totalMinutes"] as? Int, forKey: "totalMinutes")
        defaults.set(userData?["totalPoints"] as? Int, forKey: "totalPoints")
        defaults.set(userData?["dateOfBirth"] as? Date, forKey: "dateOfBirth")
        defaults.set(userData?["contactNumber"] as? String, forKey: "contactNumber")
        defaults.set(userData?["profilePictureURL"] as? String, forKey: "profilePictureURL")
        defaults.set(true, forKey: "isLoggedIn")
    }
    
    public func downloadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading profile picture: \(error.localizedDescription)")
                return
            }

            if let data = data {
                let base64String = data.base64EncodedString()
                UserDefaults.standard.set(base64String, forKey: "userProfilePic")
            }

            DispatchQueue.main.async {
                self.navigateToTabBarController()
            }
        }.resume()
    }
    
    private func navigateToTabBarController() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController

                if let homeVC = tabBarController.viewControllers?.first(where: { $0 is homeViewController }) as? homeViewController {
                    homeVC.profileUpdateDelegate = self

                    let defaults = UserDefaults.standard
                    let totalMinutes = defaults.float(forKey: "totalMinutes")
                    let dailyTarget = defaults.float(forKey: "dailyTarget")
                    
                    homeVC.updateHomeCard(totalMinutes: totalMinutes, dailyTarget: dailyTarget)
                }

                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }
        }
    }
    
    public func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupDoneButton(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)

        textField.inputAccessoryView = toolbar
    }

    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
}

extension signInViewController: ProfileUpdateDelegate {
    func updateProfileImage(_ image: UIImage) {
        print("Profile image updated successfully.")
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            UserDefaults.standard.set(imageData, forKey: "userProfilePic")
        }
    }
}

extension signInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        activityIndicator.startAnimating()
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            activityIndicator.stopAnimating()
            showAlert(message: "Invalid Apple Sign-In response.")
            return
        }
        
        // Create Firebase credential
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        // Sign in with Firebase
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Firebase Apple Sign-In failed: \(error.localizedDescription)")
                return
            }
            
            // Get Firebase User
            guard let firebaseUser = authResult?.user else {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Failed to get Firebase user.")
                return
            }
            
            // Check if user exists in Firestore
            self.checkIfUserExistsInFirestore(email: firebaseUser.email ?? "") { exists, userId in
                if exists, let userId = userId {
                    // Existing user - fetch data
                    fetchUserData(userId: userId, viewController: self)
                } else {
                    // New user - proceed to registration
                    self.navigateToSignUpWithApple(
                        firebaseUser: firebaseUser,
                        appleIDToken: idTokenString,
                        fullName: appleIDCredential.fullName
                    )
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        activityIndicator.stopAnimating()
        showAlert(message: "Apple Sign-In failed: \(error.localizedDescription)")
    }
}
