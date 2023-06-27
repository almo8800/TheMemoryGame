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

enum DifficultyLevel {
    case fourXfour
    case fourXsix
    
    static func allValues() -> [String] {
        return [fourXfour, fourXsix].map({$0.description})
    }
    public var totalNumberOfCards: Int {
        return numberOfRows*numberOrColumns
    }
    public var numberOfRows: Int {
        switch self {
        case .fourXfour:
            return 4
        case .fourXsix:
            return 6
        }
    }
    public var numberOrColumns: Int {
        switch self {
        case .fourXfour:
            return 4
        case .fourXsix:
            return 4
        }
    }
    public var description: String {
        return "\(numberOrColumns)X\(numberOfRows)"
    }
}



class CardsGenerator {
    var assetsFromLibrary: [PHAsset] = []
    var photosFromLibrary: [UIImage] = []
    var difficultyLevel = DifficultyLevel.fourXfour
    static let shared = CardsGenerator()
    private init() {}
    
    public func checkAccessToLib(completion: @escaping (PHAuthorizationStatus, Int) -> Void) {
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            
            var assetsNumber = 0
            
            switch status {
            case .authorized:
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                                     PHAssetMediaType.image.rawValue,
                                                     PHAssetMediaType.video.rawValue)
                fetchOptions.fetchLimit = 100
                let assets = PHAsset.fetchAssets(with: fetchOptions)
                assetsNumber = assets.count
                
                completion(status, assetsNumber)
                
            case .denied, .notDetermined, .restricted, .limited:
                completion(status, assetsNumber)
            @unknown default:
                completion(.notDetermined, assetsNumber)
            }
        }
    }
    
    public func generateImagesForGame(completion: @escaping ([UIImage], PHAuthorizationStatus) -> Void )  {
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            switch status {
            case .authorized:
                guard let self = self else { return }
                var arrayOfImage: [UIImage] = []
                self.fetchAssets { array in
                    arrayOfImage = array
                }
                var arrayForGame = self.fillArrayForGame(arrayOfConvertedImages: arrayOfImage)
                arrayForGame.shuffle()
                completion(arrayForGame, status)
                
            case .denied, .limited, .notDetermined, .restricted:
                completion([], status)
                
            @unknown default:
                completion([], status)
            }
        }
    }
    
    
    private func fetchAssets(completion: @escaping ([UIImage]) -> Void ) {
        var convertedImagesFromAssets: [UIImage] = []
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                             PHAssetMediaType.image.rawValue,
                                             PHAssetMediaType.video.rawValue)
        fetchOptions.fetchLimit = 100
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        print(assets.count)
        
        assets.enumerateObjects { (object, index, _) in
            
            print(object.mediaType)
            switch object.mediaType {
            case .image:
                self.convertFromPhotoAssets(object: object) { image in
                    convertedImagesFromAssets.append(image)
                }
            case .video:
                self.convertFromVideoAssets(asset: object) { image in
                    
                    convertedImagesFromAssets.append(image)
                }
                
            case .audio, .unknown:
                assertionFailure("wrong type")
                
            @unknown default:
                assertionFailure("wrong type")
            }
        }
        
        completion(convertedImagesFromAssets)
    }
    
    private func convertFromVideoAssets(asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        print("we catch video")
        let asset = asset
        let options = PHVideoRequestOptions()
        options.version = .original
        
        let group = DispatchGroup()
        group.enter()
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: { (avAsset, _, _) in
            guard let avAsset = avAsset else {
                group.leave()
                return }
            let generator = AVAssetImageGenerator(asset: avAsset)
            generator.appliesPreferredTrackTransform = true
            let timeScale = CMTimeScale(NSEC_PER_SEC)
            let time = CMTime(seconds: Double.random(in: 0...60), preferredTimescale: timeScale)
            guard let imageRef = try? generator.copyCGImage(at: time, actualTime: nil) else {
                group.leave()
                return }
            let image = UIImage(cgImage: imageRef)
            completion(image)
            group.leave()
        })
        group.wait()
    }
    
    private func convertFromPhotoAssets(object: PHAsset, completion: @escaping (UIImage) -> Void) {
        print("we catch image")
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        imageManager.requestImage(for: object, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { image, _ in
            if let image = image { completion(image) }
        }
        return
    }
    
    
    private func fillArrayForGame(arrayOfConvertedImages: [UIImage]) -> [UIImage] {
        
        var arrayImagesForGame: [UIImage] = []
        
        let numberOfCycles = difficultyLevel.totalNumberOfCards / 2
        var arrayOfConvertedImages = arrayOfConvertedImages
        arrayOfConvertedImages.shuffle()
        
        for _ in 0..<numberOfCycles {
            
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
    
}

