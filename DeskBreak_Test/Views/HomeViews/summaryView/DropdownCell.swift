//
//  DropdownCell.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 21/03/25.
//

import UIKit

class DropdownCell: UICollectionViewCell {
    
    let periodButton: UIButton = {
        let button = UIButton()
        button.setTitle("Select Period", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(periodButton)
        periodButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            periodButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            periodButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            periodButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            periodButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with period: String) {
        periodButton.setTitle(period, for: .normal)
    }
}
