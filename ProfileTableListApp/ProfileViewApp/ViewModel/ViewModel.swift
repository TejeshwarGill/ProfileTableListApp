//
//  ViewModel.swift
//  ProfileViewApp
//
//  Created by Tejeshwar Singh Gill on 24/2/19.
//  Copyright © 2019 GILL/Samsung. All rights reserved.
//

import UIKit

class ViewModel: NSObject {

    @IBOutlet var apiClient: APIClient!
    
    var apps: [NSDictionary]?
    
    //This function is what directly accesses the apiClient to make the API call
    func getApps(_ query:String, completion: @escaping () -> Void) {
        
        //call on the apiClient to fetch the apps
        apiClient.fetchAppList(query) { (arrayOfAppsDictionaries) in
            
            //Put this block on the main queue because our completion handler is where the data display code will happen and we don't want to block any UI code.
            DispatchQueue.main.async {
                
                //assign our local apps array to our returned json
                self.apps = arrayOfAppsDictionaries
                
                //call our completion handler because it is in this completion that we will reload data in our view controller tableview
                completion()
            }
        }
    }
    
    // MARK: - values to display in our table view controller
    func numberOfItemsToDisplay(in section: Int) -> Int {
        return apps?.count ?? 0
    }
    
    func appTitleToDisplay(for indexPath: IndexPath) -> String {
        return apps?[indexPath.row].value(forKeyPath: "name") as? String ?? ""
    }
    
    func appDescriptionToDisplay(for indexPath: IndexPath) -> String {
        return apps?[indexPath.row].value(forKeyPath: "skills") as? String ?? ""
    }
    
    func appImageDisplay(for indexPath: IndexPath) -> String {
        guard let owner = apps?[indexPath.row].value(forKeyPath: "image") as? [String:AnyObject] else {
            return ""
        }
        return owner["avatar_url"] as? String ?? ""
    }
}














