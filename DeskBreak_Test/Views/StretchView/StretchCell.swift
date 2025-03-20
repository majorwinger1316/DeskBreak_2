//
//  StretchCell.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 20/03/25.
//

import UIKit

class StretchCell: UICollectionViewCell {
    
    static let identifier = "StretchCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .main.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .text
        label.textAlignment = .left
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let targetAreaTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.text = "Target Area"
        return label
    }()
    
    private let targetAreaLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .text
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .main // Purple button
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private var stretchType: StretchType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    @objc private func startButtonTapped() {
        guard let stretchType = stretchType else {
            print("Stretch type is nil.")
            return
        }
        
        var viewController: UIViewController?
        
        // Get the storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name
        
        switch stretchType {
        case .liftUp:
            // Instantiate GameViewController from the storyboard
            viewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") // Replace with your identifier
        case .neckFlex:
            // Instantiate NeckFlexGameViewController from the storyboard
            viewController = storyboard.instantiateViewController(withIdentifier: "NeckFlexGameViewController") // Replace with your identifier
        default:
            print("Unsupported stretch type: \(stretchType)")
            return
        }
        
        guard let viewController = viewController else {
            print("Failed to instantiate view controller from storyboard.")
            return
        }
        
        // Set the modal presentation style to full screen
        viewController.modalPresentationStyle = .fullScreen
        
        // Get the topmost view controller to present from
        if let topViewController = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            
            // If the root view controller is a navigation controller, present from its top view controller
            if let navigationController = topViewController as? UINavigationController {
                navigationController.topViewController?.present(viewController, animated: true, completion: nil)
            } else {
                topViewController.present(viewController, animated: true, completion: nil)
            }
        } else {
            print("Failed to find the top view controller.")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make the cell background dark
        contentView.backgroundColor = .card
        contentView.layer.cornerRadius = 16
    }
    
    private func setupUI() {
        // Setup shadow and corner radius
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        // Add Subviews
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(targetAreaTitleLabel)
        contentView.addSubview(targetAreaLabel)
        contentView.addSubview(startButton)
        contentView.addSubview(separatorView)
        
        // Layout
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        targetAreaTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        targetAreaLabel.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Icon Container
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon Image View
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            // Duration Label
            durationLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Start Button
            startButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            startButton.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Description Label
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 16),
            
            // Separator
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // Target Area Title Label
            targetAreaTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            targetAreaTitleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12),
            
            // Target Area Label
            targetAreaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            targetAreaLabel.topAnchor.constraint(equalTo: targetAreaTitleLabel.bottomAnchor, constant: 4),
            targetAreaLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    func configure(with stretchType: StretchType) {
        self.stretchType = stretchType
        titleLabel.text = stretchType.title
        durationLabel.text = getFormattedDuration(for: stretchType)
        descriptionLabel.text = getDescription(for: stretchType)
        targetAreaLabel.text = stretchType.targetAreas
        iconImageView.image = getIcon(for: stretchType)
    }
    
    private func getFormattedDuration(for stretchType: StretchType) -> String {
        // You could customize this based on the stretch type
        switch stretchType {
        case .liftUp:
            return "1-10 minutes"
        case .neckFlex:
            return "1-10 minutes"
        default:
            return "5 minutes"
        }
    }
    
    private func getDescription(for stretchType: StretchType) -> String {
        // Customize based on stretch type
        switch stretchType {
        case .liftUp:
            return "Eases shoulder and upper back tension"
        case .neckFlex:
            return "Helps relieve the stiffness in the neck"
        default:
            return "Helps improve flexibility and reduce muscle tension"
        }
    }
    
    private func getIcon(for stretchType: StretchType) -> UIImage? {
        // You would replace these with your actual icons
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        
        switch stretchType {
        case .liftUp:
            return UIImage(systemName: "figure.wave", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        case .neckFlex:
            return UIImage(systemName: "person.and.background.dotted", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        default:
            return UIImage(systemName: "figure.walk", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
}
