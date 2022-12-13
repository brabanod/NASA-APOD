//
//  DetailViewController.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 05.12.22.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: Views
    
    var detailView: APODDetailView!
    
    
    // MARK: Model
    
    /// Stores the date for which the APOD should be displayed
    var date: Date? = nil
    
    var apodCache: APODCache?
    
    
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Configuration.backgroundColor

        // Setup detail view
        detailView = APODDetailView(cache: apodCache)
        detailView.delegate = self
        detailView.accessibilityIdentifier = "DetailView"
        self.view.addSubview(detailView)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        self.view.leftAnchor.constraint(equalTo: detailView.leftAnchor).isActive = true
        self.view.rightAnchor.constraint(equalTo: detailView.rightAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: detailView.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: detailView.bottomAnchor).isActive = true
        
        // Show requested APOD in detail view
        if date != nil {
            detailView.showAPOD(for: date!)
        }
    }
}


extension DetailViewController: APODDetailViewDelegate {
    
    func dismiss(_ sender: AnyObject) {
        performSegue(withIdentifier: "UnwindDetailSegueIdentifier", sender: sender)
    }
}
