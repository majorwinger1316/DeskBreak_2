//
//  MemberDetailsViewController 2.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 19/11/24.
//


import UIKit

class MemberDetailsViewController: UIViewController {
    
    // Define UI components
    var scrollView: UIScrollView!
    var contentView: UIView!
    var progressView: UIView!
    var historyView: UIView!
    var awardsView: UIView!
    
    // Data properties
    var member: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.bg
        title = member?.name ?? "Member Details"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.text]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissViewController))
        
        setupViews()
        setupConstraints() // Ensure this is called to apply constraints
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupViews() {
        // Initialize and configure scroll view and content view
        scrollView = UIScrollView()
        contentView = UIView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Create section labels outside of cards
        let progressLabel = createSectionTitleLabel(withText: "Progress")
        let historyLabel = createSectionTitleLabel(withText: "History")
        let awardsLabel = createSectionTitleLabel(withText: "Awards")
        
        // Configure individual sections
        setupProgressView()
        setupHistoryView()
        setupAwardsView()
        
        // Arrange labels and sections in a stack view for vertical alignment
        let stackView = UIStackView(arrangedSubviews: [
            progressLabel, progressView,
            historyLabel, historyView,
            awardsLabel, awardsView
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupProgressView() {
        progressView = createCardView()
        
        let activeDaysLabel = createIconDetailLabel(icon: "figure.walk", text: "Total Active Days", value: "\(member?.totalActiveDays ?? 0)")
        let pointsLabel = createIconDetailLabel(icon: "camera", text: "Total Points Earned", value: "\(member?.points ?? 0)")
        let positionLabel = createIconDetailLabel(icon: "person.3", text: "Position", value: "\(member?.position ?? 0)")
        
        let progressStack = UIStackView(arrangedSubviews: [activeDaysLabel, pointsLabel, positionLabel])
        progressStack.axis = .vertical
        progressStack.spacing = 16
        
        progressStack.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(progressStack)
        
        NSLayoutConstraint.activate([
            progressStack.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: 16),
            progressStack.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -16),
            progressStack.topAnchor.constraint(equalTo: progressView.topAnchor, constant: 16),
            progressStack.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupHistoryView() {
        historyView = createCardView()
        
        let minutesLabel = UILabel()
        minutesLabel.text = "\(member?.dailyGoal ?? 0)"
        minutesLabel.font = UIFont.boldSystemFont(ofSize: 48)
        minutesLabel.textColor = .text // Ensure text color is not white
        minutesLabel.textAlignment = .center
        
        let minutesDescriptionLabel = UILabel()
        minutesDescriptionLabel.text = "Minutes"
        minutesDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        minutesDescriptionLabel.textColor = .lightGray
        minutesDescriptionLabel.textAlignment = .center
        
        let lastExerciseLabel = createIconDetailLabel(icon: "figure.wave", text: "Last Exercise", value: "Score: 100") // Static for now
        let skyKickLabel = createIconDetailLabel(icon: "timer", text: "SkyKick Scorer", value: "Minutes: 10") // Static for now
        
        let historyStack = UIStackView(arrangedSubviews: [minutesLabel, minutesDescriptionLabel, lastExerciseLabel, skyKickLabel])
        historyStack.axis = .vertical
        historyStack.spacing = 16
        historyStack.alignment = .center
        
        historyStack.translatesAutoresizingMaskIntoConstraints = false
        historyView.addSubview(historyStack)
        
        NSLayoutConstraint.activate([
            historyStack.leadingAnchor.constraint(equalTo: historyView.leadingAnchor, constant: 16),
            historyStack.trailingAnchor.constraint(equalTo: historyView.trailingAnchor, constant: -16),
            historyStack.topAnchor.constraint(equalTo: historyView.topAnchor, constant: 16),
            historyStack.bottomAnchor.constraint(equalTo: historyView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupAwardsView() {
        awardsView = createCardView()
        
        let seeMoreButton = UIButton(type: .system)
        seeMoreButton.setTitle("See More", for: .normal)
        seeMoreButton.tintColor = .lightGray
        seeMoreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
        seeMoreButton.addTarget(self, action: #selector(seeMoreTapped), for: .touchUpInside)
        
        awardsView.addSubview(seeMoreButton)
        
        // Static awards for now
        let awardImage1 = createAwardImage(imageName: "star.fill", title: "7 Day Streak")
        let awardImage2 = createAwardImage(imageName: "timer", title: "100 Minutes")
        let awardImage3 = createAwardImage(imageName: "trophy.fill", title: "First Stretch")
        
        // Stack the images and their titles vertically
        let imageStack = UIStackView(arrangedSubviews: [awardImage1, awardImage2, awardImage3])
        imageStack.axis = .horizontal
        imageStack.spacing = 24
        imageStack.alignment = .center
        imageStack.translatesAutoresizingMaskIntoConstraints = false
        awardsView.addSubview(imageStack)
        
        // Add constraints for the "See More" button
        NSLayoutConstraint.activate([
            seeMoreButton.topAnchor.constraint(equalTo: awardsView.topAnchor, constant: 16),
            seeMoreButton.trailingAnchor.constraint(equalTo: awardsView.trailingAnchor, constant: -16),
            
            // Add constraints for the image stack
            imageStack.topAnchor.constraint(equalTo: seeMoreButton.bottomAnchor, constant: 16),
            imageStack.centerXAnchor.constraint(equalTo: awardsView.centerXAnchor),
            imageStack.leadingAnchor.constraint(equalTo: awardsView.leadingAnchor, constant: 16),
            imageStack.trailingAnchor.constraint(equalTo: awardsView.trailingAnchor, constant: -16),
            imageStack.bottomAnchor.constraint(equalTo: awardsView.bottomAnchor, constant: -16)
        ])
    }

    // Helper to create an image and title label for the awards
    private func createAwardImage(imageName: String, title: String) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .center
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: imageName)
        imageView.tintColor = .main
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .text
        titleLabel.textAlignment = .center
        
        container.addArrangedSubview(imageView)
        container.addArrangedSubview(titleLabel)
        
        return container
    }

    @objc func seeMoreTapped() {
        print("See More tapped")
    }

    // Helper to create section title label
    private func createSectionTitleLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .text
        return label
    }
    
    // Helper to create label with icon and text
    private func createIconDetailLabel(icon: String, text: String, value: String) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .center
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: icon)
        imageView.tintColor = .text
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = .text
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .text
        
        container.addArrangedSubview(imageView)
        container.addArrangedSubview(textLabel)
        container.addArrangedSubview(valueLabel)
        
        return container
    }

    // Helper to create a card view
    private func createCardView() -> UIView {
        let cardView = UIView()
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.backgroundColor = .card // Use the correct card color
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }
}
