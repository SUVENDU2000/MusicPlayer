//
//  ImageManager.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import Foundation
import UIKit

class ImageLoadView : UIImageView {
    
    let cachedImage = NSCache<AnyObject, UIImage>()
    
    // Method for cacheing Images for reuse without fetching from server again
    func getImage(imageURL : URL) {
        
        if let cachedImage = self.cachedImage.object(forKey: imageURL as AnyObject) {
            self.image = cachedImage
//            print("Image is loaded from Cached")
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let imageData = try? Data(contentsOf: imageURL) {
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self?.cachedImage.setObject(image, forKey: imageURL as AnyObject)
                        self?.image = image
//                        print("Image is loaded from server")
                    }
                }
            }
            
        }
    }
}
