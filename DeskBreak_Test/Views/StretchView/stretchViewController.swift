// leaderboardViewController.swift
import UIKit
import FirebaseFirestore
import FirebaseAuth

class stretchViewController: UIViewController {
    
    @IBOutlet weak var gameCollectionView: UICollectionView!
    private let stretches: [StretchType] = [.liftUp, .neckFlex]
    
    @IBAction func unwindToStretch(segue: UIStoryboardSegue){
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBackground()
        if let flowLayout = gameCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = .zero // Disable automatic sizing
        }
    }
    
    private func setupCollectionView() {
        gameCollectionView.delegate = self
        gameCollectionView.dataSource = self
        gameCollectionView.register(StretchCell.self, forCellWithReuseIdentifier: StretchCell.identifier)
        gameCollectionView.backgroundColor = .clear
        
        // Configure collection view layout for better spacing
        if let flowLayout = gameCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 16
            flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor.bg // Set background to black like in the image
    }
}

extension stretchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stretches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StretchCell.identifier, for: indexPath) as! StretchCell
        cell.configure(with: stretches[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32 // Account for left and right padding
        let height: CGFloat = 180 // Fixed height for all cells
        return CGSize(width: width, height: height)
    }
}
