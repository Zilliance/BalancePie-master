//
//  TextImprovementsExamples.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 08-05-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation

//usage example:

//let examples = TextImprovementsExamples.instance.getImprovementExamplesFor(feeling: .great, improvementType: .gratitude)


final class TextImprovementsExamples {
    
    static let instance = TextImprovementsExamples()
    
    private var examples: [String:[String: Array<String>]] = [:]
    
    private init()
    {
        if let path = Bundle.main.path(forResource: "TextImprovementsExamples", ofType: "plist"), let texts = NSDictionary(contentsOfFile: path) as? [String: [String: Array<String>]] {

            examples = texts
            
        }
    }
    
    func getImprovementExamplesFor(feeling: Feeling, improvementType: FineTuneType) -> [String]? {
        
        guard let feelingString = feeling.string else {
            return nil
        }
        
        let requiedExamples = examples[feelingString]
        
        return requiedExamples?[improvementType.rawValue]
        
    }
    
}
