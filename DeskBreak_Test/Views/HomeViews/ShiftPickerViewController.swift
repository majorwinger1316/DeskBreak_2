//
//  ShiftPickerViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 20/03/25.
//

import UIKit

protocol ShiftPickerDelegate: AnyObject {
    func didSelectShift(_ shift: String)
}

class ShiftPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Properties
    private let shiftOptions = [
        "9 AM - 5 PM",
        "10 AM - 6 PM",
        "11 AM - 7 PM",
        "12 PM - 8 PM",
        "1 PM - 9 PM"
    ]

    private let pickerView = UIPickerView()
    weak var delegate: ShiftPickerDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Select Shift"

        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton

        view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Select the current shift
        let selectedShift = UserDefaults.standard.string(forKey: "selectedShift") ?? "9 AM - 5 PM"
        if let index = shiftOptions.firstIndex(of: selectedShift) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }

    // MARK: - Actions
    @objc private func doneTapped() {
        let selectedShift = shiftOptions[pickerView.selectedRow(inComponent: 0)]
        delegate?.didSelectShift(selectedShift)
        dismiss(animated: true)
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shiftOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shiftOptions[row]
    }
}
