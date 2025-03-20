//
//  shiftView.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 20/03/25.
//

import UIKit

class ShiftInfoView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "person.badge.clock")?
            .withTintColor(.label, renderingMode: .alwaysOriginal)
        let attributedText = NSMutableAttributedString(attachment: imageAttachment)
        attributedText.append(NSAttributedString(string: " Work Shift"))
        
        label.attributedText = attributedText
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let shiftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let notificationToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false // Default is off
        toggle.onTintColor = .systemBlue
        return toggle
    }()

    private let changeShiftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Shift", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Notifications will be sent Mon-Fri during your shift."
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        updateShiftLabel()
    }

    // Required initializer for storyboard/XIB usage
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
        updateShiftLabel()
    }

    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        clipsToBounds = true

        let isNotificationEnabled = UserDefaults.standard.bool(forKey: "isNotificationEnabled")
        notificationToggle.isOn = isNotificationEnabled

        let stackView = UIStackView(arrangedSubviews: [titleLabel, shiftLabel, notificationToggle, changeShiftButton, infoLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        changeShiftButton.addTarget(self, action: #selector(changeShiftTapped), for: .touchUpInside)
        notificationToggle.addTarget(self, action: #selector(notificationToggleChanged), for: .valueChanged)
    }

    @objc private func changeShiftTapped() {
        // Open HalfModalPresentationController to select a new shift
        let shiftPickerVC = ShiftPickerViewController()
        shiftPickerVC.delegate = self
        let navController = UINavigationController(rootViewController: shiftPickerVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        // Present the modal
        if let parentVC = self.parentViewController {
            parentVC.present(navController, animated: true)
        }
    }

    @objc private func notificationToggleChanged() {
        // Save the toggle state to UserDefaults
        UserDefaults.standard.set(notificationToggle.isOn, forKey: "isNotificationEnabled")

        if notificationToggle.isOn {
            scheduleStretchNotifications()
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    // MARK: - Update Shift Label
    private func updateShiftLabel() {
        let selectedShift = UserDefaults.standard.string(forKey: "selectedShift") ?? "9 AM - 5 PM"
        shiftLabel.text = selectedShift
    }
}

// MARK: - ShiftPickerDelegate
extension ShiftInfoView: ShiftPickerDelegate {
    func didSelectShift(_ shift: String) {
        UserDefaults.standard.set(shift, forKey: "selectedShift")
        updateShiftLabel()

        if notificationToggle.isOn {
            scheduleStretchNotifications()
        }
    }
}

// MARK: - Helper Extension
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
