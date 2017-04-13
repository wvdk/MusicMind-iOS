//
//  MusicSearchViewController.swift
//  MusicMind
//
//  Created by Ryan Boyd on 3/19/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import UIKit
import Alamofire

class MusicSearchViewController: UITableViewController {
    
    var searchResults = [String: Any]()
    var totalNumberOfSongFromResults: Int = 0
    var audioPlayer: SPTAudioStreamingController?
    @IBOutlet weak var searchBar: UISearchBar!

    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setups
        createAudioPlayer()
        setupNavigationBar(theme: .light)
        hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        searchBar.keyboardAppearance = .dark
    }

    
    // MARK: - Setups and helpers
    
    private func createAudioPlayer() {
        audioPlayer = SPTAudioStreamingController.sharedInstance()
        
        audioPlayer?.playbackDelegate = self
        audioPlayer?.delegate = self
        try! audioPlayer?.start(withClientId: "85374bf3879843d6a7b6fd4e62030d97")
        
        audioPlayer!.login(withAccessToken: user.spotifyToken)
    }
    
    func convertStringToDictionary(text: String) -> [String:Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
}

extension MusicSearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        Alamofire.request("https://api.spotify.com/v1/search?q=\(searchText)&type=track").responseString { response in
            debugPrint(response)
            
            if let json = response.result.value {
                print("JSON: \(json)")
                
                if let dict = self.convertStringToDictionary(text: json ) {
                    
                    self.searchResults = dict
                    
                    if let tracks = self.searchResults["tracks"] as? [String: Any] {
                        
                        if let items = tracks["items"] as? [[String: Any]] {
                            
                            self.totalNumberOfSongFromResults = items.count
                            
                        }
                        
                    }
                    
                    debugPrint(self.searchResults)
                    
                    self.tableView?.reloadData()
                }
            }
        }
    }
    
}

extension MusicSearchViewController: UITextViewDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension MusicSearchViewController: SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    
    // MARK: - Audio steaming
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print(audioStreaming)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print(trackUri)
    }

}

/// Table view delegate and data source methods
extension MusicSearchViewController {
    
    
    // MARK: - Table view delegate 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tracks = self.searchResults["tracks"] as? [String: Any] {
            if let items = tracks["items"] as? [[String: Any]] {
                if let index = items[indexPath.row] as? [String: Any] {
                    let trackURI = index["uri"] as? String
                    self.audioPlayer?.playSpotifyURI(trackURI, startingWith: 0, startingWithPosition: 0, callback: { error in
                        if (error != nil) {
                            print(error?.localizedDescription)
                            return;
                        }})
                    
                }
            }
        }
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalNumberOfSongFromResults
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let tracks = self.searchResults["tracks"] as? [String: Any] {
            if let items = tracks["items"] as? [[String: Any]] {
                if let index = items[indexPath.row] as? [String: Any] {
                    
                    cell.textLabel?.text = index["name"] as? String
                    
                    if let album = index["album"] as? [String: Any] {
                        
                        if let artist = album["artists"] as? [[String: Any]] {
                            cell.detailTextLabel?.text = artist[0]["name"] as? String
                            print(artist[0]["name"] as? String)
                        }
                        
                        if let image = album["images"] as? [[String: Any]]{
                            if let smallImage = image[2] as? [String: Any]{
                                let urlString = smallImage["url"] as? String
                                if let url  = NSURL(string: urlString!){
                                    if let data = NSData(contentsOf: url as URL){
                                        cell.imageView?.image = UIImage(data: data as Data)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }

}
