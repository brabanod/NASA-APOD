//
//  APODHighlightViewReusableWrapper.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 05.12.22.
//

import UIKit

class APODHighlightViewReusableWrapper: UICollectionReusableView {
    
    // MARK: Views
    
    var highlightView: APODHighlightView!
    
    
    // MARK: Model
    
    /// APOD cache which will be used to load data. Will load data and refresh UI if it is set.
    var apodCache: APODCache? = nil {
        didSet {
            highlightView.apodCache = apodCache
        }
    }
    
    
    // MARK: -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        highlightView = APODHighlightView(frame: .zero)
        self.addSubview(highlightView)
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: highlightView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: highlightView.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: highlightView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: highlightView.bottomAnchor).isActive = true
    }
}
