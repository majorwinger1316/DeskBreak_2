//
//  onBoardingV2ViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 06/11/24.
//

import UIKit

class onBoardingV2ViewController: UIViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        self.dismiss(animated: true) {
            if let window = UIApplication.shared.windows.first {
                let signInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! signInViewController

                window.rootViewController = signInViewController
                window.makeKeyAndVisible()
            }
        }
    }

}
