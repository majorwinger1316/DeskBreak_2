//
//  SceneDelegate.swift
//  DeskBreak_Test
//
//  Created by admin33 on 21/09/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let isOnboardingCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

        let initialViewController: UIViewController

        if !isOnboardingCompleted {
            // Show Onboarding if not completed
            initialViewController = storyboard.instantiateViewController(withIdentifier: "onBoardingV2ViewController")
        } else if !isLoggedIn {
            // Show Login if onboarding is completed but user is not logged in
            initialViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        } else {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        }

        // Embed the initial view controller in a navigation controller
        let navigationController = UINavigationController(rootViewController: initialViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}

