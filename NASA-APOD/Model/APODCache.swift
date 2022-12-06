//
//  APODCache.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 26.11.22.
//

import UIKit
import Combine

// FIXME: Should this be an actor?
class APODCache {
    
    // MARK: Model
    
    private var apodAPI: APODAPI
    
    /// Stores loaded APODs (cache)
    private var apods: [Date: APOD] = [:]
    
    private var apodTasks: [Date: Task<APOD, Error>] = [:]
    private var thumbnailTasks: [Date: Task<UIImage, Error>] = [:]
    private var imageTasks: [Date: Task<UIImage, Error>] = [:]
    
    
    // MARK: -
    
    /// - Parameters:
    ///     - apodAPI: The API instance to use when loading APODs.
    ///     - initialLoadAmout: The amount of APODs that should be loaded into cache directly when the cache is initialized.
    ///     - withThumbnails: Specifies, whether the initially loaded APODs should be loaded with thumbnails.
    ///     - withImages: Specifies, whether the initially loaded APODs should be loaded with images.
    init(api apodAPI: APODAPI, withThumbnails shouldLoadThumbnails: Bool = false, withImages shouldLoadImages: Bool = false) throws {
        self.apodAPI = apodAPI
    }

    /// Loads a specified amount of APODs into the cache (excluding the first day).
    ///
    /// - Parameters:
    ///     - startDate: The date from which to start loading previous days.
    ///     - loadAmount: Specifies how many past days should be loaded. I. e. if a value of 10 is given, the last 10 APODs are loaded into the cache.
    ///     - shouldLoadThumbnails: Specifies, whether thumbnails should also be loaded.
    ///     - shouldLoadImages: Specifies, whether images should also be loaded.
    public func load(startDate: Date? = nil, previousDays loadAmount: Int = 10, withThumbnails shouldLoadThumbnails: Bool, withImages shouldLoadImages: Bool) async throws {
        assert(loadAmount >= 0)
        
        // Get start date
        guard let start = startDate ?? DateUtils.today() else { return }
    
        // Store retrieved APODs at their individual position in the cache
        for days in (0..<loadAmount) {
            // Get date, continue to next if this fails
            guard let date = DateUtils.date(start, adding: -days)
            else {
                // Try next APOD
                continue
            }
            
            let _ = try await apod(for: date, withThumbnail: shouldLoadThumbnails, withImage: shouldLoadImages)
        }
    }
    
    /// Loads an APOD either from cache or from API.
    ///
    /// There are situations where you want to only load the metadata first (for the title for example) and then load the thumbnail or image afterwards. Therefore just call this function twice:
    /// ```
    /// let today = Date()
    /// var apod = await cache.apod(for: today)
    /// apod = await cache.apod(for: today, withThumbnail: true)
    /// ```
    /// Since the metadata is already cached on the second call, calling the function again results in effectively no time lost.
    ///
    /// - Parameters:
    ///     - date: The date for which to load the APOD.
    ///     - shouldLoadThumbnail: Specifies, if thumbnail should be loaded for APOD.
    ///     - shouldLoadImage: Specifies, if image should be loaded for APOD.
    func apod(
        for date: Date,
        withThumbnail shouldLoadThumbnail: Bool = false,
        withImage shouldLoadImage: Bool = false)
    async throws -> APOD {
        // Strip time from date to have a unified key for caching
        guard let date = DateUtils.strip(date) else { throw APODAPIError.queryCompositionFailure("Failed to create request date for given date.") }
        
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
        
        // 2. Get APOD thumbnail
        if shouldLoadThumbnail {
            // Create a load task if none is already running
            // If the thumbnail was already loaded, still create a new load task
            // This will call the APOD API and return the already loaded thumbnail from there, so no additional waiting time
            if thumbnailTasks[date] == nil {
                thumbnailTasks[date] = Task { [apod] in
                    return try await apodAPI.thumbnail(of: apod!)
                }
            }
            // Wait for the load task to finish and remove it thereafter
            let thumbnail = try await thumbnailTasks[date]?.value
            thumbnailTasks[date] = nil
            
            // Store thumbnail in APOD in cache
            await apods[date]?.setThumbnail(thumbnail)
        }
        
        // 3. Get APOD image
        if shouldLoadImage {
            // Create a load task if none is already running
            // If the image was already loaded, still create a new load task
            // This will call the APOD API and return the already loaded image from there, so no additional waiting time
            if imageTasks[date] == nil {
                imageTasks[date] = Task { [apod] in
                    return try await apodAPI.image(of: apod!)
                }
            }
            // Wait for the load task to finish and remove it thereafter
            let image = try await imageTasks[date]?.value
            imageTasks[date] = nil
            
            // Store image in APOD in cache
            await apods[date]?.setImage(image)
        }
        
        return apod
    }
}
