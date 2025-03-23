//
//  shiftView.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 20/03/25.
//

import UIKit

class RoutineCardView: UIView {
    // MARK: - Properties
    private let mainColor = UIColor(named: "main") ?? .main
    private let cardHeight: CGFloat = 170
    private let cardWidth: CGFloat = 360

    // UI Elements
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let exerciseNameLabel = UILabel()
    private let tapIndicatorView = UIImageView()
    private let planRoutineLabel = UILabel()
    private let planRoutineIcon = UIImageView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        // Add container
        addSubview(containerView)
        
        // Title label (e.g., "Upcoming Exercise")
        titleLabel.text = "Upcoming Exercise"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .text
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Time label (e.g., "10:00 AM")
        timeLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        timeLabel.textColor = mainColor
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(timeLabel)
        
        // Exercise name label (e.g., "Neck Flex")
        exerciseNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        exerciseNameLabel.textColor = .lightGray
        exerciseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(exerciseNameLabel)
        
        // Tap indicator (e.g., a chevron or arrow)
        let tapConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        tapIndicatorView.image = UIImage(systemName: "chevron.right", withConfiguration: tapConfig)?.withRenderingMode(.alwaysTemplate)
        tapIndicatorView.tintColor = .lightGray
        tapIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tapIndicatorView)
        
        // Plan Routine Label (when no routines exist)
        planRoutineLabel.text = "Plan your routine"
        planRoutineLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        planRoutineLabel.textColor = .text
        planRoutineLabel.translatesAutoresizingMaskIntoConstraints = false
        planRoutineLabel.isHidden = true // Hidden by default
        containerView.addSubview(planRoutineLabel)
        
        // Plan Routine Icon (e.g., a calendar or plus icon)
        let planConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        planRoutineIcon.image = UIImage(systemName: "calendar.badge.plus", withConfiguration: planConfig)?.withRenderingMode(.alwaysTemplate)
        planRoutineIcon.tintColor = mainColor.withAlphaComponent(0.8)
        planRoutineIcon.translatesAutoresizingMaskIntoConstraints = false
        planRoutineIcon.isHidden = true // Hidden by default
        containerView.addSubview(planRoutineIcon)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            
            // Time label
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            // Exercise name label
            exerciseNameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            exerciseNameLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            
            // Tap indicator
            tapIndicatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            tapIndicatorView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            tapIndicatorView.widthAnchor.constraint(equalToConstant: 24),
            tapIndicatorView.heightAnchor.constraint(equalToConstant: 24),
            
            // Plan Routine Label
            planRoutineLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            planRoutineLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -20),
            
            // Plan Routine Icon
            planRoutineIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            planRoutineIcon.topAnchor.constraint(equalTo: planRoutineLabel.bottomAnchor, constant: 10),
            planRoutineIcon.widthAnchor.constraint(equalToConstant: 40),
            planRoutineIcon.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with routine: Routine?) {
        if let routine = routine {
            print("Routine found: \(routine.exerciseName) at \(routine.time)")
            // Show routine details
            titleLabel.isHidden = false
            timeLabel.isHidden = false
            exerciseNameLabel.isHidden = false
            tapIndicatorView.isHidden = false
            
            planRoutineLabel.isHidden = true
            planRoutineIcon.isHidden = true
            
            // Format the time
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            timeLabel.text = formatter.string(from: routine.time)
            
            // Set the exercise name
            exerciseNameLabel.text = routine.exerciseName
            
            // Adjust card height for routine details
            self.frame.size.height = cardHeight
        } else {
            print("No routine found. Showing 'Plan your routine' message.")
            // Show "Plan your routine" message
            titleLabel.isHidden = true
            timeLabel.isHidden = true
            exerciseNameLabel.isHidden = true
            tapIndicatorView.isHidden = true
            
            planRoutineLabel.isHidden = false
            planRoutineIcon.isHidden = false
            
            // Adjust card height for no routine
            self.frame.size.height = cardHeight
        }
        
        // Update layout
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }
}
