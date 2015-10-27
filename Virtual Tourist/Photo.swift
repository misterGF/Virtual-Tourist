//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Gil Ferreira on 10/25/15.
//  Copyright © 2015 Gil Ferreira. All rights reserved.
//

import Foundation
import MapKit
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    
    @NSManaged var url: NSURL

    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(insertIntoMangedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }
}
