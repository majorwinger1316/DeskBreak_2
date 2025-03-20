//
//  CommunityCollectionViewCell.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 20/03/25.
//

import UIKit

class CommunityCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .card // Use a secondary background color for the card
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        return view
    }()
    
    private let communityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30 // Circular image (60x60)
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.3.fill")?.withTintColor(.main, renderingMode: .alwaysOriginal) // Use .main as accent color
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .text // Use primary text color for better readability
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray // Use secondary text color for less emphasis
        label.numberOfLines = 2
        return label
    }()
    
    private let locationIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "location.fill"))
        imageView.tintColor = .main // Use .main as accent color
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .main // Use .main as accent color
        return label
    }()
    
    private let chevronIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .main // Use .main as accent color
        return imageView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .clear
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(communityImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(locationIcon)
        containerView.addSubview(locationLabel)
        containerView.addSubview(chevronIcon)
        
        // Set constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        communityImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Community image
            communityImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            communityImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            communityImageView.widthAnchor.constraint(equalToConstant: 60),
            communityImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: communityImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: communityImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -8),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Location icon
            locationIcon.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            locationIcon.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationIcon.widthAnchor.constraint(equalToConstant: 12),
            locationIcon.heightAnchor.constraint(equalToConstant: 12),
            
            // Location label
            locationLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 4),
            locationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Chevron icon
            chevronIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronIcon.widthAnchor.constraint(equalToConstant: 12),
            chevronIcon.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    // MARK: - Configure Cell
    func configure(with community: Community) {
        // Set community name
        nameLabel.text = community.communityName
        
        // Set community description (or placeholder)
        descriptionLabel.text = community.communityDescription ?? "No description available."
        
        // Set community location (or placeholder)
        locationLabel.text = community.placeName ?? "Location not available."
        
        // Set community image (or placeholder)
        if let imageUrl = community.communityImageUrl, let url = URL(string: imageUrl) {
            // Load image from URL
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.communityImageView.image = image
                    }
                }
            }.resume()
        } else {
            communityImageView.image = UIImage(systemName: "person.3.fill")?.withTintColor(.main, renderingMode: .alwaysOriginal)
        }
        
        // Add a subtle animation to the cell
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.containerView.transform = .identity
            }
        }
    }
}
