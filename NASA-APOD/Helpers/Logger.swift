//
//  Logger.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 24.11.22.
//

import Foundation
import OSLog

struct Log {
    static let `default` = Logger(OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.pascalbraband.NASA-APOD", category: "default"))
    
    static func withCategory(_ category: String) -> Logger {
        return Logger(OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.pascalbraband.NASA-APOD", category: "default"))
    }
}
