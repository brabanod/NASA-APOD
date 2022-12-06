//
//  UIWindow+Extension.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 06.12.22.
//

import UIKit

extension UIWindow {

    /// The topmost presented view controller of the window.
    var presentedViewController: UIViewController? {
        guard var topController = self.rootViewController else { return nil }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}
