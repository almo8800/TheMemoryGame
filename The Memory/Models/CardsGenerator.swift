//
//  CardsGenerator.swift
//  The Memory
//
//  Created by Andrei on 15/6/23.
//

import Foundation
import UIKit
import Photos
import AVFoundation

enum HardLevel: Int {
    case fourXfour = 16
    case fourXsix = 24
    
    static func allValues() -> [String] {
        return [fourXfour, fourXsix].map({$0.description})
    }
    
    public var description: String {
        switch self {
        case .fourXfour:
            return "4x4"
        case .fourXsix:
            return "4x6"
        }
    }
    
}

class CardsGenerator {
    
    var assetsFromLibrary: [PHAsset] = []
    var photosFromLibrary: [UIImage] = []
    
    var thumbnails: [UIImage] = []
    
    var cardsNumber: Int = 16 {
        didSet {
            print("Cardsnumber now is \(cardsNumber)")
            fillArrayForGame()
            print(arrayForGame.count)
        }
    }
    
    static let shared = CardsGenerator()
    
    private init() {
        fetchAssetsFromDevice()
        convertAssetsToPhotos()
        fillArrayForGame()
        
    }
    
    var arrayForGame: [UIImage] = []

    
    func fillArrayForGame() {
       var array: [UIImage] = []
       let numberOfCards = cardsNumber
       
    
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
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",                                           PHAssetMediaType.image.rawValue,
                                                     PHAssetMediaType.video.rawValue)
                fetchOptions.fetchLimit = 100
                
                let assets = PHAsset.fetchAssets(with: fetchOptions)
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

