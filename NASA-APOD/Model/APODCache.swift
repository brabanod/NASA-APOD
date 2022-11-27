//
//  APODCache.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 26.11.22.
//

import Foundation
import Combine

// FIXME: Shoudl this be an actor?
class APODCache {
    
    // MARK: Model
    
    private var apodAPI: APODAPI
    
    /// Specifies how many APODs are loaded, when cache is initialized.
    private(set) var initialLoadAmount: Int
    
    /// Stores loaded APODs
    private var apods: [Date: APOD] = [:]
    
    private var initalLoadTask: Task<[APOD], Error>? = nil
    private var apodTasks: [Date: Task<APOD, Error>] = [:]
    private var thumbnailTasks: [Date: Task<APOD, Error>] = [:]
    private var imageTasks: [Date: Task<APOD, Error>] = [:]
    
    
    // MARK: -
    
    init(
        api apodAPI: APODAPI,
        initialLoadAmount: Int = 10,
        withThumbnails shouldLoadThumbnails: Bool = false,
        withImages shouldLoadImages: Bool = false)
    async throws {
        self.apodAPI = apodAPI
        self.initialLoadAmount = initialLoadAmount
        
        try await initialLoad(withThumbnails: shouldLoadThumbnails, withImages: shouldLoadImages)
    }
    
    func initialLoad(withThumbnails shouldLoadThumbnails: Bool, withImages shouldLoadImages: Bool) async throws {
        // Store retrieved APODs at their individual position in the cache
        for days in (1...self.initialLoadAmount) {
            // Get date, fail promise if date could not be retrieved
            guard let date = DateUtils.today(adding: -days)
            else {
                // Try next APOD
                continue
            }
            try await apod(for: date, completion: { _ in })
        }
    }
    
    func apod(
        for date: Date,
        completion: @escaping (APOD) -> (),
        withThumbnail shouldLoadThumbnail: Bool = false,
        thumbnailCompletion: ( (APOD) -> ())? = nil,
        withImage shouldLoadImage: Bool = false,
        imageCompletion: ( (APOD) -> ())? = nil)
    async throws {        
        // 1. Get APOD
        var apod: APOD!
        
        // APOD is in cache
        if apods[date] != nil {
            // Take it directly from cache
            apod = apods[date]
        }
        // APOD is not in cache
        else {
            // Create a load task if none is already running
            if apodTasks[date] == nil {
                apodTasks[date] = Task {
                    try await apodAPI.apodByDate(date)
                }
            }
            // Wait for the load task to finish and remove it thereafter
            apod = try await apodTasks[date]?.value
            apodTasks[date] = nil
        }
        
        // Store in cache and deliver APOD in completion
        apods[date] = apod
        completion(apod)
                    
        // 2. Get APOD thumbnail
        if shouldLoadThumbnail {
            // Create a load task if none is already running
            // If the thumbnail was already loaded, still create a new load task
            // This will call the APOD API and return the already loaded thumbnail from there, so no additional waiting time
            if thumbnailTasks[date] == nil {
                thumbnailTasks[date] = Task { [apod] in
                    let thumbnail = try await apodAPI.thumbnail(of: apod!)
                    var apodUpdate = apod!
                    apodUpdate.thumbnail = thumbnail
                    return apodUpdate
                }
            }
            // Wait for the load task to finish and remove it thereafter
            apod = try await thumbnailTasks[date]?.value
            thumbnailTasks[date] = nil
            
            // Store in cache and call thumbnail completion handler
            apods[date] = apod
            thumbnailCompletion?(apod)
        }
        
        // 3. Get APOD image
        if shouldLoadImage {
            // Create a load task if none is already running
            // If the image was already loaded, still create a new load task
            // This will call the APOD API and return the already loaded image from there, so no additional waiting time
            if imageTasks[date] == nil {
                imageTasks[date] = Task { [apod] in
                    let image = try await apodAPI.thumbnail(of: apod!)
                    var apodUpdate = apod!
                    apodUpdate.image = image
                    return apodUpdate
                }
            }
            // Wait for the load task to finish and remove it thereafter
            apod = try await imageTasks[date]?.value
            imageTasks[date] = nil
            
            // Store in cache and call thumbnail completion handler
            apods[date] = apod
            imageCompletion?(apod)
        }
    }
}

// FIXME: All tasks need to be removed after accessed
// FIXME: Make APOD an actor because the APOD object is accessed asynchronously by thumbnail AND image task. This makes it vulnerable to race conditions. Therefore create a method which allows us to setThumbnail and setImage for the APOD.
