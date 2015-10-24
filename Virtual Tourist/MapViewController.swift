//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Gil Ferreira on 10/24/15.
//  Copyright © 2015 Gil Ferreira. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deletePinsLabel: UILabel!
    @IBOutlet weak var editNavBtn: UIBarButtonItem!
    
    // Nav button clicked function
    @IBAction func editNavBtnAction(sender: AnyObject) {
        
        if deletePinsLabel.hidden {
            //Prior state was Edit
            editNavBtn.title = "Done"
            deletePinsLabel.hidden = false
            
            
        } else {
            //Prior state was Done - Let's hide the label
            editNavBtn.title = "Edit"
            deletePinsLabel.hidden = true
        }
    
    }

    // Add pin logic
    @IBAction func addPin(sender: UILongPressGestureRecognizer) {
        
        //Only add pins if in the right mode
        if deletePinsLabel.hidden {
            let location = sender.locationInView(self.mapView)
            let locCoords = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = locCoords
            annotation.title = "Pin added"
            self.mapView.addAnnotation(annotation)

        } else {
            print("Long press detected but in wrong mode")
        }
    }
    
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get delegate and shared session
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        mapView.delegate = self
        
        // Check if core data has last location
        if false {
            // Set initial loation
            let initialLocation = CLLocation(latitude: 21.282778, longitude:  -157.829444)
            centerMapOnLocation(initialLocation)
            
        } else {
            
        }

    }
    
    // Delegate function for maps - Response to taps
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Annotation selected")
        // Annotation selected. Will want to segue to our other view
        let photoViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PhotosVC") as! PhotosViewController
        
        // Push the new VC onto the stack
        //self.navigationController!.pushViewController(photoViewController, animated: true)
        
        
        
    }
    // Helper function to center based on coords
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

