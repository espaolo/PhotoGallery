//
//  UIImageView+Download.swift
//  PhotoGallery
//
//  Created by Admin on 20/06/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//


import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()


extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        if url == nil {return}
        self.image = nil
        imageCache.countLimit = 100

        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cachedImage
            return
        }

        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            }

        }).resume()
    }
}
