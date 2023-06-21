//
//  CardsCollectionView.swift
//  The Memory
//
//  Created by Andrei on 14/6/23.
//

import UIKit

class CardsCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var cardsGenerator: CardsGenerator
    var imageArray: [UIImage] = []
    
    var firstFlippedCardTag: Int?
    var firstFlippedCardIndex: Int?
    
    var openCards = 0
    var gameVCdelegate: GameVCDelegate?
    

    init(cardsGenerator: CardsGenerator = .shared) {
        self.cardsGenerator = cardsGenerator
        
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        
        imageArray = cardsGenerator.arrayForGame
        
        
        isScrollEnabled = false
        backgroundColor = #colorLiteral(red: 0.9749920964, green: 0.9101356864, blue: 0.9532486796, alpha: 1)
        
        delegate = self
        dataSource = self
        
        register(CardsCollectionViewCell.self, forCellWithReuseIdentifier: "CardsCollectionViewCell")
        
        translatesAutoresizingMaskIntoConstraints = false
        //layout.minimumLineSpacing = 10
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardsCollectionViewCell", for: indexPath) as? CardsCollectionViewCell else { fatalError("Cell not found")}
        
        cell.tag = indexPath.row
        cell.closeImageView.alpha = 1
        cell.closeImageView.layer.cornerRadius = 6
        cell.closeImageView.layer.masksToBounds = true
        cell.openImageView.alpha = 1
        cell.openImageView.layer.cornerRadius = 6
        cell.openImageView.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
       // cell.layer.masksToBounds = true
        
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 1, height: 2.0)
        cell.layer.shadowRadius = 3.0
        cell.layer.shadowOpacity = 0.5
        
        
        let image = imageArray[indexPath.row]
        cell.configureCell(image)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let cell = collectionView.cellForItem(at: indexPath) as! CardsCollectionViewCell
        
        print(indexPath.section)
        print(indexPath.item)
        print("tag os \(cell.tag)")
        
        // ЕСЛИ КАРТА НЕ ПЕРЕВËРНУТА
        if cell.isFlipped == false {
            
            cell.flip()
            cell.isFlipped = true
            //cardArray[indexPath.row].isFlipped = true
            
            // определяем первая это карта или вторая
            if firstFlippedCardIndex == nil {
                
                firstFlippedCardTag = cell.tag
                firstFlippedCardIndex = indexPath.row
            } else {
                // если вторая
                checkForMatches(secondFlippedCardTag: cell.tag)
            }
            
        } else {
            
            cell.flipBack(timeSpeed: 0.3)
            cell.isFlipped = false
        }
    }
    //
    func checkForMatches(secondFlippedCardTag: Int) {

        //let cardOneCell = self.viewWithTag(firstFlippedCardTag!) as? CardsCollectionViewCell // проблема что тут получаю nil
        let indexPathOfOneCell = IndexPath(row: firstFlippedCardIndex!, section: 0)
        let cardOneCell = self.cellForItem(at: indexPathOfOneCell) as? CardsCollectionViewCell

        let indexPathOfTwoCell = IndexPath(row: secondFlippedCardTag, section: 0)
        let cardTwoCell = self.cellForItem(at: indexPathOfTwoCell) as? CardsCollectionViewCell

//        let cardOne = cardArray[firstFlippedCardTag!.row]
//        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        let cardOneName = cardOneCell?.numberLabel.text
        let cardTwoName = cardTwoCell?.numberLabel.text

    
       
        
        if cardOneName == cardTwoName, indexPathOfOneCell != indexPathOfTwoCell {
        
           cardOneCell?.isMatched = true
           cardTwoCell?.isMatched = true
            
           //remove the cells
           cardOneCell?.remove()
           cardTwoCell?.remove()
            
            cardOneCell?.isActive = false
            cardTwoCell?.isActive = false
//        
            
           firstFlippedCardTag = nil
           firstFlippedCardIndex = nil
            
            openCards += 2
            print("open cards = \(openCards)")
            
            if openCards == 16 {
                gameVCdelegate?.endGame()
                
            }
            
            
            
       } else {
           
           cardOneCell?.isFlipped = false
           cardTwoCell?.isFlipped = false
           
           cardOneCell?.flipBack(timeSpeed: 0.3)
           cardTwoCell?.flipBack(timeSpeed: 0.3)
           
           firstFlippedCardTag = nil
           firstFlippedCardIndex = nil
           
       }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {


        let width = collectionView.frame.width / 5 + 10
        let itemSize = CGSize(width: width, height: width * 1.2)

        return itemSize
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = self.cellForItem(at: indexPath) as? CardsCollectionViewCell else  { fatalError("Cell not found") }
        return cell.isActive
    }
    

    
    func setBackAllCellLogic() {
        let cellQuantity = imageArray.count
        for index in 0...cellQuantity-1 {
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

// reload data для определенных индексов
// difable data source
