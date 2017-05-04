//
//  PieLegendView.swift
//  Zilliance
//
//  Created by Philip Dow on 4/26/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

private let colorDiameter = CGFloat(14)

final class PieLegendView: UIView {
    private let stackView = UIStackView()
    
    var labels = [
        "I feel great",
        "I feel neutral",
        "I feel lousy",
        "I feel mixed"
    ]
    var colors: [UIColor] = [
        .feelingGreat,
        .feelingNeutral,
        .feelingLousy,
        .feelingMixed
    ]
    
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
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stackView)
        
        self.stackView.alignment = .fill
        self.stackView.axis = .vertical
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 0
        
        self.stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        zip(self.labels, self.colors).forEach { (text, color) in
            
            let containerView = UIView()
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = UIColor.clear
            
            let label = UILabel()
            
            label.text = text
            label.backgroundColor = .clear
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .darkBlueBackground
            label.font = .muliRegular(size: 12)
            containerView.addSubview(label)
            
            let colorView = UIView()
            
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = colorDiameter/2
            colorView.layer.borderColor = UIColor.darkBlueBackground.cgColor
            colorView.layer.borderWidth = 0.5
            containerView.addSubview(colorView)
            
            colorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
            colorView.widthAnchor.constraint(equalToConstant: colorDiameter).isActive = true
            colorView.heightAnchor.constraint(equalToConstant: colorDiameter).isActive = true
            colorView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            
            label.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 10).isActive = true
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            label.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            
            self.stackView.addArrangedSubview(containerView)
        }
    }
}
