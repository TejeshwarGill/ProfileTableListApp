//
//  ImageCache.swift
//  ProfileViewApp
//
//  Created by Tejeshwar Singh Gill on 24/2/19.
//  Copyright © 2019 GILL/Samsung. All rights reserved.
//

import UIKit

public typealias Image = UIImage
/// The `ImageRequestCache` protocol defines a set of APIs for adding, removing and fetching images from a cache.
public protocol ImageRequestCache {
    /// Adds the image to the cache using an identifier created from the request and identifier.
    func add(_ image: Image, for request: URLRequest, withIdentifier identifier: String?)
    
    /// Removes the image from the cache using an identifier created from the request and identifier.
    func removeImage(for request: URLRequest, withIdentifier identifier: String?) -> Bool
    
    /// Returns the image from the cache associated with an identifier created from the request and identifier.
    func image(for request: URLRequest, withIdentifier identifier: String?) -> Image?
    
    //Adds the image to the cache with the given identifier.
    func add(_ image: Image, withIdentifier identifier: String)
    
    //Returns the image in the cache associated with the given identifier.
    func image(withIdentifier identifier: String) -> Image?
}
class ImageCache: ImageRequestCache {
    class CachedImage {
        let image: Image
        let identifier: String
        var lastAccessDate: Date
        
        init(_ image: Image, identifier: String) {
            self.image = image
            self.identifier = identifier
            self.lastAccessDate = Date()
        }
        
        func accessImage() -> Image {
            lastAccessDate = Date()
            return image
        }
    }
    
    private let synchronizationQueue: DispatchQueue
    private var cachedImages: [String: CachedImage]
    
    // MARK: Initialization
    public init () {
        
        
        self.cachedImages = [:]
        
        self.synchronizationQueue = {
            let name = String(format: "org.test.mvvm-%08x%08x", arc4random(), arc4random())
            return DispatchQueue(label: name, attributes: .concurrent)
        }()
        
        #if os(iOS) || os(tvOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.removeAllImages),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Add Image to Cache
    
    /// Adds the image to the cache using an identifier created from the request and optional identifier.
    public func add(_ image: Image, for request: URLRequest, withIdentifier identifier: String? = nil) {
        let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
        add(image, withIdentifier: requestIdentifier)
    }
    
    /// Adds the image to the cache with the given identifier.
    ///
    /// - parameter image:      The image to add to the cache.
    /// - parameter identifier: The identifier to use to uniquely identify the image.
    public func add(_ image: Image, withIdentifier identifier: String) {
        synchronizationQueue.async(flags: [.barrier]) {
            let cachedImage = CachedImage(image, identifier: identifier)
            self.cachedImages[identifier] = cachedImage
        }
        
        synchronizationQueue.async(flags: [.barrier]) {
            var sortedImages = self.cachedImages.map { $1 }
            
            sortedImages.sort {
                let date1 = $0.lastAccessDate
                let date2 = $1.lastAccessDate
                
                return date1.timeIntervalSince(date2) < 0.0
            }
        }
    }
    
    
    
    // MARK: Remove Image from Cache
    
    /// Removes the image from the cache using an identifier created from the request and optional identifier.
    ///
    @discardableResult
    public func removeImage(for request: URLRequest, withIdentifier identifier: String?) -> Bool {
        let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
        return removeImage(withIdentifier: requestIdentifier)
    }
    
    /// Removes all images from the cache created from the request.
    ///
    /// - parameter request: The request used to generate the image's unique identifier.
    ///
    /// - returns: `true` if any images were removed, `false` otherwise.
    @discardableResult
    private func removeImages(matching request: URLRequest) -> Bool {
        let requestIdentifier = imageCacheKey(for: request, withIdentifier: nil)
        var removed = false
        
        synchronizationQueue.sync {
            for key in self.cachedImages.keys where key.hasPrefix(requestIdentifier) {
                if let _ = self.cachedImages.removeValue(forKey: key) {
                    removed = true
                }
            }
        }
        
        return removed
    }
    
    /// Removes the image from the cache matching the given identifier.
    ///
    /// - parameter identifier: The unique identifier for the image.
    ///
    /// - returns: `true` if the image was removed, `false` otherwise.
    @discardableResult
    private func removeImage(withIdentifier identifier: String) -> Bool {
        var removed = false
        
        synchronizationQueue.sync {
            if self.cachedImages.removeValue(forKey: identifier) != nil {
                removed = true
            }
        }
        
        return removed
    }
    
    /// Removes all images stored in the cache.
    ///
    /// - returns: `true` if images were removed from the cache, `false` otherwise.
    @discardableResult @objc
    private func removeAllImages() -> Bool {
        var removed = false
        
        synchronizationQueue.sync {
            if !self.cachedImages.isEmpty {
                self.cachedImages.removeAll()
                removed = true
            }
        }
        
        return removed
    }
    
    // MARK: Fetch Image from Cache
    
    /// Returns the image from the cache associated with an identifier created from the request and optional identifier.
    ///
    /// - parameter request:    The request used to generate the image's unique identifier.
    /// - parameter identifier: The additional identifier to append to the image's unique identifier.
    ///
    /// - returns: The image if it is stored in the cache, `nil` otherwise.
    public func image(for request: URLRequest, withIdentifier identifier: String? = nil) -> Image? {
        let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
        return image(withIdentifier: requestIdentifier)
    }
    
    /// Returns the image in the cache associated with the given identifier.
    ///
    /// - parameter identifier: The unique identifier for the image.
    ///
    /// - returns: The image if it is stored in the cache, `nil` otherwise.
    public func image(withIdentifier identifier: String) -> Image? {
        var image: Image?
        
        synchronizationQueue.sync {
            if let cachedImage = self.cachedImages[identifier] {
                image = cachedImage.accessImage()
            }
        }
        
        return image
    }
    
    // MARK: Image Cache Keys
    
    /// Returns the unique image cache key for the specified request and additional identifier.
    ///
    /// - parameter request:    The request.
    /// - parameter identifier: The additional identifier.
    ///
    /// - returns: The unique image cache key.
    private func imageCacheKey(for request: URLRequest, withIdentifier identifier: String?) -> String {
        var key = request.url?.absoluteString ?? ""
        
        if let identifier = identifier {
            key += "-\(identifier)"
        }
        
        return key
    }
}
