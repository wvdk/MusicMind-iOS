//
//  MusicSearchViewController.swift
//  MusicMind
//
//  Created by Ryan Boyd on 3/19/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import UIKit
import Alamofire

class MusicSearchViewController: UITableViewController, UISearchBarDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    var arr = [String:Any]()
    var arrCount: Int = 0
    var audioPlayer: SPTAudioStreamingController?
    
    func createSearchBar(){
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.frame.size.width = self.view.frame.size.width - 160
        searchBar.placeholder = "search"
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
    }
    
    func createAudioPlayer(){
        self.audioPlayer = SPTAudioStreamingController.sharedInstance()
        self.audioPlayer?.playbackDelegate = self
        self.audioPlayer?.delegate = self
        try! self.audioPlayer?.start(withClientId: "85374bf3879843d6a7b6fd4e62030d97")
        self.audioPlayer!.login(withAccessToken: user.spotifyToken)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        Alamofire.request("https://api.spotify.com/v1/search?q=\(searchText)&type=track").responseString { response in
            debugPrint(response)
            
            if let json = response.result.value {
                print("JSON: \(json)")
                if let dict = self.convertStringToDictionary(text: json ) {
                    self.arr = dict
                    if let tracks = self.arr["tracks"] as? [String: Any] {
                        if let items = tracks["items"] as? [[String: Any]] {
                            self.arrCount = items.count
                        }
                    }
                    debugPrint(self.arr)
                    self.tableView?.reloadData()
                    //debugPrint((self.arr["tracks"] as! [String: AnyObject])["items"] as! [String: AnyObject])
                }
            }
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print(audioStreaming)
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setups
        createSearchBar()
        createAudioPlayer()
        setupNavigationBar(theme: .light)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.arrCount
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //Configure the cell...
        if let tracks = self.arr["tracks"] as? [String: Any] {
            if let items = tracks["items"] as? [[String: Any]] {
                if let index = items[indexPath.row] as? [String: Any] {
                    
                    cell.textLabel?.text = index["name"] as? String
                    
                    if let album = index["album"] as? [String: Any] {
                        
                        //cell.textLabel?.text = album["name"] as? String
                        
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
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print(trackUri)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tracks = self.arr["tracks"] as? [String: Any] {
            if let items = tracks["items"] as? [[String: Any]] {
                if let index = items[indexPath.row] as? [String: Any] {
                    let trackURI = index["uri"] as? String
                    self.audioPlayer?.playSpotifyURI(trackURI, startingWith: 0, startingWithPosition: 0, callback: { error in
                        if (error != nil) {
                            print(error)
                            return;
                        }})
                    
                }
            }
        }
        
    }
    
}

extension MusicSearchViewController: UITextViewDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        self.view.endEditing(true)
        searchBar.resignFirstResponder()
    }
}
