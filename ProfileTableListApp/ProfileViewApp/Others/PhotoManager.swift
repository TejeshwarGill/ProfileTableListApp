//
//  PhotoManager.swift
//  ProfileViewApp
//
//  Created by Tejeshwar Singh Gill on 24/2/19.
//  Copyright © 2019 GILL/Samsung. All rights reserved.
//

import UIKit


class PhotosManager {
    
    let imageCache = ImageCache()
    
    //MARK: - Image Downloading
    
    func retrieveImage(for url: String, completion: @escaping (UIImage?) -> Void) {
        guard let urlInstance = URL.init(string: url) else {
            completion(nil)
            return
        }
        self.loadImage(url: urlInstance) { (image) in
            completion(image)
            self.cache(image, for: url)
        }
    }
    
    //MARK: - Image Caching
    
    func cache(_ image: Image, for url: String) {
        imageCache.add(image, withIdentifier: url)
    }
    
    func cachedImage(for url: String) -> Image? {
        return imageCache.image(withIdentifier: url)
    }
    
    private func loadImage(url: URL, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            if let responseData = try? Data(contentsOf: url) {
                if let image = UIImage.init(data: responseData){
                    completion(image)
                }
            }
        }
    }
    
}
