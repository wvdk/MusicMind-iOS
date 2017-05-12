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
    
    override func viewDidLoad() {
        // Setups
        setupNavigationBar(theme: .light)
        hideKeyboardWhenTappedAround()
        
        // Set delegates
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension FindFriendsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Perform search
        
        let usersRef = FIRDatabase.database().reference().child("users")
        
//        usersRef.queryOrderedByKey().
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //
    }

}

extension FindFriendsViewController: UITableViewDelegate {
    
}

extension FindFriendsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        //  Statuses
        // Add
        // Checked
  
        return cell
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
}

