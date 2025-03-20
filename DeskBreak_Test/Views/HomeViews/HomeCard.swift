//
//  HomeCard.swift
//  DeskBreak_Test
//
//  Created by admin33 on 01/11/24.
//

import UIKit

class HomeCard: UIView {
    // MARK: - UI Components
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .main
        label.textAlignment = .left
        return label
    }()
    
    private let minutesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .right
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .main.withAlphaComponent(0.2)
        progressView.progressTintColor = .main
        progressView.layer.cornerRadius = 6
        progressView.clipsToBounds = true
        return progressView
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup View
    private func setupView() {
        backgroundColor = .card
        layer.cornerRadius = 16
        layer.masksToBounds = false
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        // Add gradient background
        gradientLayer.colors = [
            UIColor.main.withAlphaComponent(0.1).cgColor,
            UIColor.main.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 16
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Add subviews
        addSubview(percentageLabel)
        addSubview(minutesLabel)
        addSubview(progressBar)
        
        // Layout constraints
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        minutesLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Percentage Label
            percentageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            percentageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            // Minutes Label
            minutesLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 8),
            minutesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            minutesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            // Progress Bar
            progressBar.topAnchor.constraint(equalTo: minutesLabel.bottomAnchor, constant: 24),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            progressBar.heightAnchor.constraint(equalToConstant: 12),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Update Progress
    func setProgress(minutes: CGFloat, dailyTarget: CGFloat) {
        let progress = max(0, min(1, minutes / dailyTarget))
        
        // Update progress bar
        progressBar.setProgress(Float(progress), animated: true)
        
        // Update percentage label
        let percentageValue = min(100, progress * 100)
        percentageLabel.text = "\(Int(percentageValue))%"
        
        // Update minutes label
        minutesLabel.text = "\(Int(minutes)) of \(Int(dailyTarget)) mins"
    }
}
