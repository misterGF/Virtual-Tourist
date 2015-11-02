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
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // Init my vars/outlets/etc
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deletePinsLabel: UILabel!
    @IBOutlet weak var editNavBtn: UIBarButtonItem!
    var mapChangedFromUSerInteraction = false
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
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
    @IBAction func addPin(sender: UIGestureRecognizer) {
        
        //Only add pins if in the right mode
        if deletePinsLabel.hidden && UIGestureRecognizerState.Began == sender.state {
            
            //Grab coords
            let location = sender.locationInView(self.mapView)
            let locCoords = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            
            // Save to context
            let lat : Double = locCoords.latitude
            let lng : Double = locCoords.longitude
            
            let pin = Pin(lat: lat , lng: lng, context: sharedContext)
            print(pin)
            self.mapView.addAnnotation(pin)
            CoreDataStackManager.sharedInstance().saveContext()

        } else {
            
            print("Long press detected but in wrong mode")
            
        }
    }
    
    // View Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "addPin:")
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        
        mapView.delegate = self
        
        fetchCoords()
        
        for entry in fetchedCoordsController.fetchedObjects as! [Coords] {
            
            let coord = entry.lastLocation
            print("Coords from original \(coord)")
            
            // Set initial loation
            centerMapOnLocation(coord)
        }
        
        // Add data to our map
        mapView.addAnnotations(fetchPins())
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Handle title change on back clicks
        navigationItem.title = "Virtual Tourist"
    
    }
   
    // Change the back button prior to segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        navigationItem.title = "OK"
    }
    
    // Convience functions for our core data - Get our center coords
    lazy var fetchedCoordsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Coordinates")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastLocation", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    // Check for user interaction for map changes
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
    
        let view = self.mapView.subviews[0]
        
        if let gestureRecognizers = view.gestureRecognizers {
            
            for recognizer in gestureRecognizers {
                
                if(recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended){
                    
                    return true
                }
            }
        }
        return false
    }
    
    // Fetch all our pins
    func fetchPins() -> [Pin]{
 
        var error: NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        var results = []
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
            
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
        return results as! [Pin]
    }
    
    // Fetch our coordinates to center the map on view
    func fetchCoords(){
        
        var error: NSError?
        
        do {
            
            try fetchedCoordsController.performFetch()
            
        } catch let error1 as NSError {
            
            error = error1
            
        }
        
        if let error = error {
            
            print("Error performing initial fetch: \(error)")
            
        }
    }
    
    // Delete coords
    func deleteCoords(){
        
        print("Deleting coords")
        
        fetchCoords()
        
        for coord in fetchedCoordsController.fetchedObjects as! [Coords] {
  
            sharedContext.deleteObject(coord)
  
        }
    }
    
    // Delegate function for maps - Response to taps
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        // Annotation selected. Will want to segue to our other view or delete.
        if editNavBtn.title == "Edit" {
            
            performSegueWithIdentifier("toPhotoVC", sender: nil)
            
        } else {
            
            let pin = view.annotation as! Pin
            
            sharedContext.deleteObject(pin)
            mapView.removeAnnotation(view.annotation!)
            CoreDataStackManager.sharedInstance().saveContext()
            
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        if(mapViewRegionDidChangeFromUserInteraction()) {
            
            let lat = mapView.centerCoordinate.latitude.description
            let lng = mapView.centerCoordinate.longitude.description
            
            deleteCoords()
            
            let coords = Coords(insertIntoMangedObjectContext: sharedContext)
            
            coords.lastLocation = CLLocation(latitude: mapView.centerCoordinate.latitude , longitude: mapView.centerCoordinate.longitude)
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            print("Region changed to \(lat) \(lng)")
        }
    }
    
    // Helper function to center based on coords
    func centerMapOnLocation(location: CLLocation) {

        mapView.setCenterCoordinate(location.coordinate, animated: true)
        
        print("Got the following from core data \(location.coordinate)")
    }
    
}

