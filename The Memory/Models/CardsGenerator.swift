//
//  CardsGenerator.swift
//  The Memory
//
//  Created by Andrei on 15/6/23.
//

import Foundation
import UIKit
import Photos

enum HardLevel: Int {
    case four = 4
    case five = 5
    
    static func allValues() -> [String] {
        return [four, five].map({$0.description})
    }
    
    public var description: String {
        switch self {
        case .four:
            return "four"
        case .five:
            return "five"
        }
    }
    
}

class CardsGenerator {
    
    var assetsFromLibrary: [PHAsset] = []
    var photosFromLibrary: [UIImage] = []
    
    static let shared = CardsGenerator(level: HardLevel.four)
    
    private init(level: HardLevel) {
        fetchAssetsFromDevice()
        convertAssetsToPhotos()
        fillArrayForGame(level: level.rawValue)
    }
    
    var arrayForGame: [UIImage] = []
    
    class CardA {
        var card: Card!
        var index: Int!
    }
    
    func fillArrayForGame(level: Int) {
       var array: [UIImage] = []
       let numberOfCards = level * level
       
        
        while array.count != numberOfCards {
            if let element = photosFromLibrary.randomElement() {
                if !array.contains(element) {
                    array.append(element)
                    array.append(element)
                }
                else {
                    print("Double photo detected")
                }
            }
        }
        
        
//        for _ in 0...maxIndex {
//            if let element = photosFromLibrary.randomElement() {
//                array.append(element)
//                array.append(element)
//            }
//        }
        
        array.shuffle()
        arrayForGame = array
        print("HERE IT IS")
        print(arrayForGame)
        
        return
    }
    
    func fetchAssetsFromDevice() {
        
        let semaphore = DispatchSemaphore(value: 0)
        
    
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            
            if status == .authorized {
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.fetchLimit = 100
                
                
                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                print(assets.count)
                assets.enumerateObjects { (object, _, _) in
                    print(object)
                    self?.assetsFromLibrary.append(object)
                }
            }
            
           
            
            semaphore.signal()
            
        }
        
        semaphore.wait()
    }
    
    func convertAssetsToPhotos() {
        print("photos from assets is \(photosFromLibrary.count)")
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        for asset in assetsFromLibrary { // не нужен ли тут weak self?
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    self.photosFromLibrary.append(image)
                }
            }
        }
        
        print("photos from assests is \(photosFromLibrary.count)")
        
 
       
    
        
    }
    
}

