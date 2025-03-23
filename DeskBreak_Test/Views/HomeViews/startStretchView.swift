//
//  startStretchView.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 21/03/25.
//

import UIKit

class startStretchView: UIView {
    
    // MARK: - Properties
    private let mainColor = UIColor(named: "main") ?? .main
    private let cardHeight: CGFloat = 170
    private let cardWidth: CGFloat = 360
    
    // UI Elements
    private let containerView = UIView()
    private let mainMessageLabel = UILabel()
    private let actionLabel = UILabel()
    private let walkSymbolView = UIImageView()
    private let startButton = UIButton(type: .system)
    
    // Tab selection index (second tab = index 1)
    private let targetTabIndex = 1
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Card setup
        backgroundColor = .card
        
        // Container view (main card)
        containerView.frame = bounds
        containerView.backgroundColor = UIColor.card
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        // Add container border
        containerView.layer.borderWidth = 1.5
        containerView.layer.borderColor = mainColor.withAlphaComponent(0.5).cgColor
        
        // Add container
        addSubview(containerView)
        
        // Setup walk symbol
        setupSymbols()
        
        // Main message label
        mainMessageLabel.text = "Take a Break"
        mainMessageLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        mainMessageLabel.textColor = .text
        mainMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(mainMessageLabel)
        
        // Action label
        actionLabel.text = "Stretch and refresh yourself"
        actionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        actionLabel.textColor = .lightGray
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(actionLabel)
        
        // Start button
        startButton.setTitle("Start Stretching", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        startButton.backgroundColor = .main
        startButton.setTitleColor(.black, for: .normal)
        startButton.layer.cornerRadius = 20
        startButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(startButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Main message label
            mainMessageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            mainMessageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            
            // Action label
            actionLabel.leadingAnchor.constraint(equalTo: mainMessageLabel.leadingAnchor),
            actionLabel.topAnchor.constraint(equalTo: mainMessageLabel.bottomAnchor, constant: 8),
            
            // Start button
            startButton.leadingAnchor.constraint(equalTo: mainMessageLabel.leadingAnchor),
            startButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25),
            startButton.widthAnchor.constraint(equalToConstant: 160),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Walk symbol constraints
            walkSymbolView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            walkSymbolView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            walkSymbolView.widthAnchor.constraint(equalToConstant: 80),
            walkSymbolView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Add button action
        startButton.addTarget(self, action: #selector(didTapCard), for: .touchUpInside)
    }
    
    private func setupSymbols() {
        // Walk symbol
        let walkConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        let walkSymbol = UIImage(systemName: "figure.walk.circle", withConfiguration: walkConfig)?.withRenderingMode(.alwaysTemplate)
        walkSymbolView.image = walkSymbol
        walkSymbolView.tintColor = mainColor.withAlphaComponent(1.0)
        walkSymbolView.contentMode = .scaleAspectFit
        walkSymbolView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(walkSymbolView)
    }
    
    @objc private func didTapCard() {
        // Visual feedback for tap
        UIView.animate(withDuration: 0.15, animations: {
            self.startButton.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.startButton.alpha = 1.0
            }
            
            // Switch to the Stretch tab
            self.switchToStretchTab()
        }
    }
    
    private func switchToStretchTab() {
        // Find the tab bar controller and switch to the Stretch tab
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           let tabBarController = window.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = self.targetTabIndex
        } else if let viewController = self.findViewController(),
                 let tabBarController = viewController.tabBarController {
            tabBarController.selectedIndex = self.targetTabIndex
        }
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }
}
