//
//  HalfModalDetailsView.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 06/03/25.
//

import UIKit

class HalfModalDetailsView: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let shiftOptions = [
        "9 AM - 5 PM",
        "10 AM - 6 PM",
        "11 AM - 7 PM",
        "12 PM - 8 PM",
        "1 PM - 9 PM"
        ]
    
    var selectedShift: String = UserDefaults.standard.string(forKey: "selectedShift") ?? "9 AM - 5 PM"
    
    var onShiftSelected: ((String) -> Void)?

    private let shiftPicker = UIPickerView()
    private let doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .modalComponents
        
        setupPickerView()
        setupDoneButton()
    }

    private func setupPickerView() {
        shiftPicker.delegate = self
        shiftPicker.dataSource = self
        shiftPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shiftPicker)

        NSLayoutConstraint.activate([
            shiftPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shiftPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
            doneButton.topAnchor.constraint(equalTo: shiftPicker.bottomAnchor, constant: 20)
        ])
    }

    @objc private func doneButtonTapped() {
        if let selectedRow = shiftPicker.selectedRow(inComponent: 0) as Int? {
            let selectedshift = shiftOptions[selectedRow]
            let selectedIndex = self.shiftPicker.selectedRow(inComponent: 0)
            self.selectedShift = self.shiftOptions[selectedIndex]
            UserDefaults.standard.set(self.selectedShift, forKey: "selectedShift")
            print("Shift Timings changed to \(selectedshift)")
            scheduleStretchNotifications()
        }
        dismiss(animated: true)
        if let detailsVC = self.presentingViewController as? DetailsViewController {
            detailsVC.detailTableView.reloadData()
        }
    }


    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shiftOptions.count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shiftOptions[row]
    }

}
