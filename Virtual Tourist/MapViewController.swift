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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deletePinsLabel: UILabel!
    @IBOutlet weak var editNavBtn: UIBarButtonItem!
    var mapChangedFromUSerInteraction = false
    
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
            
            // Save to context
            print("Pin location: \(locCoords)")
            let pin = Pin(insertIntoMangedObjectContext: sharedContext)
            pin.lat = locCoords.latitude
            pin.lng = locCoords.longitude
            CoreDataStackManager.sharedInstance().saveContext()

        } else {
            print("Long press detected but in wrong mode")
        }
    }
    
    func addPinToMap(pinObj : Pin){
       
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pinObj.lat, pinObj.lng)
        annotation.title = "Pin added"
        self.mapView.addAnnotation(annotation)
    }
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        fetchCoords()
        for entry in fetchedCoordsController.fetchedObjects as! [Coords] {
            
            let coord = entry.lastLocation
            print("Coords from original \(coord)")
            // Set initial loation
            centerMapOnLocation(coord)
        }
        
        fetchPins()
        for entry in fetchedPinsController.fetchedObjects as! [Pin] {
            print("Pin from coredata \(entry.lat) \(entry.lng)")
            addPinToMap(entry)
        }
        
        

    }
    
    // Convience functions for our core data
    lazy var fetchedCoordsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Coordinates")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastLocation", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    lazy var fetchedPinsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true)]
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
    
    func fetchPins(){
 
        var error: NSError?
        do {
            try fetchedPinsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
    }
    
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
            print("Deleting \(coord)")
            sharedContext.deleteObject(coord)
        }
    }
    
    
    // Delegate function for maps - Response to taps
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        // Annotation selected. Will want to segue to our other view or delete.
        if editNavBtn.title == "Edit" {
            performSegueWithIdentifier("toPhotoVC", sender: nil)
        } else {
            
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

