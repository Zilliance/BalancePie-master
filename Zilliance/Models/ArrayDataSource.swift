//
//  ArrayDataSource.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 1/11/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import UIKit

class ArrayDataSource<T, U>: NSObject, UITableViewDataSource where T: UITableViewCell {
    typealias ConfigureCellClosure = (T, U) -> Void

    var items: Array<U>
    var cellIdentifier: String
    var cellClosure: ConfigureCellClosure
    
    init(items: Array<U>, cellIdentifier: String, configureCellClosure: @escaping ConfigureCellClosure) {
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.cellClosure = configureCellClosure
        super.init()
    }
    
    func update(items: Array<U>) {
        self.items = items
    }
    
    func item(at indexPath: IndexPath) -> U {
        return self.items[indexPath.row] as U
    }
    
    //MARK: TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let item = self.item(at: indexPath)
        
        switch cell {
        case let cell as T:
            cellClosure(cell, item)
            return cell
        default:
            assertionFailure()
            return cell
        }
    }
}
