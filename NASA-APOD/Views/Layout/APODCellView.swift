//
//  APODCellView.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 25.11.22.
//

import UIKit

class APODCellView: UICollectionViewCell {
    
    // MARK: Views
    
    private var imageView: LoadableImageView!
    private var labelProtectionView: UIView!
    private var titleLabel: UILabel!
    private var accessoryLabel: UILabel!
    
    
    // MARK: Model
    
    
    // MARK: -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Make rounded corners
        self.clipsToBounds = true
        self.layer.cornerRadius = 15.0
        
        // Add the loadable image view
        imageView = LoadableImageView(frame: .zero)
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        // Add label protection view
        labelProtectionView = UIView(frame: .zero)
        self.addSubview(labelProtectionView)
        labelProtectionView.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: labelProtectionView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: labelProtectionView.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: labelProtectionView.bottomAnchor).isActive = true
        labelProtectionView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6).isActive = true
        
        // Add the title label
        titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 0
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -15.0).isActive = true
        self.rightAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 15.0).isActive = true
        self.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15.0).isActive = true
        
        let title1Font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.font = UIFont(
            descriptor: title1Font.fontDescriptor.withSymbolicTraits(.traitBold)!,
            size: title1Font.pointSize)
        titleLabel.textColor = .white
        
        // Add the accessory label
        accessoryLabel = UILabel(frame: .zero)
        accessoryLabel.numberOfLines = 0
        self.addSubview(accessoryLabel)
        accessoryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: accessoryLabel.leftAnchor, constant: -15.0).isActive = true
        self.rightAnchor.constraint(equalTo: accessoryLabel.rightAnchor, constant: 15.0).isActive = true
        self.topAnchor.constraint(equalTo: accessoryLabel.topAnchor, constant: -15.0).isActive = true
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: accessoryLabel.bottomAnchor, constant: 10).isActive = true
        
        accessoryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        accessoryLabel.textColor = .systemGray5
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Setup gradient for label protection view
        let gradient = CAGradientLayer()
        gradient.frame = labelProtectionView.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.9)
        gradient.endPoint = CGPoint(x: 0, y: 0.0)
        labelProtectionView.layer.addSublayer(gradient)
    }
    
    @MainActor func setTitle(_ title: String?) async {
        UIView.transition(with: titleLabel, duration: 0.8, options: .transitionCrossDissolve) {
            self.titleLabel.text = title
        }
    }
    
    @MainActor func setImage(_ image: UIImage?) async {
        UIView.transition(with: titleLabel, duration: 0.8, options: .transitionCrossDissolve) {
            self.imageView.image = image
        }
    }
    
    @MainActor func setAccessoryText(_ text: String?) async {
        UIView.transition(with: titleLabel, duration: 0.8, options: .transitionCrossDissolve) {
            self.accessoryLabel.text = text
        }
    }
}
