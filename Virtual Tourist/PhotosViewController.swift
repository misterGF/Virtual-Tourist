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
import SwiftyJSON

class PhotosViewController : UIViewController,  MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Declare my top level variables
    var selectedPin : Pin!
    var photos : Photo!
    var page: Int = 1 // Keep track of what page we want to pull from API
    var numOfPhotos: Int = 0
    var numOnScreen: Int = 12 //We have screen space for 12. Enable new collection after that number is reached
    
    
    // Declare my outlooks
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollection: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noImagesFound: UILabel!
    
    
    //View Did/Will/etc functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Zoom into mappod
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let coords = selectedPin!.coordinate
        
        let region = MKCoordinateRegion(center: coords
            , span: span)

        mapView.setRegion(region, animated: true)
        
        // Setup the pin as well
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = coords
        self.mapView.addAnnotation(pinAnnotation)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let coords = selectedPin!.coordinate
        
        if selectedPin.photos.count > 0 {
          print("We have images!")
        } else {
            print("No pictures found. Calling Flickr")
            
            let lat = coords.latitude
            let lng = coords.longitude
            
            // Start activity indicator
            activityIndicator.startAnimating()
            getImagesFromFlickr(lat, lng: lng, page: self.page)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveContext()
    }
    // End of view will/did/etc funcs

    
    
    // Core data related funcs
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func deleteAllPics(){
        for photo in selectedPin.photos {
            sharedContext.deleteObject(photo)
        }
    }
    //End of core data

   
    
    // Flickr related functions
    func getImagesFromFlickr(lat: CLLocationDegrees, lng: CLLocationDegrees, page: Int) {
        
        FlickrClient.sharedInstance().getImages(lat, lng: lng, page: page){
            (json, error) in
            
            if error != "" {
                print("Error during network activity \(error)")
            }
            
            if (!json.isEmpty) {
                
                //Save image
                // print("Found this many images \(json.count)")
                
                for (_, subJson):(String, JSON) in json {
                    
                    let obj = subJson.object
                    let id =  obj.valueForKey("id")!
                    
                    if let url =  obj.valueForKey("url_l") {
                        
                        // print("key: \(key) id: \(id) url:  \(url)")
                        let dictionary : [String: AnyObject] = [ "id" : id, "url" : url]
                        
                        // Parse through each and save it to context
                        let photo = Photo(dictionary: dictionary, insertIntoMangedObjectContext: self.sharedContext)
                        
                        //Assign pin to photo
                        photo.pin = self.selectedPin
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView.reloadData()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.hidden = true
                        }
                    }
                }
            } else {
                // No photos display info
                dispatch_async(dispatch_get_main_queue()) {
                    self.noImagesFound.hidden = false
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                }
            }
        }
    }
    
    func downloadFromFlickr(photo: Photo!, cell: PhotoCell!){
        // Start the task that will eventually download the image
        FlickrClient.sharedInstance().taskForImage(photo.url) { data, error in
            
            if let data = data {
                let image = UIImage(data: data)
                
                // cache
                photo.image = image
                
                // update the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    cell.imageView!.image = image
                    cell.loadingIndicator.stopAnimating()
                    cell.loadingIndicator.hidden = true
                }
            }
        }
    }
    
    // End of Flickr Functions
    
    
    
    // Collection View Functions s
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = selectedPin.photos[indexPath.item]
        var photoImage = UIImage(named: "placeholder")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
        cell.loadingIndicator.hidden = false
        cell.loadingIndicator.startAnimating()
        cell.imageView.image = nil
        
        //Set the photo image
        if photo.image != nil {
            photoImage = photo.image
            cell.loadingIndicator.stopAnimating()
            cell.loadingIndicator.hidden = true
        }
        else
        {
            downloadFromFlickr(photo, cell: cell)
        }
        
        // Check where we are at.
        self.numOfPhotos += 1
        self.enableCollectionButton()
        
        cell.imageView.image = photoImage
        return cell
    }
 
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let photo = selectedPin.photos[indexPath.item]
        photo.pin = nil
        
        let imageIdentifier: String = "\(photo.imageID).jpg"
        
        // Delete it from core data
        collectionView.deleteItemsAtIndexPaths([indexPath])
        sharedContext.deleteObject(photo)
        
        photo.removeFromDocumentsDirectory(imageIdentifier)
        
        self.saveContext()
    }
    
    // End of collection view functions
    
    
    // Action buttons
    func enableCollectionButton() {
        
        if numOfPhotos == numOnScreen {
            newCollection.enabled = true
        }
    }
    
    @IBAction func newCollectionStart(sender: AnyObject) {
        
        print("New collection requested")
        deleteAllPics() // Delete picks
        self.page++ //Increase to the next page
        getImagesFromFlickr(selectedPin.lat, lng: selectedPin.lng, page: page)
        
    }
    
    // End of action buttons
    

    
    //Customize UIViewColleciton - Done in storyboard now
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Take up 1/3 of the with
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        
        if let frameWidth: CGFloat = self.collectionView.frame.size.width {
            if frameWidth != 0 {
                let width = floor(frameWidth/3)
                layout.itemSize = CGSize(width: width, height: width)
                collectionView.collectionViewLayout = layout
            }
        }
        

    }
    // End of customization

    
}