//
//  AlertComposer.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 06.12.22.
//

import UIKit

class AlertComposer {
    
    enum AlertType {
        case errorGeneral, errorNetwork
    }
    
    /// Indicates whether an alert is already displayed.
    ///
    /// **Important:** Always set this to true, when presenting an alert, and reset it when dismissing.
    private static var isAlertPresented: Bool = false
    
    
    // MARK: Composition
    
    /// Always use this function to create and present `UIAlertController`'s, as it manages the `isAlertPresented` state.
    private static func showAlert(title: String, message: String, actions: [UIAlertAction], in viewController: UIViewController?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add all actions to alert
        actions.forEach { action in
            alert.addAction(action)
        }
        
        // Present alert (only if no other alert is already displayed)
        guard !isAlertPresented else { return }
        viewController?.present(alert, animated: true, completion: nil)
        isAlertPresented = true
    }

    /// Always use this function to create `UIAlertAction`'s, as it manages the `isAlertPresented` state.
    private static func createAction(title: String, style: UIAlertAction.Style, handler: (@escaping (UIAlertAction) -> ()?)) -> UIAlertAction {
        return UIAlertAction(
            title: title,
            style: style,
            handler: { action in
                handler(action)
                isAlertPresented = false
            })
    }
    
    
    // MARK: Generic
    
    /// Shows a basic error alert with the given title and message inside a view controller.
    /// This alert has a single 'OK'-button action, to dismiss the alert.
    ///
    /// If called from a `UIView`, you may want to use `self.window?.presentedViewController` as a view controller to present the alert in.
    ///
    /// - Parameters:
    ///     - title: The title of the alert.
    ///     - message: The message of the alert.
    ///     - viewController: The view controller, in which the alert should be displayed.
    static func showErrorAlert(title: String, message: String, in viewController: UIViewController?) {
        showAlert(
            title: title,
            message: message,
            actions: [
                createAction(title: String(localized: "OK", comment: "Alert: Close alert button title."), style: .default, handler: { _ in isAlertPresented = false}),
            ],
            in: viewController)
    }
    
    
    // MARK: Predefined
    
    /// Shows a predefined error alert of a given type.
    ///
    /// If called from a `UIView`, you may want to use `self.window?.presentedViewController` as a view controller to present the alert in.
    ///
    /// - Parameters:
    ///     - viewController: The view controller, in which the alert should be displayed.
    static func showErrorAlert(type: AlertType, in viewController: UIViewController?) {
        switch type {
        case .errorGeneral:
            showGeneralErrorAlert(in: viewController)
        case .errorNetwork:
            showNetworkErrorAlert(in: viewController)
        }
    }
    
    /// Predefined alert for *general* errors.
    ///
    /// - Parameters:
    ///     - viewController: The view controller, in which the alert should be displayed.
    private static func showGeneralErrorAlert(in viewController: UIViewController?) {
        AlertComposer.showErrorAlert(
            title: String(localized: "Stars are not aligned", table: "Error", comment: "Alert: Title for default error messages."),
            message: String(localized: "Something went wrong. Please try again or contact support if the problem persists.", table: "Error", comment: "Alert: Message for general errors."),
            in: viewController)
    }
    
    /// Predefined alert for *general* errors.
    ///
    /// - Parameters:
    ///     - viewController: The view controller, in which the alert should be displayed.
    private static func showNetworkErrorAlert(in viewController: UIViewController?) {
        AlertComposer.showErrorAlert(
            title: String(localized: "Stars are not aligned", table: "Error", comment: "Alert: Title for default error messages."),
            message: String(localized: "Could not load the Astronomy Picture of the day from NASA.", table: "Error", comment: "Alert: Message for network errors."),
            in: viewController)
    }
}
