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
    private let itemsPerRow: Int = 2
    
    /// Reuse identifier for the cell in the `UICollectionView`.
    private let cellReuseId = "APODCell"
    
    /// APOD cache which will be used to load data. Will load data and refresh UI if it is set.
    var apodCache: APODCache? = nil {
        didSet {
            // TODO: Reload data
        }
    }
    
    private(set) var numberOfItemsDisplayed: Int = Configuration.initialCacheLoadAmount
    
    
    // MARK: -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// - Parameters:
    ///     - apodCache: The `APODCache` instance to use, to load APODs.
    init(frame: CGRect = .zero, cache apodCache: APODCache?) {
        self.apodCache = apodCache
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        
        // Create and setup UICollectionView
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = collectionViewInsets
        layout.estimatedItemSize = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(APODCellView.self, forCellWithReuseIdentifier: cellReuseId)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
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
        return numberOfItemsDisplayed
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: cellReuseId,
          for: indexPath
        ) as? APODCellView else { fatalError("Cell was not registered") }
        
        guard let requestDate = DateUtils.today(adding: -indexPath.row-1) else {
            // TODO: handle this
            fatalError("Cell was not registered")
        }
        
        cell.id = requestDate
        
        Task {
            // Load APOD metadata
            var apod = try await apodCache?.apod(for: requestDate)
            if cell.id == requestDate {
                cell.setTitle(apod?.title)
                cell.setAccessoryText(apod?.date.formatted(date: .numeric, time: .omitted))
            }
            
            // Load APOD thumbnail
            apod = try await apodCache?.apod(for: requestDate, withThumbnail: true)
            if cell.id == requestDate {
                cell.setImage(await apod?.thumbnail)
            }
        }
        
        
        return cell
    }
    
    
}


extension APODListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = horizontalCellPadding * CGFloat(itemsPerRow + 1)
        let availableWidth = self.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)

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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard Configuration.infiniteScroll else { return }
        // Find the lowest row displayed
        let visibleCells = collectionView.visibleCells
        guard let maxIndexPath = visibleCells
            .map({ cell in
                collectionView.indexPath(for: cell)?.row ?? 0
                
            })
            .max(by: { $0 < $1 })
        else {
            return
        }
        
        // Calculate which is the last row that is displayed
        let maxRow = (maxIndexPath + 1) / Int(itemsPerRow)
        
        print("Current row \(maxRow), last row \(numberOfItemsDisplayed / 2) (\(numberOfItemsDisplayed))")
        
        
        // 3 rows before end, show load 5 more rows
        if maxRow > (numberOfItemsDisplayed / 2) - 3 {
            numberOfItemsDisplayed = min(
                numberOfItemsDisplayed + 5 * itemsPerRow,
                Configuration.maximumAPODAmount)
            collectionView.reloadData()
            print("Load 5 more cells")
        }
    }
}
