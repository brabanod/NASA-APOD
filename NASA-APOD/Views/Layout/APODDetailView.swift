//
//  APODDetailView.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 05.12.22.
//

import UIKit

class APODDetailView: UIView {

    // MARK: Views
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    var topBar: UIVisualEffectView!
    var topBarSeparator: UIView!
    var dismissButton: UIButton!
    
    var imageView: LoadableImageView!

    var detailsContainer: UIView!
    var detailsKeysContainer: UIStackView!
    var detailsValuesContainer: UIStackView!
    
    var titleKeyLabel: UILabel!
    var titleValueLabel: UILabel!
    var copyrightKeyLabel: UILabel!
    var copyrightValueLabel: UILabel!
    var dateKeyLabel: UILabel!
    var dateValueLabel: UILabel!
    
    var separatorView: UIView!
    
    var explanationLabel: UILabel!
    
    /// Distribution between key and value stack views.
    private let keyValueDistribution: CGFloat = 1/4
    
    /// Defines the percentage of the screen, that the image takes up.
    private let relativeImageHeight: CGFloat = 0.4
    
    
    // MARK: Model
    
    /// APOD cache which will be used to load data.
    var apodCache: APODCache? = nil
    
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
    
    var delegate: APODDetailViewDelegate?
    
    var isAnimatingHideTopBar = false
    
    
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
        setupLayout()
    }
    
    private func setupLayout() {
        // Setup scroll view
        scrollView = UIScrollView(frame: .zero)
        scrollView.delegate = self
        self.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        // Setup content view for scroll view
        contentView = UIView(frame: .zero)
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        let bottomC = scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        
        scrollView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        let alignY = scrollView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        
        bottomC.priority = UILayoutPriority(250)
        alignY.priority = UILayoutPriority(250)
        bottomC.isActive = true
        alignY.isActive = true
        
        // Setup image view
        imageView = LoadableImageView(frame: .zero)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: relativeImageHeight).isActive = true

        // Setup details container
        detailsContainer = UIView(frame: .zero)
        contentView.addSubview(detailsContainer)
        detailsContainer.translatesAutoresizingMaskIntoConstraints = false
        imageView.bottomAnchor.constraint(equalTo: detailsContainer.topAnchor, constant: -30).isActive = true
        contentView.leftAnchor.constraint(equalTo: detailsContainer.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: detailsContainer.rightAnchor).isActive = true
        detailsContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true

        // Setup detail keys container (left stack view)
        detailsKeysContainer = UIStackView(frame: .zero)
        detailsKeysContainer.axis = .vertical
        detailsKeysContainer.distribution = .equalCentering
        
        detailsContainer.addSubview(detailsKeysContainer)
        detailsKeysContainer.translatesAutoresizingMaskIntoConstraints = false
        detailsKeysContainer.leftAnchor.constraint(equalTo: detailsContainer.leftAnchor, constant: 20).isActive = true
        detailsKeysContainer.topAnchor.constraint(equalTo: detailsContainer.topAnchor).isActive = true
        detailsKeysContainer.bottomAnchor.constraint(equalTo: detailsContainer.bottomAnchor).isActive = true
        detailsKeysContainer.widthAnchor.constraint(equalTo: detailsContainer.widthAnchor, multiplier: keyValueDistribution).isActive = true

        // Setup detail values container (right stack view)
        detailsValuesContainer = UIStackView(frame: .zero)
        detailsValuesContainer.axis = .vertical
        detailsValuesContainer.distribution = .equalCentering
        
        detailsContainer.addSubview(detailsValuesContainer)
        detailsValuesContainer.translatesAutoresizingMaskIntoConstraints = false
        detailsValuesContainer.leftAnchor.constraint(equalTo: detailsKeysContainer.rightAnchor).isActive = true
        detailsContainer.rightAnchor.constraint(equalTo: detailsValuesContainer.rightAnchor, constant: 20).isActive = true
        detailsContainer.topAnchor.constraint(equalTo: detailsValuesContainer.topAnchor).isActive = true
        detailsContainer.bottomAnchor.constraint(equalTo: detailsValuesContainer.bottomAnchor).isActive = true

        // Fill keys stack
        let keysFontBase = UIFont.preferredFont(forTextStyle: .body)
        let keysFont = UIFont(
            descriptor: keysFontBase.fontDescriptor.withSymbolicTraits(.traitBold)!,
            size: keysFontBase.pointSize)
        
        titleKeyLabel = UILabel(frame: .zero)
        titleKeyLabel.textColor = .white
        titleKeyLabel.numberOfLines = 0
        titleKeyLabel.font = keysFont
        titleKeyLabel.text = String(localized: "Title", table: "Detail", comment: "List: Description for the APODs title attribute.")
        detailsKeysContainer.addArrangedSubview(titleKeyLabel)
        titleKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        titleKeyLabel.widthAnchor.constraint(equalTo: detailsKeysContainer.widthAnchor).isActive = true

        copyrightKeyLabel = UILabel(frame: .zero)
        copyrightKeyLabel.textColor = .white
        copyrightKeyLabel.numberOfLines = 0
        copyrightKeyLabel.font = keysFont
        copyrightKeyLabel.text = String(localized: "Source", table: "Detail", comment: "List: Description for the APODs copyright attribute.")
        detailsKeysContainer.addArrangedSubview(copyrightKeyLabel)
        copyrightKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightKeyLabel.widthAnchor.constraint(equalTo: detailsKeysContainer.widthAnchor).isActive = true

        dateKeyLabel = UILabel(frame: .zero)
        dateKeyLabel.textColor = .white
        dateKeyLabel.numberOfLines = 0
        dateKeyLabel.font = keysFont
        dateKeyLabel.text = String(localized: "Date", table: "Detail", comment: "List: Description for the APODs date attribute.")
        detailsKeysContainer.addArrangedSubview(dateKeyLabel)
        dateKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        dateKeyLabel.widthAnchor.constraint(equalTo: detailsKeysContainer.widthAnchor).isActive = true

        // Fill values stack
        titleValueLabel = UILabel(frame: .zero)
        titleValueLabel.textColor = .white
        titleValueLabel.numberOfLines = 0
        detailsValuesContainer.addArrangedSubview(titleValueLabel)
        titleValueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleValueLabel.widthAnchor.constraint(equalTo: detailsValuesContainer.widthAnchor).isActive = true
        titleValueLabel.heightAnchor.constraint(equalTo: titleKeyLabel.heightAnchor).isActive = true

        copyrightValueLabel = UILabel(frame: .zero)
        copyrightValueLabel.textColor = .white
        copyrightValueLabel.numberOfLines = 0
        detailsValuesContainer.addArrangedSubview(copyrightValueLabel)
        copyrightValueLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightValueLabel.widthAnchor.constraint(equalTo: detailsValuesContainer.widthAnchor).isActive = true
        copyrightValueLabel.heightAnchor.constraint(equalTo: copyrightKeyLabel.heightAnchor).isActive = true

        dateValueLabel = UILabel(frame: .zero)
        dateValueLabel.textColor = .white
        dateValueLabel.numberOfLines = 0
        detailsValuesContainer.addArrangedSubview(dateValueLabel)
        dateValueLabel.translatesAutoresizingMaskIntoConstraints = false
        dateValueLabel.widthAnchor.constraint(equalTo: detailsValuesContainer.widthAnchor).isActive = true
        dateValueLabel.heightAnchor.constraint(equalTo: dateKeyLabel.heightAnchor).isActive = true
        
        // Add separator
        separatorView = UIView(frame: .zero)
        separatorView.backgroundColor = .systemGray
        contentView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: separatorView.leftAnchor, constant: -20).isActive = true
        contentView.rightAnchor.constraint(equalTo: separatorView.rightAnchor, constant: 20).isActive = true
        separatorView.topAnchor.constraint(equalTo: detailsContainer.bottomAnchor, constant: 20).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // Add explanation label
        explanationLabel = UILabel(frame: .zero)
        explanationLabel.numberOfLines = 0
        explanationLabel.textColor = .white
        
        contentView.addSubview(explanationLabel)
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.topAnchor.constraint(equalTo: detailsContainer.bottomAnchor, constant: 40).isActive = true
        contentView.leftAnchor.constraint(equalTo: explanationLabel.leftAnchor, constant: -20).isActive = true
        contentView.rightAnchor.constraint(equalTo: explanationLabel.rightAnchor, constant: 20).isActive = true
        contentView.bottomAnchor.constraint(equalTo: explanationLabel.bottomAnchor, constant: 20).isActive = true
        
        // Setup top bar
        topBar = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.addSubview(topBar)
        topBar.isHidden = true
        topBar.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: topBar.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: topBar.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: topBar.topAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 60).isActive = true

        // Add top bar separator
        topBarSeparator = UIView(frame: .zero)
        topBarSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        topBar.contentView.addSubview(topBarSeparator)
        topBarSeparator.translatesAutoresizingMaskIntoConstraints = false
        topBar.leftAnchor.constraint(equalTo: topBarSeparator.leftAnchor, constant: 0).isActive = true
        topBar.rightAnchor.constraint(equalTo: topBarSeparator.rightAnchor, constant: 0).isActive = true
        topBar.bottomAnchor.constraint(equalTo: topBarSeparator.bottomAnchor, constant: 0).isActive = true
        topBarSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add dismiss button
        dismissButton = UIButton(type: .close)
        dismissButton.overrideUserInterfaceStyle = .dark
        topBar.contentView.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        topBar.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: dismissButton.rightAnchor, constant: 20).isActive = true
        
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    func showAPOD(for date: Date) {
        Task {
            do {
                // Load APOD metadata first
                self.apod = try await apodCache?.apod(for: date)
                
                // Load APOD full size image
                self.apod = try await apodCache?.apod(for: date, withImage: true)
            } catch {
                // TODO: Show alert
                print("Failed to load APOD.")
                return
            }
        }
    }
    
    @MainActor private func showAPOD(_ apod: APOD) async {
        // Set labels
        titleValueLabel.text = apod.title
        copyrightValueLabel.text = apod.copyright
        dateValueLabel.text = apod.date.formatted(date: .numeric, time: .omitted)
        explanationLabel.text = apod.explanation

        // Set image. If the image is still nil, then try to first set the thumbnail.
        if await apod.image == nil {
            imageView.image = await apod.thumbnail
        } else {
            imageView.image = await apod.image
        }
    }
    
    @objc func dismiss() {
        delegate?.dismiss(self)
    }
}


extension APODDetailView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only show top bar if scrolled past 5 pixels
        if scrollView.contentOffset.y >= 5 {
            // Show top bar
            guard topBar.isHidden else { return }
            topBar.isHidden = false
            topBar.alpha = 0.0
            UIView.animate(withDuration: 0.2) {
                self.topBar.alpha = 1.0
            }
        } else {
            // Hide top bar
            guard !topBar.isHidden, !isAnimatingHideTopBar else { return }
            isAnimatingHideTopBar = true
            UIView.animate(withDuration: 0.2) {
                self.topBar.alpha = 0.0
            } completion: { success in
                self.topBar.isHidden = success
                self.isAnimatingHideTopBar = false
            }
        }
    }
}


protocol APODDetailViewDelegate {
    func dismiss(_ sender: AnyObject)
}
