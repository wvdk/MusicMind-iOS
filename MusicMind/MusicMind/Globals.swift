//
//  Globals.swift
//  MusicMind
//
//  Created by Wesley Van der Klomp on 3/18/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import Foundation

// Yes, these are globals. Yes, global state is the root of all evil. Yes, I'm doing it anyway.

let userLoginCredentials = UserLoginCredentials()
let user = User()
let spotifyAuth = SPTAuth.defaultInstance()!
let spotifyStreamingController = SPTAudioStreamingController.sharedInstance()!

enum NavigationBarTheme {
    case light
    case dark
}

var prettyVersionNumber: String {
    get {
        if let infoDictionary = Bundle.main.infoDictionary {
            if let versionNumber = infoDictionary["CFBundleShortVersionString"] as? String,
                let buildNumber = infoDictionary["CFBundleVersion"] as? String {
                
                return "\(versionNumber) (\(buildNumber))"
            }
        }
        
        return "No version number found."
    }
}
