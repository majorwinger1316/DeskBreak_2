//
//  HomeCard.swift
//  DeskBreak_Test
//
//  Created by admin33 on 01/11/24.
//

import UIKit

class HomeCard: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .main
        label.text = "Daily Progress"
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .main
        label.textAlignment = .left
        return label
    }()
    
    private let minutesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .right
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .main.withAlphaComponent(0.3)
        progressView.progressTintColor = .main
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        return progressView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .card
        layer.cornerRadius = 12
        layer.masksToBounds = false
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        // Add subviews
        addSubview(titleLabel)
        addSubview(percentageLabel)
        addSubview(minutesLabel)
        addSubview(progressBar)
        
        // Layout constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        minutesLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Percentage Label
            percentageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            percentageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            // Minutes Label
            minutesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            minutesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            minutesLabel.leadingAnchor.constraint(equalTo: percentageLabel.trailingAnchor, constant: 8),
            
            // Progress Bar
            progressBar.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 16),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            progressBar.heightAnchor.constraint(equalToConstant: 8),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    func setProgress(minutes: CGFloat, dailyTarget: CGFloat) {
        let progress = max(0, min(1, minutes / dailyTarget))
        
        // Update progress bar
        progressBar.setProgress(Float(progress), animated: true)
        
        // Update percentage label
        let percentageValue = min(100, progress * 100)
        percentageLabel.text = "\(Int(percentageValue))%"
        
        // Update minutes label
        minutesLabel.text = "\(Int(minutes))/\(Int(dailyTarget)) mins"
    }
}
