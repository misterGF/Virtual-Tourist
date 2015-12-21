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
    
    let FLICKR_API_KEY: String = "9f659d12912670b03e2e67b7086185de"
    let FLICKR_URL: String = "https://api.flickr.com/services/rest/"
    let SEARCH_METHOD: String = "flickr.photos.search"
    let EXTRAS: String = "url_l"
    let FORMAT_TYPE: String = "json"
    let JSON_CALLBACK:Int = 1
    let PER_PAGE: Int = 21
    
    override init(){
        super.init()
    }
    
    func getImages(lat: Double, lng: Double, page: Int, completionHandler: (result: JSON!, error: String?) -> Void) {

        Alamofire.request(.GET, FLICKR_URL , parameters: ["method": SEARCH_METHOD, "api_key": FLICKR_API_KEY, "lat": lat, "lon": lng, "extras": EXTRAS, "format": FORMAT_TYPE, "per_page": PER_PAGE, "page": page ,"nojsoncallback": JSON_CALLBACK])
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
    
    func taskForImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) {
        
        Alamofire.request(.GET, filePath).response { (request, response, data, error) in
            
            if let error = error {
                completionHandler(imageData: nil, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
    }
           
    //Singleton
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    //Image cache
    struct Cache {
        static let imageCache = ImageCache()
    }
}