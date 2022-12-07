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
    
    var topBar: BlurBar!
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
    var videoKeyLabel: UILabel!
    var videoWatchButton: UIButton!
    
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
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
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
        imageView.fadeEnabled = false
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

        // Setup detail keys container (left stack view)
        detailsKeysContainer = UIStackView(frame: .zero)
        detailsKeysContainer.axis = .vertical
        detailsKeysContainer.distribution = .equalCentering
        detailsKeysContainer.alignment = .leading
        detailsKeysContainer.spacing = 10
        
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
        detailsValuesContainer.alignment = .leading
        detailsValuesContainer.spacing = 10
        
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

        copyrightKeyLabel = UILabel(frame: .zero)
        copyrightKeyLabel.textColor = .white
        copyrightKeyLabel.numberOfLines = 0
        copyrightKeyLabel.font = keysFont
        copyrightKeyLabel.text = String(localized: "Source", table: "Detail", comment: "List: Description for the APODs copyright attribute.")
        detailsKeysContainer.addArrangedSubview(copyrightKeyLabel)
        copyrightKeyLabel.translatesAutoresizingMaskIntoConstraints = false

        dateKeyLabel = UILabel(frame: .zero)
        dateKeyLabel.textColor = .white
        dateKeyLabel.numberOfLines = 0
        dateKeyLabel.font = keysFont
        dateKeyLabel.text = String(localized: "Date", table: "Detail", comment: "List: Description for the APODs date attribute.")
        detailsKeysContainer.addArrangedSubview(dateKeyLabel)
        dateKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        videoKeyLabel = UILabel(frame: .zero)
        videoKeyLabel.textColor = .white
        videoKeyLabel.numberOfLines = 0
        videoKeyLabel.font = keysFont
        videoKeyLabel.text = String(localized: "Video", table: "Detail", comment: "List: Description for the APODs video attribute.")
        detailsKeysContainer.addArrangedSubview(videoKeyLabel)
        videoKeyLabel.translatesAutoresizingMaskIntoConstraints = false

        // Fill values stack
        titleValueLabel = UILabel(frame: .zero)
        titleValueLabel.textColor = .white
        titleValueLabel.numberOfLines = 0
        detailsValuesContainer.addArrangedSubview(titleValueLabel)
        titleValueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleValueLabel.heightAnchor.constraint(equalTo: titleKeyLabel.heightAnchor).isActive = true

        copyrightValueLabel = UILabel(frame: .zero)
        copyrightValueLabel.textColor = .white
        copyrightValueLabel.numberOfLines = 0
        detailsValuesContainer.addArrangedSubview(copyrightValueLabel)
        copyrightValueLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightValueLabel.heightAnchor.constraint(equalTo: copyrightKeyLabel.heightAnchor).isActive = true

        dateValueLabel = UILabel(frame: .zero)
        dateValueLabel.textColor = .white
        dateValueLabel.numberOfLines = 0
        detailsValuesContainer.addArrangedSubview(dateValueLabel)
        dateValueLabel.translatesAutoresizingMaskIntoConstraints = false
        dateValueLabel.heightAnchor.constraint(equalTo: dateKeyLabel.heightAnchor).isActive = true
        
        videoWatchButton = UIButton(type: .system)
        videoWatchButton.setTitle(String(localized: "Watch", table: "Detail", comment: "List: Title for the watch APOD's video button."), for: .normal)
        videoWatchButton.addTarget(self, action: #selector(watchVideo), for: .touchUpInside)
        detailsValuesContainer.addArrangedSubview(videoWatchButton)
        videoWatchButton.translatesAutoresizingMaskIntoConstraints = false
        videoWatchButton.heightAnchor.constraint(equalTo: videoKeyLabel.heightAnchor).isActive = true
        
        // Hide video key and button for now
        hideVideoAttribute()
        
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
        contentView.bottomAnchor.constraint(equalTo: explanationLabel.bottomAnchor, constant: 40).isActive = true
        
        // Setup top bar
        topBar = BlurBar(frame: .zero)
        self.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: topBar.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: topBar.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: topBar.topAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Add dismiss button
        dismissButton = UIButton(type: .close)
        dismissButton.overrideUserInterfaceStyle = .dark
        topBar.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        topBar.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: dismissButton.rightAnchor, constant: 20).isActive = true
        
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    
    // MARK: Display APOD
    
    /// This function is intended to be called from the outside of this view. Call it with a date, to display the corresponding APOD. The APOD for the date will be loaded from the cache.
    /// - Parameters:
    ///     - date: The date for which to show the APOD.
    func showAPOD(for date: Date) {
        Task {
            do {
                // Load APOD metadata first
                self.apod = try await apodCache?.apod(for: date)
                
                // Load APOD full size image
                self.apod = try await apodCache?.apod(for: date, withImage: true)
            } catch {
                Log.default.log("Failed to load APOD. Error:\n\(error)")
                AlertComposer.showErrorAlert(type: .errorGeneral, in: self.window?.presentedViewController)
            }
        }
    }
    
    /// Updated the UI with the data of the given APOD.
    ///
    /// - Parameters:
    ///     - apod: The APOD to be displayed in the UI.
    @MainActor private func showAPOD(_ apod: APOD) async {
        // Set labels
        titleValueLabel.text = apod.title
        copyrightValueLabel.text = apod.copyright ?? String(localized: "Public Domain", comment: "APOD: Public domain description for copyright.")
        dateValueLabel.text = apod.date.formatted(.dateTime.year(.extended()).month(.twoDigits).day(.twoDigits))
        explanationLabel.text = apod.explanation
        
        // Display video attribute if media type is video
        if apod.mediaType == .video {
            showVideoAttribute()
        } else {
            hideVideoAttribute()
        }
        
        // Set image. If the image is still nil, then try to first set the thumbnail.
        if await apod.image == nil {
            imageView.image = await apod.thumbnail
        }
        
        // If thumbnail is also nil (i.e. imageView.image is nil), directly set image
        if imageView.image == nil {
            imageView.image = await apod.image
        }
    }
    
    
    // MARK: Video
    
    @objc func watchVideo() {
        // When apod type is video, the video URL is stored in thumbnailURL
        guard let url = apod?.thumbnailURL else {
            Log.default.log("Failed to open video. URL was nil.")
            AlertComposer.showErrorAlert(type: .errorGeneral, in: self.window?.presentedViewController)
            return
        }
        UIApplication.shared.open(url)
    }
    
    /// Hides the video attributes, i. e. the label and button to indicate watching a video.
    func hideVideoAttribute() {
        videoKeyLabel.isHidden = true
        videoWatchButton.isHidden = true
    }
    
    /// Shows the video attributes, i. e. the label and button to indicate watching a video.
    func showVideoAttribute() {
        videoKeyLabel.isHidden = false
        videoWatchButton.isHidden = false
    }
    
    
    // MARK: Other
    
    /// Call this function, when the detail view wants itself to be dismissed.
    @objc func dismiss() {
        delegate?.dismiss(self)
    }
}


extension APODDetailView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only show top bar if scrolled past 10 pixels
        if scrollView.contentOffset.y >= 10 {
            topBar.showBlur()
        } else {
            topBar.hideBlur()
        }
    }
}


protocol APODDetailViewDelegate {
    func dismiss(_ sender: AnyObject)
}
