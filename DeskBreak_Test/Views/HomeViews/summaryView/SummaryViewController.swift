//
//  SummaryViewViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 21/03/25.
//

import UIKit

class SummaryViewController: UIViewController {
    
    @IBOutlet weak var durationSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var summaryCollectionView: UICollectionView!

    var selectedPeriod: String?
    
    var last6Weeks: [String] = ["Mar 1 - Mar 7", "Mar 8 - Mar 14", "Mar 15 - Mar 21", "Mar 22 - Mar 28", "Mar 29 - Apr 4", "Apr 5 - Apr 11"]
    var last6Months: [String] = ["October 2024", "November 2024", "December 2024", "January 2025", "February 2025", "March 2025"]

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedPeriod = durationSegmentControl.selectedSegmentIndex == 0 ? last6Weeks.first : last6Months.first

        summaryCollectionView.delegate = self
        summaryCollectionView.dataSource = self
        summaryCollectionView.register(DropdownCell.self, forCellWithReuseIdentifier: "DropdownCell")
        summaryCollectionView.register(StatsCell.self, forCellWithReuseIdentifier: "StatsCell")
    }

    @IBAction func durationSegmentChanged(_ sender: UISegmentedControl) {
        selectedPeriod = sender.selectedSegmentIndex == 0 ? last6Weeks.first : last6Months.first
        summaryCollectionView.reloadData()
    }
}

// MARK: - CollectionView DataSource & Delegate
extension SummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Section 0: Dropdown, Section 1: Stats
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : 3 // 3 Stats: Total Minutes, Sessions Completed, Percentage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DropdownCell", for: indexPath) as! DropdownCell
            cell.configure(with: selectedPeriod ?? "Select Period")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell", for: indexPath) as! StatsCell
            let dummyStats = [
                ("Total Minutes Stretched", "240 min"),
                ("Sessions Completed", "12 sessions"),
                ("Achievement", "75% of goal met")
            ]
            let stat = dummyStats[indexPath.item]
            cell.configure(title: stat.0, value: stat.1)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 20
        return CGSize(width: width, height: indexPath.section == 0 ? 50 : 80)
    }
}
