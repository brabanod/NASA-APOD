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
    
    var imageView: LoadableImageView!
    var labelProtectionView: UIView!
    var titleLabel: UILabel!
    var copyrightLabel: UILabel!
    
    
    // MARK: Model
    
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
        self.topAnchor.constraint(equalTo: labelProtectionView.topAnchor).isActive = true
        labelProtectionView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25).isActive = true
        
        // Add the title label
        titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 0
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
        
        // Add the copyright label
        copyrightLabel = UILabel(frame: .zero)
        copyrightLabel.numberOfLines = 0
        self.addSubview(copyrightLabel)
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        self.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: copyrightLabel.leftAnchor, constant: -20.0).isActive = true
        self.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: copyrightLabel.rightAnchor, constant: 20.0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: copyrightLabel.topAnchor, constant: -10.0).isActive = true
        
        copyrightLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        copyrightLabel.textColor = .white
        
        // Load APOD for today
        loadAPODData()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Setup gradient for label protection view
        let gradient = CAGradientLayer()
        gradient.frame = labelProtectionView.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.1)
        gradient.endPoint = CGPoint(x: 0, y: 1.0)
        labelProtectionView.layer.addSublayer(gradient)
    }
    
    /// Loads the APOD for today.
    ///
    /// **Warning:** UI is implicitly refreshed by setting the APOD object to the corresponding instance property. This is done to do intermediate update of the UI (first text, then image).
    func loadAPODData() {
        Task {
            do {
                // Load APOD
                try apodCache?.apod(for: Date(), completion: { apod in
                    self.apod = apod
                }, withImage: true, imageCompletion: { apod in
                    self.apod = apod
                })
            } catch {
                Log.default.log("Failed to load APOD. Error:\n\(error)")
                // Show alert, that loading APOD failed
                let alert = UIAlertController(
                    title: String(localized: "Stars are not aligned", table: "Error", comment: "Alert: Title for default error messages."),
                    message: String(localized: "Could not load the Astronomy Picture of the day from NASA.", table: "Error", comment: "Alert: Message for network errors."), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert: Close alert button title."), style: .default, handler: nil))
                self.window?.rootViewController?.present(alert, animated: true)
            }
        }
    }
    
    /// Reloads the UI to display the given APOD.
    @MainActor func showAPOD(_ apod: APOD) async {
        // Set title label
        let apodTitle = await apod.title
        UIView.transition(with: titleLabel, duration: 0.8, options: .transitionCrossDissolve) {
            self.titleLabel.text = apodTitle
        }
        
        // Set copyright label
        let apodCopyright = await apod.copyright
        UIView.transition(with: copyrightLabel, duration: 0.8, options: .transitionCrossDissolve) {
            self.copyrightLabel.text = "\(String(localized: "Today", comment: "APOD: Description of the today date.")) | © \(apodCopyright ?? String(localized: "Public Domain", comment: "APOD: Public domain description for copyright."))"
        }
        
        // Set image. Try image first and then thumbnail.
        let apodThumbnail = await apod.thumbnail
        let apodImage = await apod.image
        imageView.image = apodImage != nil ? apodImage : apodThumbnail
    }
}
