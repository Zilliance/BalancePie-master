//
//  IconCollectionViewCell.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 2/10/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.selectedIcon : UIColor.unselectedIcon
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    
}
