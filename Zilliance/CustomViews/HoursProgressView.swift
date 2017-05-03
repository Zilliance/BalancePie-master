//
//  HoursProgressView.swift
//  Balance Pie
//
//  Created by Philip Dow on 3/14/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

private let hoursInAWeek = CGFloat(24 * 7)

final class HoursProgressView: UIView {
    private let filledLabel = UILabel()
    private let sleepLabel = UILabel()
    let progressTrack = UIView()
    private let progressBar = UIView()
    private var progressBarWidthConstraint: NSLayoutConstraint!
    private let sleepBar = UIView()
    private var sleepBarWidthConstraint: NSLayoutConstraint!
    private let button = UIButton()
    
    var action: (()->Void)? = nil
    
    var availableHours: Int = 0 {
        didSet {
            self.updateView()
        }
    }
    var sleepHours: Int = 0 {
        didSet {
            self.updateView()
        }
    }
    var activeHours: Int = 0 {
        didSet {
            self.updateView()
        }
    }
    
    // MARK: -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .darkBlueBackground
        
        // Progress Track
        
        self.progressTrack.backgroundColor = UIColor(red: 49.0/255.0, green: 67.0/255.0, blue: 95.0/255.0, alpha: 1)
        self.progressTrack.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.progressTrack)
        self.progressTrack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        self.progressTrack.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        self.progressTrack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
        self.progressTrack.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        // Progress Bar
        
        self.progressBar.backgroundColor = .lightBlueBackground
        self.progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.progressBar)
        self.progressBar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        self.progressBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
        self.progressBar.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        self.progressBarWidthConstraint = self.progressBar.widthAnchor.constraint(equalToConstant: 0)
        self.progressBarWidthConstraint.isActive = true
        
        // Sleep Bar
        
        if let pattern = UIImage(named: "sleep-pattern"), let cgImage = pattern.cgImage {
            let scaled = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: pattern.imageOrientation)
            self.sleepBar.backgroundColor = UIColor(patternImage: scaled)
        } else {
            self.sleepBar.backgroundColor = .lightBlueBackground
        }
        
        self.sleepBar.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.sleepBar)
        self.sleepBar.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        self.sleepBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
        self.sleepBar.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        self.sleepBarWidthConstraint = self.sleepBar.widthAnchor.constraint(equalToConstant: 0)
        self.sleepBarWidthConstraint.isActive = true
        
        // Label
        
        self.filledLabel.translatesAutoresizingMaskIntoConstraints = false
        self.filledLabel.font = .muliRegular(size: 12)
        self.filledLabel.textColor = .lightBlueBackground
        
        self.addSubview(self.filledLabel)
        self.filledLabel.bottomAnchor.constraint(equalTo: self.progressTrack.topAnchor, constant: -4).isActive = true
        self.filledLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        
        // Sleep Label
        
        self.sleepLabel.translatesAutoresizingMaskIntoConstraints = false
        self.sleepLabel.font = .muliRegular(size: 12)
        self.sleepLabel.textColor = .lightBlueBackground
        self.sleepLabel.textAlignment = .right
        
        self.addSubview(self.sleepLabel)
        self.sleepLabel.bottomAnchor.constraint(equalTo: self.progressTrack.topAnchor, constant: -4).isActive = true
        self.sleepLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        
        // Button
        
        self.button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.button)
        self.button.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        self.button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 20).isActive = true
        self.button.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    // MARK: -
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 54)
    }
    
    private func updateView() {
        guard self.availableHours > 0 else {
            return
        }
        
        let activePercentage = CGFloat(self.activeHours) / hoursInAWeek // CGFloat(self.availableHours)
        let sleepPecentage = CGFloat(self.sleepHours) / hoursInAWeek
        let width = self.progressTrack.frame.width
        
        self.filledLabel.text = "\(self.activeHours) of \(self.availableHours) weekly hours filled"
        self.sleepLabel.text = "Asleep \(self.sleepHours) hours"
        
        self.progressBarWidthConstraint.constant = min(activePercentage, 1) * width
        self.sleepBarWidthConstraint.constant = min(sleepPecentage, 1) * width
        self.layoutIfNeeded()
    }
    
    // MARK: -
    
    @objc private func didTap(_ sender: Any?) {
        self.action?()
    }
}
