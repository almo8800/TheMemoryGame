//
//  Card.swift
//  The Memory
//
//  Created by Andrei on 14/6/23.
//

import Foundation

struct Card {
    var imageName = ""
    var isFlipped = false
    var isMatched = false
    
    init(imageName: String, isFlipped: Bool, isMatched: Bool) {
        self.imageName = imageName
        self.isFlipped = isFlipped
        self.isMatched = isMatched
    }
}
