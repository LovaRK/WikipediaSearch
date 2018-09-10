//
//  Artical+CoreDataProperties.swift
//  WikipediaSearch
//
//  Created by Lova Rama Krishna P on 09/09/18.
//  Copyright © 2018 Lova Rama Krishna P. All rights reserved.
//
//

import Foundation
import CoreData


extension Artical {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artical> {
        return NSFetchRequest<Artical>(entityName: "Artical")
    }

    @NSManaged public var name: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var image: String?
    @NSManaged public var articalContent: String?

}
