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
    
    var selectedPin : Pin?
    @IBOutlet weak var mapView: MKMapView!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Zoom into mappod
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let coords = selectedPin!.coordinate
        
        let region = MKCoordinateRegion(center: coords
            , span: span)

        mapView.setRegion(region, animated: true)
        
        // TODO : Check if images are already downloaded
        if false {
        
        } else {
            
            let lat = coords.latitude 
            let lng = coords.longitude 
            
            FlickrClient.sharedInstance().GetImages(lat, lng: lng){
                (result, error) in
                
                if (result != nil) {
                    
                    //Find out how many we have and save it.
                    print(result)
                } else {
                    print(error)
                }

            }
        }
        
    }
}