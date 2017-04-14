//
//  UserActivityTableViewCell.swift
//  Zilliance
//
//  Created by Philip Dow on 4/14/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class UserActivityTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .lightGrayBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
