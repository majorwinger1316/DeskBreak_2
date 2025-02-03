//
//  onBoardingV1ViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 06/11/24.
//

import UIKit

class onBoardingV1ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        if let onBoardingV2VC = storyboard?.instantiateViewController(withIdentifier: "onBoardingV2ViewController") {
            onBoardingV2VC.modalPresentationStyle = .fullScreen
            present(onBoardingV2VC, animated: true, completion: nil)
        }
        }
    }
