//
//  VCHelper.swift
//  Virtual Tourist
//
//  Created by Gil Ferreira on 10/24/15.
//  Copyright © 2015 Gil Ferreira. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alertError(errorString: String?){
        
        let alertController = UIAlertController(title: "Error Detected", message:
            errorString, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,
            handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        
        let url : NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
       session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            self.image = UIImage(data: data!)
            
        });

    }
}