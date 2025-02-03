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
        return label
    }()
    
    private let percentage: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .main
        return label
    }()
    
    private let minNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .text
        return label
    }()
    
    private let minLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGray
        return label
    }()
    
    private let detail: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGray
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .main
        return imageView
    }()
    
    private let circularProgressView = CircularProgressView()
    
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
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

        let padding: CGFloat = 16
        let _: CGFloat = 200
        let contentView = UIView(frame: CGRect(x: padding, y: padding, width: frame.width - 2 * padding, height: frame.height - 2 * padding))
        contentView.backgroundColor = .clear
        addSubview(contentView)
       
        minNumLabel.text = ""
        contentView.addSubview(minNumLabel)
            
        detail.text = ""
        contentView.addSubview(detail) 
        
        percentage.text = ""
        contentView.addSubview(percentage)
        
        contentView.addSubview(circularProgressView)
        
        layoutSubviews(contentView: contentView)
    }

    
    private func layoutSubviews(contentView: UIView) {
        super.layoutSubviews()

        let iconSize: CGFloat = 24
        
        minNumLabel.frame = CGRect(x: 10, y: (contentView.bounds.height - 25), width: contentView.bounds.width - iconSize - 8 - 50, height: iconSize)
        
        detail.frame = CGRect(x: (contentView.bounds.width - 50), y: 0, width: contentView.bounds.width - iconSize - 8 - 50, height: iconSize)
        
        let progressSize: CGFloat = 90
        circularProgressView.frame = CGRect(x: contentView.bounds.width - progressSize - 30, y: (contentView.bounds.height - progressSize + 10) / 2, width: progressSize, height: progressSize)

        percentage.frame = CGRect(x: contentView.bounds.width - progressSize - 10, y: (contentView.bounds.height - progressSize + 5) / 2, width: progressSize, height: progressSize)
        
        circularProgressView.setupLayers()
    }

    
    func setProgress(minutes: CGFloat, dailyTarget: CGFloat) {
        let progress = max(0, min(1, minutes / dailyTarget))
        circularProgressView.setProgress(progress: progress)

        let percentageValue = min(100, progress * 100)
        percentage.text = "\(Int(percentageValue))%"
        if percentageValue == 100 {
            percentage.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        } else {
            percentage.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        }
    }
}

class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let glowLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    func setupLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.width / 2
        let startAngle: CGFloat = -(.pi / 2)
        let endAngle: CGFloat = 2 * .pi + startAngle
        
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        // Background Circle
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = UIColor.main.withAlphaComponent(0.3).cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.lineCap = CAShapeLayerLineCap.round
        layer.addSublayer(backgroundLayer)

        // Progress Circle
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.main.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)

        // Glow Effect
        glowLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        glowLayer.backgroundColor = UIColor.main.cgColor
        glowLayer.cornerRadius = 7
        glowLayer.shadowColor = UIColor.main.cgColor
        glowLayer.shadowRadius = 10
        glowLayer.shadowOpacity = 0.8
        glowLayer.isHidden = true
        layer.addSublayer(glowLayer)
    }

    func setProgress(progress: CGFloat) {
        // Clamp progress to range [0, 1]
        let clampedProgress = max(0, min(1, progress))
        
        // Animate progress circle
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = clampedProgress
        animation.duration = 0.5
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = clampedProgress

        if clampedProgress > 0 {
            glowLayer.isHidden = false

            // Calculate positions for glow animation
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius = bounds.width / 2
            let startAngle: CGFloat = -(.pi / 2)
            let endAngle: CGFloat = startAngle + (2 * .pi * clampedProgress)
            
            let glowPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            positionAnimation.path = glowPath.cgPath
            positionAnimation.duration = 0
            positionAnimation.fillMode = .forwards
            positionAnimation.isRemovedOnCompletion = false
            glowLayer.add(positionAnimation, forKey: "positionAnimation")

            // Update glow position to final point
            let glowX = center.x + radius * cos(endAngle)
            let glowY = center.y + radius * sin(endAngle)
            glowLayer.position = CGPoint(x: glowX, y: glowY)
        } else {
            // Hide the glow layer if progress is 0
            glowLayer.isHidden = true
        }
    }
}
