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
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        var error: NSError?
        do {
            try fetchedCoordsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }

        for entry in fetchedCoordsController.fetchedObjects as! [Coords] {
            
            let coord = entry.lastLocation
            // Set initial loation
            centerMapOnLocation(coord)
        }
        

    }
    
    // Get our Coords
    lazy var fetchedCoordsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Coordinates")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastLocation", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // Delete coords
    func deleteCoords(){
        
        print("Deleting coords")
        for coord in fetchedCoordsController.fetchedObjects as! [Coords] {
            sharedContext.deleteObject(coord)
        }
    }
    
    
    // Delegate function for maps - Response to taps
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        // Annotation selected. Will want to segue to our other view
        performSegueWithIdentifier("toPhotoVC", sender: nil)
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        //Check if defaults
        let lat = mapView.centerCoordinate.latitude.description
        let lng = mapView.centerCoordinate.longitude.description
        
        if lat != "17.9723915504974" && lng != "-40.0"   {
            
            deleteCoords()
            let coords = Coords(insertIntoMangedObjectContext: sharedContext)
            coords.lastLocation = CLLocation(latitude: mapView.centerCoordinate.latitude , longitude: mapView.centerCoordinate.longitude)
            CoreDataStackManager.sharedInstance().saveContext()
            print("Region changed")
        } else {
            print("No change")
        }

    }
    
    // Helper function to center based on coords
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

