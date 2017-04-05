//
//  ItemsSelectionViewController.swift
//  Zilliance
//
//  Created by mac on 05-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class ItemsSelectionViewController: UIViewController {

    var items: [String] = []
    var createItemTitle = "Create new item"
    var selectedItemsIndexes:Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
}

extension ItemsSelectionViewController: UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        
        return indexPath.section == 0 ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (!self.selectedItemsIndexes.contains(indexPath.row))
        {
            self.selectedItemsIndexes.insert(indexPath.row)
        }
        else
        {
            self.selectedItemsIndexes.remove(indexPath.row)
        }
        
        tableView.reloadRows(at: [indexPath], with: .fade)
        
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
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")!
            
            cell.textLabel?.text = self.items[indexPath.row]
            
            cell.selectionStyle = .none
            
            cell.accessoryType = self.selectedItemsIndexes.contains(indexPath.row) ? .checkmark : .none
            
            return cell
        }
    }
    
}
