//
//  Int+Extensions.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/10/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation

extension Int {
    
    func labeledArray(with text: String) -> [String] {
        return Array(0...self).labeledArray(with: text)
    }
    
}

extension Sequence where Iterator.Element == (Int)
{
    func labeledArray(with text: String) -> [String] {
        return self.map { $0.labeled(with: text)}
    }
}

extension Int
{
    func labeled(with text: String) -> String
    {
        return self == 1 ? "\(self) \(text)" : "\(self) \(text)s"
    }
}
