//
//  CardsCollectionView.swift
//  The Memory
//
//  Created by Andrei on 14/6/23.
//

import UIKit


class CardsCollectionView: UICollectionView {
    
    private var cardsGenerator: CardsGenerator
    var imageArray: [UIImage]? = []
    
    var firstFlippedCardTag: Int?
    var firstFlippedCardIndex: Int?
    
    var openCards = 0 {
        didSet {
            if openCards == imageArray?.count {
                gameVCdelegate?.endGame()
            }
        }
    }
    var gameVCdelegate: GameVCProtocol?
    
    
    init(cardsGenerator: CardsGenerator = .shared) {
        self.cardsGenerator = cardsGenerator
        
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        
       fetchImages()
        
        
        isScrollEnabled = false
        backgroundColor = #colorLiteral(red: 0.9749920964, green: 0.9101356864, blue: 0.9532486796, alpha: 1)
        
        delegate = self
        dataSource = self
        
        register(CardsCollectionViewCell.self, forCellWithReuseIdentifier: "CardsCollectionViewCell")
        
        translatesAutoresizingMaskIntoConstraints = false
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    func fetchImages() {
        cardsGenerator.generateImagesForGame(completion: { array, status in
            
            switch status {
            case .authorized:
                self.imageArray = array
                DispatchQueue.main.async { [weak self] in
                    self?.reloadData()
                }
            case .limited, .denied, .restricted, .notDetermined:
                
                print(status)
            @unknown default:
                fatalError()
            }
        })
    }
    
    func checkForMatches(secondFlippedCardTag: Int) {
        
        let indexPathOfOneCell = IndexPath(row: firstFlippedCardIndex!, section: 0)
        let cardOneCell = self.cellForItem(at: indexPathOfOneCell) as? CardsCollectionViewCell
        
        let indexPathOfTwoCell = IndexPath(row: secondFlippedCardTag, section: 0)
        let cardTwoCell = self.cellForItem(at: indexPathOfTwoCell) as? CardsCollectionViewCell
        
        let cardOneName = cardOneCell?.cardId
        let cardTwoName = cardTwoCell?.cardId
        
        if cardOneName == cardTwoName, indexPathOfOneCell != indexPathOfTwoCell {
            
            cardOneCell?.isMatched = true
            cardTwoCell?.isMatched = true
            
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            cardOneCell?.isActive = false
            cardTwoCell?.isActive = false
            
            firstFlippedCardTag = nil
            firstFlippedCardIndex = nil
            
            openCards += 2
            
        } else {
            
            cardOneCell?.isFlipped = false
            cardTwoCell?.isFlipped = false
            
            cardOneCell?.flipBack(timeSpeed: 0.3)
            cardTwoCell?.flipBack(timeSpeed: 0.3)
            
            firstFlippedCardTag = nil
            firstFlippedCardIndex = nil
        }
    }
    
    func setBackAllCellLogic() {
    
        for index in imageArray!.indices{
            let indexPath = IndexPath(row: index, section: 0)
            let cell = self.cellForItem(at: indexPath) as? CardsCollectionViewCell
            
            cell?.flipBack(timeSpeed: 0)
            cell?.isMatched = false
            cell?.isFlipped = false
            cell?.isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CardsCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardsCollectionViewCell", for: indexPath) as? CardsCollectionViewCell else { fatalError("Cell not found")}
        
        cell.tag = indexPath.row
        let image = imageArray?[indexPath.row]
        cell.configureCell(image!)
        
        return cell
    }
}

extension CardsCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardsCollectionViewCell
        
        if cell.isFlipped == false {
            cell.flip()
            cell.isFlipped = true
            if firstFlippedCardIndex == nil {
                firstFlippedCardTag = cell.tag
                firstFlippedCardIndex = indexPath.row
            } else {
                checkForMatches(secondFlippedCardTag: cell.tag)
            }
        } else {
            cell.flipBack(timeSpeed: 0.3)
            cell.isFlipped = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = self.cellForItem(at: indexPath) as? CardsCollectionViewCell else  { fatalError("Cell not found") }
        return cell.isActive
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       calculateItemSize(collectionView, layout: collectionViewLayout)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       
        let horizontalSpace: CGFloat
        let numberOfColumns = CGFloat(cardsGenerator.difficultyLevel.numberOrColumns)
        
        let spacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        let itemSize = calculateItemSize(collectionView, layout: collectionViewLayout)
        if itemSize.width * (numberOfColumns + 1) < collectionView.frame.width {
            horizontalSpace = (collectionView.frame.width - itemSize.width * numberOfColumns) / 2 - spacing
        } else {
            horizontalSpace = CGFloat(0)
        }

        let insets = UIEdgeInsets(top: 0, left: horizontalSpace, bottom: 0, right: horizontalSpace)
        
        return insets
    }
    
    
    func calculateItemSize(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        let spacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        
        let numberOfColumns = CGFloat(cardsGenerator.difficultyLevel.numberOrColumns)
        let numberOfRows = CGFloat(cardsGenerator.difficultyLevel.numberOfRows)
        
        let width = collectionView.frame.width / numberOfColumns - spacing
        
        let minimumCellHeigh = collectionView.frame.height / numberOfRows - spacing
        
        let height: CGFloat
        
        if collectionView.numberOfItems(inSection: 0) == 16 {
            
            height = width * 1.2
        } else {
            height = width
        }
        
        let finalHeight = min(minimumCellHeigh, height)
        let itemSize = CGSize(width: min(width, finalHeight), height: finalHeight)
        
      
        
        return itemSize
    }
    
   
}

