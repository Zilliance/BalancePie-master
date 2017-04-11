//
//  ItemsSelectionViewController.swift
//  Zilliance
//
//  Created by mac on 05-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

final class ItemWithIconCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var label: UILabel!
}

struct ItemSelectionViewModel
{
    var image: UIImage?
    var title: String
    
    init(title: String, image: UIImage? = nil) {
        self.title = title
        self.image = image
    }
    
}

class ItemsSelectionViewController: UIViewController {

    var items: [ItemSelectionViewModel] = []
    var createItemTitle = "Create new item"
    var selectedItemsIndexes:Set<Int> = []
    
    @IBOutlet weak var tableView: UITableView!
    var doneAction: (([Int]) -> ())?
    var createNewItemAction: (() -> ())?

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        self.tableView.contentOffset.y = 0
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

extension ItemsSelectionViewController: UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) //create action item
        {
            self.createNewItemAction?()
            return
        }
        
        if (!self.selectedItemsIndexes.contains(indexPath.row))
        {
            self.selectedItemsIndexes.insert(indexPath.row)
        }
        else
        {
            self.selectedItemsIndexes.remove(indexPath.row)
        }
        
        if let cell = tableView.cellForRow(at: indexPath)
        {
            cell.accessoryType = self.selectedItemsIndexes.contains(indexPath.row) ? .checkmark : .none
        }
        
    }
}

extension ItemsSelectionViewController: UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
                   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createItemCell")!
            
            cell.textLabel?.text = self.createItemTitle
            cell.selectionStyle = .none

            return cell
        }
        else
        {
            let item = self.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")!

            cell.imageView?.image = item.image

            cell.textLabel?.text = item.title
            
            cell.accessoryType = self.selectedItemsIndexes.contains(indexPath.row) ? .checkmark : .none
            cell.selectionStyle = .none

            return cell
        }
    }
    
}
