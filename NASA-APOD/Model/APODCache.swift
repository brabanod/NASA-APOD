//
//  APODCache.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 26.11.22.
//

import Foundation
import Combine

// FIXME: Should this be an actor?
class APODCache {
    
    // MARK: Model
    
    private var apodAPI: APODAPI
    
    /// Specifies how many APODs are loaded, when cache is initialized.
    private(set) var initialLoadAmount: Int
    
    /// Stores loaded APODs (cache)
    private var apods: [Date: APOD] = [:]
    
    private var apodTasks: [Date: Task<APOD, Error>] = [:]
    private var thumbnailTasks: [Date: Task<APOD, Error>] = [:]
    private var imageTasks: [Date: Task<APOD, Error>] = [:]
    
    
    // MARK: -
    
    /// - Parameters:
    ///     - apodAPI: The API instance to use when loading APODs.
    ///     - initialLoadAmout: The amount of APODs that should be loaded into cache directly when the cache is initialized.
    ///     - withThumbnails: Specifies, whether the initially loaded APODs should be loaded with thumbnails.
    ///     - withImages: Specifies, whether the initially loaded APODs should be loaded with images.
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
        for days in (0..<self.initialLoadAmount) {
            // Get date, continue to next if this fails
            guard let date = DateUtils.today(adding: -(days+1))
            else {
                // Try next APOD
                continue
            }
            
            let _ = try await apod(for: date, withThumbnail: shouldLoadThumbnails, withImage: shouldLoadImages)
        }
    }
    
    /// Loads an APOD either from cache or from API.
    ///
    /// - Parameters:
    ///     - date: The date for which to load the APOD.
    ///     - completion: This function is called, when loading metadata of APOD is completed.
    ///     - shouldLoadThumbnail: Specifies, if thumbnail should be loaded for APOD.
    ///     - thumbnailCompletion: This function is called, when loading the thumbnail of APOD is completed.
    ///     - shouldLoadImage: Specifies, if image should be loaded for APOD.
    ///     - imageCompletion: This function is called when loading the image of APOD is completed.
    func apod(
        for date: Date,
        completion: @escaping (APOD) -> (),
        withThumbnail shouldLoadThumbnail: Bool = false,
        thumbnailCompletion: ( (APOD) -> ())? = nil,
        withImage shouldLoadImage: Bool = false,
        imageCompletion: ( (APOD) -> ())? = nil)
    throws {
        Task {
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
                        let image = try await apodAPI.image(of: apod!)
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
    
    /// Convenience method for retrieving APOD asynchronously. This method allows to use await, but instead does not offer the functionality to be notified on individual loading completions (metadata, thumbnail, image)
    ///
    /// - Parameters:
    ///     - date: The date for which to load the APOD.
    ///     - shouldLoadThumbnail: Specifies, if thumbnail should be loaded for APOD.
    ///     - shouldLoadImage: Specifies, if image should be loaded for APOD.
    ///
    /// - Returns: The requested APOD with thumbnail and image already loaded if requested.
    func apod(
        for date: Date,
        withThumbnail shouldLoadThumbnail: Bool = false,
        withImage shouldLoadImage: Bool = false)
    async throws -> APOD {
        // Load APOD with a continuation, so that it can await for all completion handlers to finish
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<APOD, Error>) in
            // Keep track if all completition handlers are finished. Don' wait for thumbnails and images if not requested
            // Continuation should only be resumed if alle are true
            var isMetadataLoaded = false
            var isThumbnailLoaded = false || !shouldLoadThumbnail
            var isImageLoaded = false || !shouldLoadImage
            
            do {
                try apod(for: date,
                         completion: { apod in
                    isMetadataLoaded = true
                    if isMetadataLoaded, isThumbnailLoaded, isImageLoaded {
                        continuation.resume(with: .success(apod))
                    }
                },
                         withThumbnail: shouldLoadThumbnail,
                         thumbnailCompletion: { apod in
                    isThumbnailLoaded = true
                    if isMetadataLoaded, isThumbnailLoaded, isImageLoaded {
                        continuation.resume(with: .success(apod))
                    }
                },
                         withImage: shouldLoadImage,
                         imageCompletion: { apod in
                    isImageLoaded = true
                    if isMetadataLoaded, isThumbnailLoaded, isImageLoaded {
                        continuation.resume(with: .success(apod))
                    }
                })
            } catch {
                continuation.resume(with: .failure(error))
            }
        }
    }
}

// FIXME: Make APOD an actor because the APOD object is accessed asynchronously by thumbnail AND image task. This makes it vulnerable to race conditions. Therefore create a method which allows us to setThumbnail and setImage for the APOD.
// FIXME: Should not create a copy and then store it again, this is extremly dangerous. Instead mutate the object, only using setters.
// TODO: Find a way so that it is not possible to give completion handler for thumbnails or images but not loading any of these. This would reult in the inital loading to wait for ever to complete.
