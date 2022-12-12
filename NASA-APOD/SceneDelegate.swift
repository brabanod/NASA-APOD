//
//  SceneDelegate.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 22.11.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        // Create APOD API instance and pass it to the HomeViewController
        if let homeVC = scene.windows.first?.rootViewController as? HomeViewController {
            do {
                let apodAPI: APODAPI!
                if CommandLine.arguments.contains("-UITests") {
                    // Mock API when argument UITests is given
                    let configuration = URLSessionConfiguration.default
                    configuration.protocolClasses = [APODAPIMockDefault.self]
                    let urlSession = URLSession(configuration: configuration)
                    apodAPI = try APODAPI(urlSession: urlSession)
                    
                    // Set options on mock
                    APODAPIMockDefault.simulateDelay = CommandLine.arguments.contains("-SimulateNetworkDelay")
                    APODAPIMockDefault.failRequests = CommandLine.arguments.contains("-FailRequests")
                } else {
                    // Otherwise create normal API
                    apodAPI = try APODAPI()
                }
                
                let apodCache = try APODCache(api: apodAPI)
                homeVC.apodCache = apodCache
                
                // Start loading a few APODs in the background
                Task{
                    // Exclude today from caching
                    guard let yesterday = DateUtils.today(adding: -1) else { return }
                    try await apodCache.load(startDate: yesterday, previousDays: Configuration.initialCacheLoadAmount, withThumbnails: true, withImages: false)
                }
            } catch {
                // This should never happen, when NASAAPIKey is set.
                Log.default.log("Failed to create API. Error:\n\(error)")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

