//
//  MainViewController.swift
//  ProfileViewApp
//
//  Created by Tejeshwar Singh Gill on 24/2/19.
//  Copyright © 2019 GILL/Samsung. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    lazy var tableviewController:TopAppsTableViewController = {
        return self.children.lazy.compactMap({ $0 as? TopAppsTableViewController}).first!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    func makeQuery(query:String){
        tableviewController.fetchLatestData(with: query)
    }
}
