//
//  TopBar.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 07.12.22.
//

import UIKit

/// A view, that can show and hide a blur effect.
class BlurBar: UIView {
    
    // MARK: Views
    
    private var blurView: UIVisualEffectView!
    private var separator: UIView!
    
    
    // MARK: Model
    
    /// Indicates, whether the hide animation of the blur view is running.
    private var isAnimatingHideTopBar = false
    
    
    
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
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.addSubview(blurView)
        blurView.isHidden = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: blurView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: blurView.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: blurView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: blurView.bottomAnchor).isActive = true

        // Add top bar separator
        separator = UIView(frame: .zero)
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        blurView.contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        blurView.leftAnchor.constraint(equalTo: separator.leftAnchor, constant: 0).isActive = true
        blurView.rightAnchor.constraint(equalTo: separator.rightAnchor, constant: 0).isActive = true
        blurView.bottomAnchor.constraint(equalTo: separator.bottomAnchor, constant: 0).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    /// Show blur effect of top bar
    func showBlur() {
        guard blurView.isHidden else { return }
        blurView.isHidden = false
        blurView.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            self.blurView.alpha = 1.0
        }
    }
    
    /// Hide blur effect of top bar
    func hideBlur() {
        guard !blurView.isHidden, !isAnimatingHideTopBar else { return }
        isAnimatingHideTopBar = true
        UIView.animate(withDuration: 0.2) {
            self.blurView.alpha = 0.0
        } completion: { success in
            self.blurView.isHidden = success
            self.isAnimatingHideTopBar = false
        }
    }
}
