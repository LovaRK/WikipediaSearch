//
//  Article.swift
//  WikipediaSearch
//
//  Created by Lova Rama Krishna P on 10/09/18.
//  Copyright © 2018 Lova Rama Krishna P. All rights reserved.
//

import Foundation

class Article {
    let name: String
    let image: String
    let description: String
    let articalContent: String
    
    init(name: String, image: String, description: String, articalContent: String) {
        self.name = name
        self.description = description
        self.articalContent = articalContent
        self.image = image
    }
}
