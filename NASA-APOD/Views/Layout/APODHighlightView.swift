//
//  APODHighlightView.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 23.11.22.
//

import UIKit
import OSLog

class APODHighlightView: UIView {
    
    // MARK: Views
    
    private var imageView: LoadableImageView!
    private var labelProtectionView: UIView!
    private var titleLabel: UILabel!
    private var accessoryLabel: UILabel!
    
    
    // MARK: Model
    
    var image: UIImage? {
        return imageView.image
    }
    var title: String? {
        return titleLabel.text
    }
    var accessoryText: String? {
        return accessoryLabel.text
    }
    
    /// APOD cache which will be used to load data. Will load data and refresh UI if it is set.
    var apodCache: APODCache? = nil {
        didSet {
            loadAPODData()
        }
    }
    
    /// The currently displayed APOD.
    private(set) var apod: APOD? {
        didSet {
            if self.apod != nil {
                Task {
                    await self.showAPOD(self.apod!)
                }
            }
        }
    }
    
    /// Indicates, whether the animation of the title label is running.
    private var isTitleAnimationRunning: Bool = false
    
    /// Indicates, whether the animation of the accessory label is running.
    private var isAccessoryAnimationRunning: Bool = false
    
    
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
        // Add the loadable image view
        imageView = LoadableImageView(frame: .zero)
        imageView.accessibilityIdentifier = "Image"
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        // Add label protection view
        labelProtectionView = GradientView(configuration: .blackClearDown)
        self.addSubview(labelProtectionView)
        labelProtectionView.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: labelProtectionView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: labelProtectionView.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: labelProtectionView.topAnchor).isActive = true
        labelProtectionView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25).isActive = true
        
        // Add the title label
        titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = "Title"
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -20.0).isActive = true
        self.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 20.0).isActive = true
        self.safeAreaLayoutGuide.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -30.0).isActive = true
        
        let title1Font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.font = UIFont(
            descriptor: title1Font.fontDescriptor.withSymbolicTraits(.traitBold)!,
            size: title1Font.pointSize)
        titleLabel.textColor = .white
        
        // Add the accessory label
        accessoryLabel = UILabel(frame: .zero)
        accessoryLabel.numberOfLines = 0
        accessoryLabel.accessibilityIdentifier = "Accessory"
        self.addSubview(accessoryLabel)
        accessoryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: accessoryLabel.leftAnchor, constant: -20.0).isActive = true
        self.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: accessoryLabel.rightAnchor, constant: 20.0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: accessoryLabel.topAnchor, constant: -10.0).isActive = true
        
        accessoryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        accessoryLabel.textColor = .white
        
        // Load APOD for today
        loadAPODData()
    }
    
    /// Loads the APOD for today.
    ///
    /// **Warning:** UI is implicitly refreshed by setting the APOD object to the corresponding instance property. This is done to do intermediate update of the UI (first text, then image).
    private func loadAPODData() {
        Task {
            do {
                // Incrementally load data for fast display
                let today = Date()
                
                // Load APOD without thumbnail first
                self.apod = try await apodCache?.apod(for: today)
                
                // Load APOD thumbnail
                self.apod = try await apodCache?.apod(for: today, withThumbnail: true)
                
                // Load APOD full size image
                self.apod = try await apodCache?.apod(for: today, withImage: true)
            } catch {
                Log.default.log("Failed to load APOD. Error:\n\(error)")
                AlertComposer.showErrorAlert(type: .errorNetwork, in: self.window?.presentedViewController)
            }
        }
    }
    
    /// Reloads the UI to display the given APOD.
    @MainActor private func showAPOD(_ apod: APOD) async {
        // Set title label
        let apodTitle = apod.title
        // Animate title label, only if not already animating
        if !isTitleAnimationRunning {
            isTitleAnimationRunning = true
            UIView.transition(with: titleLabel, duration: 0.8, options: .transitionCrossDissolve) {
                self.titleLabel.text = apodTitle
            } completion: { _ in
                self.isTitleAnimationRunning = false
            }
        }
        
        // Set accessory label
        let apodCopyright = apod.copyright
        if !isAccessoryAnimationRunning {
            // Animate accessory label, only if not already animating
            isAccessoryAnimationRunning = true
            UIView.transition(with: accessoryLabel, duration: 0.8, options: .transitionCrossDissolve) {
                self.accessoryLabel.text = "\(String(localized: "Today", comment: "APOD: Description of the today date.")) | © \(apodCopyright ?? String(localized: "Public Domain", comment: "APOD: Public domain description for copyright."))"
            } completion: { _ in
                self.isAccessoryAnimationRunning = false
            }
        }
        
        // Set image. Try image first and then thumbnail.
        let apodThumbnail = await apod.thumbnail
        let apodImage = await apod.image
        imageView.image = apodImage != nil ? apodImage : apodThumbnail
    }
}
