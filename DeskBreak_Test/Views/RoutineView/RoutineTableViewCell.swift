//
//  RoutineTableViewCell.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 21/03/25.
//

import UIKit

class RoutineTableViewCell: UITableViewCell {
    @IBOutlet weak var stretchLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reminderImageView: UIImageView!
    @IBOutlet weak var weekdayStackView: UIStackView!
    
    private var weekdayIndicators: [UIView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createWeekdayIndicators()
    }
    
    private func createWeekdayIndicators() {
        // Clear existing indicators
        weekdayStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        weekdayIndicators.removeAll()
        
        for weekday in WeekdayCode.allCases {
            let indicator = createCircleIndicator()
            indicator.tag = weekday.rawValue
            
            let label = UILabel()
            label.text = weekday.shortName
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.textColor = .lightGray
            
            indicator.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: indicator.centerYAnchor)
            ])
            
            weekdayIndicators.append(indicator)
            weekdayStackView.addArrangedSubview(indicator)
            weekdayStackView.spacing = 5
            weekdayStackView.distribution = .fillEqually
        }
    }
    
    private func createCircleIndicator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 28),
            view.widthAnchor.constraint(equalToConstant: 28)
        ])
        
        return view
    }
    
    func configure(with routine: Routine) {
        stretchLabel.text = routine.exerciseName
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: routine.time)
        
        // Update weekday indicators
        for indicator in weekdayIndicators {
            guard let weekday = WeekdayCode(rawValue: indicator.tag) else { continue }
            let isSelected = routine.weekdays.contains(weekday)
            
            // Update indicator appearance
            indicator.backgroundColor = isSelected ? .main.withAlphaComponent(0.5) : .clear
            
            // Update the text color of the label
            if let label = indicator.subviews.first as? UILabel {
                label.textColor = isSelected ? .text : .lightGray
            }
        }
        
        // Set reminder icon
        if routine.reminderEnabled {
            reminderImageView.image = UIImage(systemName: "bell.fill")
            reminderImageView.tintColor = .main
        } else {
            reminderImageView.image = UIImage(systemName: "bell.slash")
            reminderImageView.tintColor = .systemGray
        }
    }
}
