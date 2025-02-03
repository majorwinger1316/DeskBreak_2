//
//  HalfModalPickerViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 05/12/24.
//


import UIKit
import FirebaseFirestore

class HalfModalPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerData = (1...30).map { "\($0) min" }
    var selectedTime: String?
    
    // Callback to pass selected time back
    var onTimeSelected: ((String) -> Void)?

    private let timePicker = UIPickerView()
    private let doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .modalComponents
        
        setupPickerView()
        setupDoneButton()
    }

    private func setupPickerView() {
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timePicker)

        NSLayoutConstraint.activate([
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.tintColor = .main
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 20)
        ])
    }

    @objc private func doneButtonTapped() {
        if let selectedRow = timePicker.selectedRow(inComponent: 0) as Int? {
            let selectedTime = pickerData[selectedRow]
            onTimeSelected?(selectedTime)

            // Save the selected time to Firebase
            let db = Firestore.firestore()
            if let userId = UserDefaults.standard.string(forKey: "userId") {
                let dailyTargetValue = Int16(selectedRow + 1)  // Convert string like "5 min" to Int16
                db.collection("users").document(userId).updateData([
                    "dailyTarget": dailyTargetValue
                ]) { error in
                    if let error = error {
                        print("Error updating daily target: \(error.localizedDescription)")
                    } else {
                        print("Daily target successfully updated to \(dailyTargetValue) minutes.")
                    }
                }
            }
        }
        dismiss(animated: true)
    }


    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
