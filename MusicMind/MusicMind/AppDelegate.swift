//
//  AppDelegate.swift
//  MusicMind
//
//  Created by Wesley Van der Klomp on 2/28/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        // If user is already signed in skip the onboarding flow
        if let _ = FIRAuth.auth()?.currentUser {
            // Go to Camera Capture directly
            let storyboard = UIStoryboard(name: "CameraCapture", bundle: nil)
            let welcomeViewController = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = welcomeViewController
        } else {
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let welcomeViewController = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = welcomeViewController
        }
        
        // Setup spotify auth
        spotifyAuth.sessionUserDefaultsKey = "MMSpotifySession" // Enable automatic saving of the session to defaults
        spotifyAuth.clientID = "a87022d4244f46129aac192c58fb6389"
        spotifyAuth.redirectURL = URL(string: "musicmind://returnAfterSpotify")
        spotifyAuth.requestedScopes = [SPTAuthStreamingScope]
        
        do {
            try spotifyStreamingController.start(withClientId: spotifyAuth.clientID)
            
            spotifyStreamingController.setTargetBitrate(SPTBitrate.normal, callback: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
            spotifyStreamingController.diskCache = SPTDiskCache(capacity: 5)
        } catch {
            print(error)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        // Check if this is coming from the Spotify login flow
        if spotifyAuth.canHandle(url) {
            spotifyAuth.handleAuthCallback(withTriggeredAuthURL: url, callback: {
                (error, session) in
                
                if let error = error {
                    print(error.localizedDescription)
                } else if let session = session {
                    if session.isValid() {
                        spotifyAuth.session = session
                    }
                }
            })
            
            return true
        }
        
        return false
    }
}

