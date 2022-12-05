//
//  Configuration.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 29.11.22.
//

import Foundation

struct Configuration {
    /// The amount of APODs to be loaded and cached on app start.
    static let initialCacheLoadAmount: Int = 50
    
    /// Specifies, wheter infinite scrolling is enabled
    static let infiniteScroll: Bool = false
    
    /// The maximum number of APODs to load.
    static let maximumAPODAmount: Int = 50
}
