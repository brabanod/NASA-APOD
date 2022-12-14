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
    
    private var topBar: BlurBar!
    
    
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
    
    /// Reuse identifier for the highlight (header) view.
    private let headerReuseId = "APODHighlightView"
    
    /// APOD cache which will be used to load data. Will load data and refresh UI if it is set.
    var apodCache: APODCache? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private(set) var numberOfItemsDisplayed: Int = Configuration.initialCacheLoadAmount
    
    var delegate: APODListViewDelegate?
    
    
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
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.accessibilityIdentifier = "APODList"
        
        // Add UICollectionView to subviews
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: collectionView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: collectionView.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        
        // Create highlight view
        collectionView.register(APODHighlightViewReusableWrapper.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: headerReuseId)
        
        // Add top bar
        topBar = BlurBar(frame: .zero)
        self.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: topBar.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: topBar.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: topBar.topAnchor).isActive = true
        self.safeAreaLayoutGuide.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
    }
    
    @objc func didTapHighlightView(_ sender: AnyObject) {
        guard let today = DateUtils.today() else {
            Log.default.log("Failed to create today date.")
            AlertComposer.showErrorAlert(type: .errorGeneral, in: self.window?.presentedViewController)
            return
        }
        delegate?.showAPODDetail(for: today, sender: sender)
    }
    
    /// Based on the visible cells, this method decides whether to load more items in the collection view.
    func loadMoreItemsIfNeeded() {
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
        
        
        // 3 rows before end, show load 5 more rows
        if maxRow > (numberOfItemsDisplayed / 2) - 3 {
            numberOfItemsDisplayed = min(
                numberOfItemsDisplayed + 5 * itemsPerRow,
                Configuration.maximumAPODAmount)
            collectionView.reloadData()
        }
    }
    
    /// Shows or hides top bar, based on the given scroll position.
    func toggleTopBar(scrollPosition: CGPoint) {
        // Only show top bar if scrolled past 10 pixels
        if scrollPosition.y >= 10 {
            topBar.showBlur()
        } else {
            topBar.hideBlur()
        }
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
        let cellUntyped = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellReuseId,
            for: indexPath)
        
        guard let cell = cellUntyped as? APODCellView else {
            Log.default.log("Failed to dequeue reusable cell with id '\(self.cellReuseId)'.")
            AlertComposer.showErrorAlert(type: .errorGeneral, in: self.window?.presentedViewController)
            return cellUntyped
        }
        cell.accessibilityIdentifier = "Cell\(indexPath.row)"
        
        // Explicitly call to layout cell. This is needed in order to correctly draw the gradient view.
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        guard let requestDate = DateUtils.today(adding: -indexPath.row-1) else {
            Log.default.log("Failed to create date from today by adding \(-indexPath.row-1) days.")
            AlertComposer.showErrorAlert(type: .errorGeneral, in: self.window?.presentedViewController)
            return cellUntyped
        }
        
        cell.id = requestDate
        
        Task {
            // Load APOD metadata
            var apod = try await apodCache?.apod(for: requestDate)
            if cell.id == requestDate {
                cell.setTitle(apod?.title)
                cell.setAccessoryText(apod?.date.formatted(.dateTime.year(.extended()).month(.twoDigits).day(.twoDigits)))
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        // Initialize APODHighlightView as the only header
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseId, for: indexPath)
        
        guard let typedHeaderView = headerView as? APODHighlightViewReusableWrapper else { return headerView }
        typedHeaderView.apodCache = self.apodCache
        
        // Setup tap gesture for header
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHighlightView(_:)))
        typedHeaderView.addGestureRecognizer(tapGesture)
        
        typedHeaderView.accessibilityIdentifier = "Highlight"
        
        return typedHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height * 0.75)
    }
}


extension APODListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let requestDate = DateUtils.today(adding: -indexPath.row-1) else {
            Log.default.log("Failed to create date from today by adding \(-indexPath.row-1) days.")
            AlertComposer.showErrorAlert(type: .errorGeneral, in: self.window?.presentedViewController)
            return
        }
        delegate?.showAPODDetail(for: requestDate, sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreItemsIfNeeded()
        toggleTopBar(scrollPosition: scrollView.contentOffset)
    }
}

protocol APODListViewDelegate {
    func showAPODDetail(for date: Date, sender: AnyObject)
}
