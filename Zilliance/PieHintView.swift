//
//  PieHintView.swift
//  Zilliance
//
//  Created by Philip Dow on 4/26/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class PieHintView: UIView {
    private let imageView = UIImageView()
    private let label = UILabel()
    
    // MARK: -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        
        // Hint Label
        
        self.label.text = "Tap the plus button to add an activity to your pie. Tap a slice to update or improve it."
        self.label.font = .muliRegular(size: 12)
        self.label.textColor = .darkBlueBackground
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.numberOfLines = 0
        
        self.addSubview(self.label)
        self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20+14+10).isActive = true
        self.label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        
        // Left anchor calculated from PieLegedView constraints:
        //  20: legend margin from left
        //  14: diameter of legend color
        //  10: margin between legend color and text
        
        // Hint Image
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.image = #imageLiteral(resourceName: "icon-lightbulb").tinted(color: .lightBlueBackground)
        
        self.addSubview(self.imageView)
        
        self.imageView.topAnchor.constraint(equalTo: self.label.topAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.label.bottomAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        self.imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 40)
    }

}
