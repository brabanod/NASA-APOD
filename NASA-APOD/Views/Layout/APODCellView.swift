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
    
    var id: APOD.ID? = nil
    
    
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
        labelProtectionView = GradientView(configuration: .blackClearUp)
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
    
    @MainActor func setTitle(_ title: String?) {
        if titleLabel.text == nil || titleLabel.text == "" {
            titleLabel.alpha = 0
            titleLabel.text = title
            UIView.animate(withDuration: 0.7) {
                self.titleLabel.alpha = 1.0
            }
        } else {
            titleLabel.text = title
        }
    }
    
    @MainActor func setImage(_ image: UIImage?) {
        UIView.transition(with: titleLabel, duration: 0.9, options: .transitionCrossDissolve) {
            self.imageView.image = image
        }
    }
    
    @MainActor func setAccessoryText(_ text: String?) {
        if accessoryLabel.text == nil || accessoryLabel.text == "" {
            accessoryLabel.alpha = 0
            accessoryLabel.text = text
            UIView.animate(withDuration: 0.5) {
                self.accessoryLabel.alpha = 1.0
            }
        } else {
            accessoryLabel.text = text
        }
    }
}
