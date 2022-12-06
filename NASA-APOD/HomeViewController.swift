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
    var apodListView: APODListView!
    var apodDetailView: APODDetailView!
    
    
    // MARK: Model
    
    var apodCache: APODCache?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Temporarily stores the date for the APOD to be displayed in the detail view.
    private var dateForAPOD: Date? = nil
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Configuration.backgroundColor
        
        // Add a highlight view
//        apodHighlightView = APODHighlightView(cache: apodCache)
//        self.view.addSubview(apodHighlightView)
//        apodHighlightView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.leftAnchor.constraint(equalTo: apodHighlightView.leftAnchor).isActive = true
//        self.view.rightAnchor.constraint(equalTo: apodHighlightView.rightAnchor).isActive = true
//        self.view.topAnchor.constraint(equalTo: apodHighlightView.topAnchor).isActive = true
//        self.view.bottomAnchor.constraint(equalTo: apodHighlightView.bottomAnchor).isActive = true
        
        // Add a list view
        apodListView = APODListView(cache: apodCache)
        apodListView.delegate = self
        self.view.addSubview(apodListView)
        apodListView.translatesAutoresizingMaskIntoConstraints = false
        self.view.leftAnchor.constraint(equalTo: apodListView.leftAnchor).isActive = true
        self.view.rightAnchor.constraint(equalTo: apodListView.rightAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: apodListView.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: apodListView.bottomAnchor).isActive = true
        
        // Add detail view
//        apodDetailView = APODDetailView(cache: apodCache)
//        self.view.addSubview(apodDetailView)
//        apodDetailView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.leftAnchor.constraint(equalTo: apodDetailView.leftAnchor).isActive = true
//        self.view.rightAnchor.constraint(equalTo: apodDetailView.rightAnchor).isActive = true
//        self.view.topAnchor.constraint(equalTo: apodDetailView.topAnchor).isActive = true
//        self.view.bottomAnchor.constraint(equalTo: apodDetailView.bottomAnchor).isActive = true
//
//        apodDetailView.showAPOD(for: DateUtils.today()!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Show alert if API could not be created
        if apodCache == nil {
            AlertComposer.showErrorAlert(
                title: String(localized: "Stars are not aligned", table: "Error", comment: "Alert: Title for default error messages."),
                message: String(localized: "Could not load the Astronomy Picture of the day from NASA.", table: "Error", comment: "Alert: Message for network errors."),
                in: self)
        }
    }
    
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? DetailViewController else { return }
        detailVC.apodCache = apodCache
        detailVC.date = dateForAPOD
    }

    @IBAction func unwind(for unwindSegue: UIStoryboardSegue) {
        dateForAPOD = nil
    }
}


extension HomeViewController: APODListViewDelegate {
    func showAPODDetail(for date: Date, sender: AnyObject) {
        dateForAPOD = date
        performSegue(withIdentifier: "ShowDetailSegueIdentifier", sender: sender)
    }
}
