//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Gil Ferreira on 10/24/15.
//  Copyright © 2015 Gil Ferreira. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosViewController : UIViewController, NSFetchedResultsControllerDelegate {

    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get delegate and shared session
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
                
        
    }
    
}