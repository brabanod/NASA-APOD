//
//  HomeViewController.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 22.11.22.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: Views
    
    var apodHighlightView: APODHighlightView!
    
    
    // MARK: Model
    
    var apodAPI: APODAPI?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.07, alpha: 1.0)
        
        // Add a loadable view
        apodHighlightView = APODHighlightView(frame: .zero, apodAPI: apodAPI)
        self.view.addSubview(apodHighlightView)
        apodHighlightView.translatesAutoresizingMaskIntoConstraints = false
        self.view.leftAnchor.constraint(equalTo: apodHighlightView.leftAnchor).isActive = true
        self.view.rightAnchor.constraint(equalTo: apodHighlightView.rightAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: apodHighlightView.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: apodHighlightView.bottomAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Show alert if API could not be created
        if apodAPI == nil {
            let alert = UIAlertController(
                title: String(localized: "Stars are not aligned", table: "Error", comment: "Alert: Title for default error messages."),
                message: String(localized: "Could not load the Astronomy Picture of the day from NASA.", table: "Error", comment: "Alert: Message for network errors."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert: Close alert button title."), style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }


}

