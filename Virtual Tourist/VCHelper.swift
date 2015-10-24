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

    //Function for setting our nav bar
    func customizeNavBar() {
        
        //Add navigation buttons
        let rightButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "toggleEdit:")
        
        navigationItem.setRightBarButtonItems([rightButtonItem], animated: true)
    }
    
    func alertError(errorString: String?){
        
        let alertController = UIAlertController(title: "Error Detected", message:
            errorString, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,
            handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}