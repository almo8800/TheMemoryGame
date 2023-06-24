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

enum DifficultyLevel: Int {
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
    
    var cardsNumber: Int = 16 {
        didSet {
            print("Cardsnumber now is \(cardsNumber)")
            //fillArrayForGame()
            //print(arrayForGame.count)
        }
    }
    
    static let shared = CardsGenerator()
    
    private init() {
        
        //fetchAssetsFromDevice()
       //fillArrayForGame()
    }
    
    //var arrayForGame: [UIImage] = []
    
    
    func fillArrayForGame(arrayOfConvertedImages: [UIImage]) -> [UIImage] {
      
        var arrayImagesForGame: [UIImage] = []
        
        let numberOfCycles = cardsNumber / 2
        var arrayOfConvertedImages = arrayOfConvertedImages
        arrayOfConvertedImages.shuffle()
        
        for index in 0..<numberOfCycles {
            
            if let randomIndex = arrayOfConvertedImages.indices.randomElement() {
                let element = arrayOfConvertedImages.remove(at: randomIndex)
                arrayImagesForGame.append(element)
                arrayImagesForGame.append(element)
            } else {
                print("problem")
            }
        }
        
        
        return arrayImagesForGame
    }
    
    func fetchAssetsFromDevice(completion: @escaping ([UIImage]) -> Void)  {
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            
            switch status {
            case .authorized:
                guard let self = self else { return }
                let assetsFromLibrary = self.getAssets()
                let arrayOfImage = self.convertAssetsToPhotos(assets: assetsFromLibrary)
                let arrayForGame = self.fillArrayForGame(arrayOfConvertedImages: arrayOfImage)
                completion(arrayForGame)
            case .denied:
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
                completion([])
                
            case .notDetermined, .limited, .restricted:
                completion([])
                
            @unknown default:
                completion([])
            }
        }
    }
    
    func getAssets() -> [PHAsset] {
        
        //let semaphore = DispatchSemaphore(value: 0)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",                                           PHAssetMediaType.image.rawValue,
                                             PHAssetMediaType.video.rawValue)
        fetchOptions.fetchLimit = 100
        
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        print(assets.count)
        
        var fetchedAssets = [PHAsset]()
        
        assets.enumerateObjects { [self] (object, index, _) in
            fetchedAssets.append(object)
        }
        return fetchedAssets
    }
    
    func convertAssetsToPhotos(assets: [PHAsset]) -> [UIImage] {
        print("photos from assets is \(photosFromLibrary.count)")
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var convertedAssets: [UIImage] = []
        
        for asset in assets { // не нужен ли тут weak self?
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    convertedAssets.append(image)
                }
            }
        }
        
      
        return convertedAssets
    }
}

