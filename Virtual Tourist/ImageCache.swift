//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Gil Ferreira on 11/24/15.
//  Copyright © 2015 Gil Ferreira. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {

    // Grab photos
    func getImageWithId(identifier: String?) -> UIImage? {
        
        if identifier == nil || identifier == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        if let data = NSData(contentsOfFile: path){
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // Stopre photo
    func storeImage(image: UIImage?, withIdentifier identifier: String){
        
        let path = pathForIdentifier(identifier)
        
        if image == nil {
            
            do {
               try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch {
                //empty
            }
            
            return
        }
        
        let data = UIImagePNGRepresentation(image!)
        data?.writeToFile(path, atomically: true)
    }
    
    // Helper Function
    func pathForIdentifier(identier: String) -> String {
        
        let documentsDirectoryURL : NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identier)
        return fullURL.path!
    }
    
}
