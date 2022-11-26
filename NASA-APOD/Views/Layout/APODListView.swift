//
//  APODListView.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 24.11.22.
//

import UIKit

class APODListView: UIView {
    
    // MARK: Views
    
    private var collectionView: UICollectionView!
    
    
    // MARK: Model
    
    private let horizontalCellPadding: CGFloat = 20.0
    private let verticalCellPadding: CGFloat = 20.0
    private var collectionViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: verticalCellPadding, left: horizontalCellPadding, bottom: verticalCellPadding, right: horizontalCellPadding)
    }
    
    /// Specifies how many cells should be displayed in one row.
    private let itemsPerRow: CGFloat = 2
    
    /// Reuse identifier for the cell in the `UICollectionView`.
    private let cellId = "APODCell"
    
    /// APOD API object. Will load data and refresh UI if it is set.
    var apodAPI: APODAPI? = nil {
        didSet {
            // TODO: Reload data
        }
    }
    
    
    // MARK: -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    init(frame: CGRect = .zero, api apodAPI: APODAPI?) {
        self.apodAPI = apodAPI
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Create and setup UICollectionView
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = collectionViewInsets
        layout.estimatedItemSize = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(APODCellView.self, forCellWithReuseIdentifier: cellId)
        collectionView.showsVerticalScrollIndicator = false
        
        // Add UICollectionView to subviews
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: collectionView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: collectionView.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
    }
}


extension APODListView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: cellId,
          for: indexPath
        ) as? APODCellView else { fatalError("Cell was not registered") }

        return cell
    }
    
    
}


extension APODListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = horizontalCellPadding * (itemsPerRow + 1)
        let availableWidth = self.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionViewInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return verticalCellPadding
    }
}


extension APODListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select!: \(indexPath)")
    }
}
