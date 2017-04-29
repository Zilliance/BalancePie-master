//
//  ItemsSelectionViewController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 05-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

final class ItemWithIconCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var label: UILabel!
    
    func setChosen(_ chosen: Bool, animated: Bool) {
        if chosen {
            self.iconView.image = self.iconView.image?.tinted(color: .lightBlueBackground)
            self.label.textColor = .lightBlueBackground
            self.label.font = .muliRegular(size: 15)
            // self.accessoryType = .checkmark
        } else {
            self.iconView.image = self.iconView.image?.tinted(color: .darkBlueBackground)
            self.label.textColor = .darkBlueBackground
            self.label.font = .muliLight(size: 15)
            // self.accessoryType = .none
        }
    }
}

struct ItemSelectionViewModel {
    var title: String
    var image: UIImage?
}

extension ItemSelectionViewModel {
    static func items(from activities:[Activity]) -> [ItemSelectionViewModel] {
        var items: [ItemSelectionViewModel] = []
        activities.forEach { activity in
            var image: UIImage? = nil
            
            if let iconName = activity.iconName {
                image = UIImage(named: iconName)?.tinted(color: .darkBlueBackground)
            }
            
            let item = ItemSelectionViewModel(title: activity.name, image: image)
            items.append(item)
        }
        return items
    }
    
    static func items(from values:[Value]) -> [ItemSelectionViewModel] {
        var items: [ItemSelectionViewModel] = []
        values.forEach { value in
            
            let item = ItemSelectionViewModel(title: value.name, image: nil)
            items.append(item)
        }
        return items
    }
}

// MARK: -

class ItemsSelectionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var items: [ItemSelectionViewModel] = []
    var createItemTitle = "Create new item"
    var selectedItemsIndexes:Set<Int> = []
    
    var doneAction: (([Int]) -> ())?
    var createNewItemAction: (() -> ())?
    
    var isMultipleSelectionEnabled = true

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .darkBlueBackground
        self.navigationController?.navigationBar.barTintColor = .groupTableViewBackground
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.darkBlueBackground,
            NSFontAttributeName: UIFont.muliBold(size: 18)
        ]
        
        self.cancelButton.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor.darkBlueBackground,
            NSFontAttributeName: UIFont.muliRegular(size: 14)
        ], for: .normal)
        
        self.doneButton.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor.darkBlueBackground,
            NSFontAttributeName: UIFont.muliBold(size: 14)
        ], for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction private func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.doneAction?(Array(self.selectedItemsIndexes))
    }
}

// MARK: - Data Source

extension ItemsSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
                   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createItemCell", for: indexPath)
            
            cell.textLabel?.text = self.createItemTitle
            cell.selectionStyle = .none
            
            cell.preservesSuperviewLayoutMargins = false
            cell.hideSeparatorInsets()

            return cell
        } else {
            let item = self.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemWithIconCell", for: indexPath) as! ItemWithIconCell
            
            if let image = item.image {
                cell.iconView.image = image
            }
            else {
                cell.iconView.removeFromSuperview()
            }
            
            cell.label?.text = item.title
            
            cell.setChosen(self.selectedItemsIndexes.contains(indexPath.row), animated: true)
            // cell.accessoryType = self.selectedItemsIndexes.contains(indexPath.row) ? .checkmark : .none
            cell.selectionStyle = .none

            cell.preservesSuperviewLayoutMargins = false
            cell.hideSeparatorInsets()
            
            return cell
        }
    }
}

// MARK: - Delegate

extension ItemsSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) {
            DispatchQueue.main.async {
                self.createNewItemAction?()
            }
            return
        }
        
        if !self.isMultipleSelectionEnabled {
            if let row = self.selectedItemsIndexes.popFirst(), let cell = tableView.cellForRow(at: IndexPath(row: row, section: 1)) as? ItemWithIconCell {
                cell.setChosen(false, animated: true)
                // cell.accessoryType = .none
            }
        }
        
        if !self.selectedItemsIndexes.contains(indexPath.row) {
            self.selectedItemsIndexes.insert(indexPath.row)
        } else {
            self.selectedItemsIndexes.remove(indexPath.row)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? ItemWithIconCell {
            cell.setChosen(self.selectedItemsIndexes.contains(indexPath.row), animated: true)
            //cell.accessoryType = self.selectedItemsIndexes.contains(indexPath.row) ? .checkmark : .none
        }
    }
}
