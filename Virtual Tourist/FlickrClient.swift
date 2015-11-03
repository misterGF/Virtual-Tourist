//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Gil Ferreira on 11/2/15.
//  Copyright © 2015 Gil Ferreira. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FlickrClient: NSObject {
    
    //Example URL https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=fe61bca18be65e8a599397fca9bfba28&lat=42.36&lon=-71.03&extras=url_l&format=json&nojsoncallback=1
    
    let FLICKR_API_KEY: String = "fe61bca18be65e8a599397fca9bfba28"
    let FLICKR_URL: String = "https://api.flickr.com/services/rest/"
    let SEARCH_METHOD: String = "flickr.photos.search"
    let EXTRAS: String = "url_l"
    let FORMAT_TYPE: String = "json"
    let JSON_CALLBACK:Int = 1
    
    override init(){
        super.init()
    }
    
    func GetImages(lat: Double, lng: Double, completionHandler: (result: JSON!, error: String?) -> Void) {

        Alamofire.request(.GET, FLICKR_URL , parameters: ["method": SEARCH_METHOD, "api_key": FLICKR_API_KEY, "lat": lat, "lon": lng, "extras": EXTRAS, "format": FORMAT_TYPE, "nojsoncallback": JSON_CALLBACK])
            .responseJSON { response in

                let dataFromNetworking = response.data
                
                if(dataFromNetworking != nil){
                    
                    let json = JSON(data: dataFromNetworking!)
                    
                    if let imageUrls: JSON = json["photos"]["photo"] {
 
                        completionHandler(result: imageUrls, error: "")
                        return
                    }
                }
            }
    }
    
    func urlToImage(imageString: String){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                let url = NSURL(string: imageString)
                let imageData = NSData(contentsOfURL: url!)
                
                if(imageData != nil){
                    //self.imageView.image = UIImage(data: imageData!)
                    
                } else {
                    //self.urlToImageView(imageString)
                }
                
            });
        });
    }
    
    //Singleton
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
}