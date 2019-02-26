//
//  TopAppsTableViewController.swift
//  ProfileViewApp
//
//  Created by Tejeshwar Singh Gill on 24/2/19.
//  Copyright © 2019 GILL/Samsung. All rights reserved.
//

import UIKit

class TopAppsTableViewController: UITableViewController {

    @IBOutlet var viewModel: ViewModel!
    @IBOutlet weak var failLabel: UILabel!
    
    let photoManager: PhotosManager = PhotosManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 136
        self.tableView.allowsSelection = false;
        
        if NetworkReachability.isConnectedToNetwork() == true {
           // failLabel.isHidden = true ( Commented for adding reachability in the futures
        }
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        self.fetchLatestData(with: "")
    }

    func fetchLatestData(with query:String){
        viewModel.getApps(query) {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItemsToDisplay(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell

        print(cell.textLabel?.text ?? "")

        cell.nameLabel.text = viewModel.appTitleToDisplay(for: indexPath)
        if cell.nameLabel.text == "" {
            cell.nameLabel.text = "Name Unavailable"
        }
        cell.skillsLabel.text = viewModel.appDescriptionToDisplay(for: indexPath)
        if cell.skillsLabel.text == "" {
            cell.skillsLabel.text = "Skills Unavailable"
        }
        
        let url:String = viewModel.appImageDisplay(for: indexPath)
        let image = photoManager.cachedImage(for: url)
        if  image != nil {
            cell.profileImage?.image = image
        }else{
            cell.profileImage?.image = #imageLiteral(resourceName: "noImage.jpg")
            photoManager.retrieveImage(for: url) { (img) in
                DispatchQueue.main.async {
                    if  img != nil {
                        cell.profileImage?.image = img
                    }
                    else{
                        cell.profileImage?.image = #imageLiteral(resourceName: "noImage.jpg")
                    }
                }
            }
        }
        return cell
    }
}
