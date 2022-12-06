//
//  AlertComposer.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 06.12.22.
//

import UIKit

class AlertComposer {
    
    /// Shows a basic error alert with the given title an message inside a view controller.
    /// This alert has a single 'OK'-button action, to dismiss the alert.
    ///
    /// If called from a `UIView`, you may want to use `self.window?.rootViewController` as a view controller to present the alert in.
    ///
    /// - Parameters:
    ///     - title: The title of the alert.
    ///     - message: The message of the alert.
    ///     - viewController: The view controller, in which the alert should be displayed.
    static func showErrorAlert(title: String, message: String, in viewController: UIViewController?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "Alert: Close alert button title."), style: .default, handler: nil))
        viewController?.present(alert, animated: true, completion: nil)
    }
}
