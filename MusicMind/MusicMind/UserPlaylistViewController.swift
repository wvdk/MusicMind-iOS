//
//  UserPlaylistViewController.swift
//  MusicMind
//
//  Created by Rich Ruais on 5/16/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import UIKit
import Alamofire

struct playlist {
    let name: String!
    let trackCount: String!
    let largeImage: UIImage!
    let id: String!
}

struct spotifyUser {
    let id: String!
}

var currentSpotifyUser: spotifyUser!
var userPlaylists = [playlist]()
var playlistTableView = UITableView()

class UserPlaylistViewController: UIViewController {
    
    let ssh = SpotifySearchHelpers()

    @IBOutlet weak var tableView: UITableView!
    
  override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistTableView = tableView
        tableView.delegate = self
        tableView.dataSource = self

        getUserPlaylists()
        getSpotifyUserInfo()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getSpotifyUserInfo() {
        Alamofire.request("https://api.spotify.com/v1/me", headers: ["Authorization": "Bearer " + spotifyAuth.session.accessToken]).responseJSON(completionHandler: {
            response in
            self.setCurrentSpotifyUser(JSONData: response.data!)
        })
    }
    
    func setCurrentSpotifyUser(JSONData: Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String : AnyObject]
            let id = readableJSON["id"]
            let user = spotifyUser.init(id: id as! String)
            currentSpotifyUser = user
        } catch {
            print(error)
        }
    }

    
}

extension UserPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func getUserPlaylists() {
        Alamofire.request("https://api.spotify.com/v1/me/playlists", headers: ["Authorization": "Bearer " + spotifyAuth.session.accessToken]).responseJSON(completionHandler: {
            response in
            self.parseUserPlaylists(JSONData: response.data!)
        })
    }
    
    func parseUserPlaylists(JSONData: Data) {
        let tempArr = ssh.parseUserPlaylists(JSONData: JSONData)
        for i in 0..<tempArr.count {
            userPlaylists.append(tempArr[i])
        }
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPlaylists.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        let playlistName = cell.viewWithTag(1) as! UILabel
        playlistName.text = userPlaylists[indexPath.row].name
        let playlistTrackCount = cell.viewWithTag(2) as! UILabel
        playlistTrackCount.text = userPlaylists[indexPath.row].trackCount
        let playlistImage = cell.viewWithTag(3) as! UIImageView
        playlistImage.image = userPlaylists[indexPath.row].largeImage
        let backgroundImage = cell.viewWithTag(4) as! UIImageView
        backgroundImage.image = userPlaylists[indexPath.row].largeImage
    
        return cell
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playlistTracks" {
            let vc = segue.destination
                as! PlaylistTracksViewController
            let myIndexPath = self.tableView.indexPathForSelectedRow!
            let row = myIndexPath.row
            vc.playlistName = userPlaylists[row].name
            vc.playlistTrackCount = userPlaylists[row].trackCount
            vc.playlistImage = userPlaylists[row].largeImage
            vc.backgroundImage = userPlaylists[row].largeImage
            vc.playlistId = userPlaylists[row].id
        }
    }

}
