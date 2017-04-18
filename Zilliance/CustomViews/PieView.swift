//
//  PieView.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/29/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit
import Charts

extension UIColor {
    static let emptySlice = UIColor(white: 0.9, alpha: 1.0)
}

fileprivate let imageMinimumSizePercentageThreshold: Double = 5

final class PieView: UIView {
    
    private var pieChartView = PieChartView()
    private let plusButton = UIButton()
    
    fileprivate var activities: [UserActivity] = []
    
    var plusButtonAction: (()->())? = nil
    var sliceAction: ((Int, UserActivity)->())? = nil
    
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
        
        // How can we draw a border around the pie?
        // self.pieChartView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        // self.pieChartView.layer.borderWidth = 3
        
        // Pie Chart
        
        self.pieChartView.translatesAutoresizingMaskIntoConstraints = false
        self.pieChartView.holeRadiusPercent = 0.25
        self.pieChartView.transparentCircleRadiusPercent = 0
        self.pieChartView.animate(xAxisDuration: 1, easingOption: .easeInCubic)
        self.pieChartView.usePercentValuesEnabled = true
        self.pieChartView.isUserInteractionEnabled = true
        self.pieChartView.rotationEnabled = false
        self.pieChartView.delegate = self
        
        self.addSubview(self.pieChartView)
        
        let pieMargin: CGFloat = 8
        self.pieChartView.topAnchor.constraint(equalTo: self.topAnchor, constant: pieMargin).isActive = true
        self.pieChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: pieMargin).isActive = true
        self.pieChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -pieMargin).isActive = true
        self.pieChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -pieMargin).isActive = true
        
        // Plus Button
        
        let buttonWidth: CGFloat = 130.0
        let buttonHeight: CGFloat = 130.0
        
        self.plusButton.translatesAutoresizingMaskIntoConstraints = false
        self.plusButton.setImage(#imageLiteral(resourceName: "btnPlus"), for: .normal)
        self.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)

        self.addSubview(plusButton)
        
        self.plusButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.plusButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        self.plusButton.centerXAnchor.constraint(equalTo: pieChartView.centerXAnchor).isActive = true
        self.plusButton.centerYAnchor.constraint(equalTo: pieChartView.centerYAnchor).isActive = true
    }
    
    // MARK: - Pie Data
    
    func load(activities pieActivities:[UserActivity], availableMinutes: Minutes) {
        self.activities = pieActivities.sorted { $0.feeling.rawValue > $1.feeling.rawValue }
        
        var yVals1: [ChartDataEntry] = [ChartDataEntry]()
        var colors: [NSUIColor] = [NSUIColor]()
        
        var emptyMinutes = availableMinutes
        
        self.activities.forEach { userActivity in
            let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            
            iconImageView.image = userActivity.image
            iconImageView.contentMode = .center
            iconImageView.layer.backgroundColor = userActivity.color.darker(amount: 0.25).cgColor
            iconImageView.layer.cornerRadius = iconImageView.frame.size.height/2
            iconImageView.clipsToBounds = true
            
            var image = UIImage.image(from: iconImageView)?.resizedImage(newSize: CGSize(width: 32, height: 32))
            let percentage = Double(userActivity.duration) / Double(availableMinutes) * 100
            
            // resize the image if percentage < 5%
            
            if percentage < imageMinimumSizePercentageThreshold {
                let factor = 24 // Int(10 * percentage - 1)
                image = image?.resizedImageWithinRect(rectSize: CGSize(width: factor, height: factor))
            }
            
            yVals1.append(PieChartDataEntry(value: Double(userActivity.duration), label: nil, icon: image))
            colors.append(userActivity.color)
            
            emptyMinutes -= userActivity.duration
        }
        
        
        if emptyMinutes > 0 {
            yVals1.append(PieChartDataEntry(value: Double(emptyMinutes), label: nil, icon: nil))
            colors.append(.emptySlice)
        }
        
        let dataSet: PieChartDataSet = PieChartDataSet(values: yVals1, label: "Activities")
        
        dataSet.sliceSpace = 1
        dataSet.colors = colors
        dataSet.iconsOffset = CGPoint(x: 0, y: UIDevice.isSmallerThaniPhone6 ? 30 : 40)
        dataSet.valueFormatter = self
        
        let data: PieChartData = PieChartData(dataSet: dataSet)
        
        data.setValueTextColor(UIColor.white)
        
        self.pieChartView.data = data
        self.pieChartView.legend.enabled = false
        self.pieChartView.chartDescription?.text = ""
        self.pieChartView.highlightValues(nil)
    }
    
    // MARK: Actions
    
    @IBAction func plusButtonTapped() {
        self.plusButtonAction?()
    }

}


// MARK: -

extension PieView: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "" ;
    }
}

extension PieView: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // remove highlight for selected slice -
        chartView.highlightValue(nil)
        let index = Int(highlight.x)
        if index < self.activities.count {
            self.sliceAction?(index, self.activities[index])
        }
    }
}
