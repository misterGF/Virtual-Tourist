//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Gil Ferreira on 10/25/15.
//  Copyright © 2015 Gil Ferreira. All rights reserved.
//

import Foundation
import MapKit
import CoreData

@objc(Pin)

class Pin : NSManagedObject, MKAnnotation {
 
    @NSManaged var lat: Double
    @NSManaged var lng: Double
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(lat: Double, lng: Double, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.lat = lat
        self.lng = lng
        
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
