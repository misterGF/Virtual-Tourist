//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Gil Ferreira on 10/25/15.
//  Copyright © 2015 Gil Ferreira. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {


    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var imageName: String = ""
}
