//
//  LoadableImageView.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 23.11.22.
//

import UIKit

/// An image view that shows a loading screen, when the `image` property is not set.
class LoadableImageView: UIView {
    
    // MARK: Views
    
    private var imageView: UIImageView!
    private var loadingView: UIView!
    
    
    // MARK: Model
    
    /// Enables fading the loading view above the image.
    var fadeEnabled: Bool = true
    
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
            // Hide/Show loading view if image is nil/present
            if newValue != nil {
                // Set newValue and hide, if it's not nil loading view thereafter
                if self.imageView.image == nil {
                    // Change value directly, if previous value was nil
                    self.imageView.image = newValue
                } else {
                    // Cross fade to new image, if there was already an image displayed
                    UIView.transition(with: self.imageView,
                                      duration: 2.0,
                                      options: .transitionCrossDissolve,
                                      animations: { self.imageView.image = newValue },
                                      completion: nil)
                }
                hideLoadingView(animated: fadeEnabled)
            } else {
                // If new value is nil, set it first after hiding
                showLoadingView(animated: fadeEnabled) { finished in
                    if newValue == nil {
                        self.imageView.image = newValue
                    }
                }
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
        
        self.clipsToBounds = true
    }
    
    /// Shows the loading screen.
    ///
    /// - Parameters:
    ///     - animated: If set to `true`, showing will be animated. Default is `true`.
    ///     - duration: The show animation's duration in seconds. Defaults to `showLoadingViewAnimationDuration`.
    ///     - completion: Handler that gets executed when the animation sequence ends. Receives a boolean value indicating, whether the animation was completed successfully.
    func showLoadingView(animated: Bool = true, duration: TimeInterval? = nil, completion: ((Bool) -> ())? = nil) {
        // Show only if not already shown
        guard self.loadingView.isHidden else { return }
        
        // Animate only if flag is set
        if animated {
            self.loadingView.isHidden = false
            UIView.animate(withDuration: duration ?? showLoadingViewAnimationDuration, animations: {
                self.loadingView.alpha = 1
            }) { (finished) in
                completion?(finished)
            }
        } else {
            self.loadingView.alpha = 1
            completion?(true)
        }
    }
    
    /// Hides the loading screen.
    ///
    /// - Parameters:
    ///     - animated: If set to `true`, hiding will be animated. Default is `true`.
    ///     - duration: The hide animation's duration in seconds. Defaults to `hideLoadingViewAnimationDuration`.
    ///     - completion: Handler that gets executed when the animation sequence ends. Receives a boolean value indicating, whether the animation was completed successfully.
    func hideLoadingView(animated: Bool = true, duration: TimeInterval? = nil, completion: ((Bool) -> ())? = nil) {
        // Hide only if not already hidden
        guard !self.loadingView.isHidden else { return }
        
        // Animate only if flag is set
        if animated {
            UIView.animate(withDuration: duration ?? hideLoadingViewAnimationDuration, animations: {
                self.loadingView.alpha = 0
            }) { (finished) in
                self.loadingView.isHidden = finished
                completion?(finished)
            }
        } else {
            self.loadingView.alpha = 0
            completion?(true)
        }
    }

}
