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
    
    @NSManaged var url: String
    @NSManaged var imageID: String
    @NSManaged var pin: Pin?

    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(dictionary: [String : AnyObject], insertIntoMangedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        url = dictionary["url"] as! String
        imageID = dictionary["id"] as! String
        
    }
    
    var image: UIImage? {
        
        get {
            return FlickrClient.Cache.imageCache.getImageWithId("\(imageID).jpg")
        }
        
        set {
            FlickrClient.Cache.imageCache.storeImage(newValue, withIdentifier: "\(imageID).jpg")
        }
    }

    func removeFromDocumentsDirectory(identifier: String) {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        let path = fullURL.path!
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch _ {
        }
        //NSCache().removeObjectForKey(path)
    }
}
