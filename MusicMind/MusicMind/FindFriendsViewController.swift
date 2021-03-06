//
//  FindFriendsViewController.swift
//  MusicMind
//
//  Created by Wesley Van der Klomp on 5/12/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import UIKit
import Firebase

class FindFriendsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchResults = [User]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        setupNavigationBar(theme: .light)
        hideKeyboardWhenTappedAround()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    fileprivate func searchForUserByName(withString: String) {
        // Get user IDs for all users with names matching withString
        let searchableNamesRef = FIRDatabase.database().reference().child("searchableNames")
        
        searchableNamesRef.queryOrderedByKey().queryStarting(atValue: withString.lowercased()).queryEnding(atValue: withString.lowercased()+"\u{f8ff}").observeSingleEvent(of: .value, with: { snapshot in
            let children = snapshot.children
            var results = [String]()
            
            while let child = children.nextObject() as? FIRDataSnapshot {
                if let id = child.value as? String {
                    results.append(id)
                }
            }
            
            self.searchResults.removeAll()
            
            // Search
            for id in results {
                let userRef = FIRDatabase.database().reference().child("users/\(id)")
                
                userRef.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                    let user = User(withSnapshot: snapshot)
                    
                    self.searchResults.append(user)
                })
            }
        })
    }
    
}

extension FindFriendsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = []
        } else {
            searchForUserByName(withString: searchText)
        }
    }

}

extension FindFriendsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendSearchResultController
        let user = searchResults[indexPath.row]
        var fullName = ""
        
        if let firstName = user.firstName { fullName = firstName }
        if let lastName = user.lastName { fullName.append(" \(lastName)") }
        
        if let profilePhotoUrl = user.profilePhoto {
            URLSession.shared.dataTask(with: profilePhotoUrl) { (data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    let image = UIImage(data: data)
                    
                    DispatchQueue.main.async {
                        cell.profileImage.image = image
                    }
                }
            }.resume()
        } else {
            cell.profileImage.image = nil
        }
        
        cell.indexPath = indexPath
        cell.nameLabel.text = fullName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(75)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
}

