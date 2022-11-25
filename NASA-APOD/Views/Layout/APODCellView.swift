//
//  APODCellView.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 25.11.22.
//

import UIKit

class APODCellView: UICollectionViewCell {
    
    // MARK: Views
    
    private var imageView: UIImageView!
    private var accessView: UIView!
    
    
    // MARK: Model
    
    /// The APOD object that is presented in the view
    var apod: APOD? {
        didSet {
            // TODO: Reload UI
        }
    }
    
    
    // MARK: -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    init(frame: CGRect = .zero, apod: APOD?) {
        self.apod = apod
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .green
    }
}
