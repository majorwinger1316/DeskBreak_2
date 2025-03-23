//
//  WeekdaySelectView.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 21/03/25.
//

import UIKit

class WeekdaySelectView: UIView {
    // MARK: - Properties
    var weekdayButtons: [UIButton] = []
    var selectedDays: Set<WeekdayCode> = [] {
        didSet {
            updateButtonStates()
        }
    }
    
    // MARK: - UI Elements
    private let stackView = UIStackView()
    
    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStackView()
        createWeekdayButtons()
    }
    
    // MARK: - Setup Methods
    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func createWeekdayButtons() {
        for weekday in WeekdayCode.allCases {
            let button = UIButton(type: .system)
            button.setTitle(weekday.shortName, for: .normal)
            button.tag = weekday.rawValue
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            
            // Add subtle animations
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            button.addTarget(self, action: #selector(weekdayButtonTapped(_:)), for: .touchUpInside)
            
            weekdayButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        updateButtonStates()
    }
    
    // MARK: - Button Actions
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.7
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 1.0
        }
    }
    
    @objc private func weekdayButtonTapped(_ sender: UIButton) {
        guard let weekday = WeekdayCode(rawValue: sender.tag) else { return }
        
        if selectedDays.contains(weekday) {
            selectedDays.remove(weekday)
        } else {
            selectedDays.insert(weekday)
        }
        
        updateButtonStates()
    }
    
    // MARK: - State Management
    private func updateButtonStates() {
        for button in weekdayButtons {
            guard let weekday = WeekdayCode(rawValue: button.tag) else { continue }
            
            if selectedDays.contains(weekday) {
                button.backgroundColor = .main.withAlphaComponent(0.5)
                button.setTitleColor(.text, for: .normal)
                
                // Subtle selection animation
                let animation = CABasicAnimation(keyPath: "borderWidth")
                animation.fromValue = 1.0
                animation.toValue = 2.0
                animation.duration = 0.2
                animation.autoreverses = true
                button.layer.add(animation, forKey: "border")
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.lightGray, for: .normal)
            }
        }
    }
    
    // MARK: - Helper Methods
    func selectAll() {
        selectedDays = Set(WeekdayCode.allCases)
    }
    
    func deselectAll() {
        selectedDays.removeAll()
    }
    
    func getSelectedWeekdays() -> [WeekdayCode] {
        return Array(selectedDays).sorted { $0.rawValue < $1.rawValue }
    }
}
