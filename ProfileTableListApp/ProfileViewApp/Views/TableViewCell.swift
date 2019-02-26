//
//  TableViewCell.swift
//  ProfileViewApp
//
//  Created by Tejeshwar Singh Gill on 24/2/19.
//  Copyright © 2019 GILL/Samsung. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        //self.imageView?.frame = CGRect(x: 15, y: 15, width: 50, height: 50)
        
    }

}
