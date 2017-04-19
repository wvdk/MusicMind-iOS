//
//  MusicSearchViewController.swift
//  MusicMind
//
//  Created by Ryan Boyd on 3/19/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import UIKit
import Alamofire

class MusicSearchViewController: UIViewController {
    
    var searchResults = [String: Any]()
    var totalNumberOfSongFromResults: Int = 0
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup gesture recognizer
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(MusicSearchViewController.edgeGestureAction(sender:)))
        edgeGesture.edges = UIRectEdge.right
        view.addGestureRecognizer(edgeGesture)
     
        // Other setups
//        createAudioPlayer()
        hideKeyboardWhenTappedAround()
        
        searchBar.keyboardAppearance = .dark
        
        // Set delegates
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let session = spotifyAuth.session {
            if session.isValid() {
                spotifySteamingController.login(withAccessToken: session.accessToken)
            } else {
                // the session has expired and we need to refresh it using SPTAuth
            }
        } else {
            presentSpotifyLoginAlert()
        }
        
        
    
//        if SPTAudioStreamingController.sharedInstance().loggedIn {
//            print("Yay. User is logged in to spotify.")
//        }
    }
    
    private func presentSpotifyLoginAlert() {
        let alert = UIAlertController(title: "Spotify Log In", message: "You need to login with your Spotify Premium account in order to play songs.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            self.dismiss(animated: true, completion: nil)
            
        }
        let login = UIAlertAction(title: "Go to Spotify", style: .default) { (alertAction) in
            self.loginToSpotify()
        }
        
        alert.addAction(cancel)
        alert.addAction(login)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func loginToSpotify() {
        
        if spotifyAuth.session != nil {
            
//            SPTAudioStreamingController.sharedInstance().login(withAccessToken: user.spotifyToken!)
            
            print(SPTAuth.defaultInstance().session.canonicalUsername)
        }
        else {
            if let spotifyUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL() {
                UIApplication.shared.open(spotifyUrl, options: [:])
            }
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func edgeGestureAction(sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.dismiss(animated: true, completion: nil)
        default:
            // pass down for the interaction controller to handle the rest of these cases
            break
        }
    }

    
    // MARK: - Setups and helpers
    
//    private func createAudioPlayer() {
//        spotifySteamingController.playbackDelegate = self
//        spotifySteamingController.delegate = self
//        
//        do {
//            try spotifySteamingController.start(withClientId: "3b7f66602b9c45b78f4aa55de8efd046")
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//    }
    
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

// MARK: - Table view delegates
extension MusicSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tracks = self.searchResults["tracks"] as? [String: Any] {
            if let items = tracks["items"] as? [[String: Any]] {
                let index = items[indexPath.row]
                let trackURI = index["uri"] as? String

                SPTAudioStreamingController.sharedInstance().playSpotifyURI(trackURI, startingWith: 0, startingWithPosition: 0) {
                    error in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalNumberOfSongFromResults
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
