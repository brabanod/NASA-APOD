//
//  LoadableImageView.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 23.11.22.
//

import UIKit

/// An image view that shows a loading screen, when the `image` property is not set.
class LoadableImageView: UIView {
    
    private var imageView: UIImageView!
    private var loadingView: UIView!
    
    /// Specifies the duration of the loading view's show animation.
    var showLoadingViewAnimationDuration: TimeInterval = 0.5
    
    /// Specifies the duration of the loading view's hide animation.
    var hideLoadingViewAnimationDuration: TimeInterval = 2.0
    
    /// Image which is presented in the image view. Setting/unsetting the image will hide/show the loading view.
    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
            
            // Show/Hide loading view if image is nil/present
            if self.image != nil {
                hideLoadingView()
            } else {
                showLoadingView()
            }
        }
    }
    
    
    // MARK: -

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Add the image view
        imageView = UIImageView(frame: .zero)
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        imageView.contentMode = .scaleAspectFill
        
        // Add the view that will display the loading animation
        loadingView = UIView(frame: .zero)
        self.addSubview(loadingView)
        loadingView.backgroundColor = .black
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: loadingView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: loadingView.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: loadingView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: loadingView.bottomAnchor).isActive = true
    }
    
    /// Shows the loading screen.
    ///
    /// - Parameters:
    ///     - animated: If set to `true`, showing will be animated. Default is `true`.
    ///     - duration: The show animation's duration in seconds. Defaults to `showLoadingViewAnimationDuration`.
    func showLoadingView(animated: Bool = true, duration: TimeInterval? = nil) {
        UIView.animate(withDuration: duration ?? showLoadingViewAnimationDuration, animations: {
            self.loadingView.alpha = 1
        }) { (finished) in
            self.loadingView.isHidden = !finished
        }
    }
    
    /// Hides the loading screen.
    ///
    /// - Parameters:
    ///     - animated: If set to `true`, hiding will be animated. Default is `true`.
    ///     - duration: The hide animation's duration in seconds. Defaults to `hideLoadingViewAnimationDuration`.
    func hideLoadingView(animated: Bool = true, duration: TimeInterval? = nil) {
        UIView.animate(withDuration: duration ?? hideLoadingViewAnimationDuration, animations: {
            self.loadingView.alpha = 0
        }) { (finished) in
            self.loadingView.isHidden = finished
        }
    }

}
