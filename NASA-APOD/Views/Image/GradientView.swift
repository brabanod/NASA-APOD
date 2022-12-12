//
//  GradientView.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 29.11.22.
//

import UIKit

class GradientView: UIView {
    
    // MARK: Model
    
    struct GradientConfiguration {
        var startColor: CGColor
        var endColor: CGColor
        var startPosition: CGPoint
        var endPosition: CGPoint
        
        static let `default` = Self.blackClearDown
        static let blackClearDown = GradientConfiguration(
            startColor: UIColor.black.withAlphaComponent(0.8).cgColor,
            endColor: UIColor.clear.cgColor,
            startPosition: CGPoint(x: 0, y: 0.1),
            endPosition: CGPoint(x: 0, y: 1.0))
        static let blackClearUp = GradientConfiguration(
            startColor: UIColor.black.withAlphaComponent(0.8).cgColor,
            endColor: UIColor.clear.cgColor,
            startPosition: CGPoint(x: 0, y: 0.9),
            endPosition: CGPoint(x: 0, y: 0.0))
    }

    let gradientLayer = CAGradientLayer()
    
    private let configuration: GradientConfiguration
    
    
    // MARK: -
    
    override init(frame: CGRect) {
        self.configuration = GradientConfiguration.default
        super.init(frame: frame)
        setup()
    }
    
    init(configuration: GradientConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.configuration = GradientConfiguration.default
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        // Add gradient layer
        self.layer.addSublayer(gradientLayer)
        gradientLayer.colors = [configuration.startColor, configuration.endColor]
        gradientLayer.startPoint = configuration.startPosition
        gradientLayer.endPoint = configuration.endPosition
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Set gradient size
        gradientLayer.frame = self.bounds
    }
}
