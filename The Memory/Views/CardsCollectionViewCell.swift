//
//  CardCollectionViewCell.swift
//  The Memory
//
//  Created by Andrei on 14/6/23.
//

import UIKit

class CardsCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "CardsCollectionViewCell"
    
    var numberLabel = UILabel()

    var openImageView = UIImageView()
    var closeImageView = UIImageView(image: UIImage(named: "iphone_pattern"))

    
    var isFlipped: Bool!
    var isMatched: Bool!
    var isActive: Bool = true
   
    
    
    //var card: Card?
    
    func configureCell(_ image: UIImage) {
       // self.card = card
        
        self.isFlipped = false
        self.isMatched = false
        self.isActive = true
     
        openImageView.image = image
        openImageView.alpha = 1.0
        
        closeImageView.image = UIImage(named: "iphone_pattern")
        closeImageView.alpha = 1.0
        
        numberLabel.text = image.description
    }
    
    func flip() {
        UIView.transition(
            from: closeImageView,
            to: openImageView,
            duration: 0.3,
            options: [.transitionFlipFromLeft, .showHideTransitionViews],
            completion: nil)
    }
    
    func flipBack(timeSpeed: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            UIView.transition(
                from: self.openImageView,
                to: self.closeImageView,
                duration: timeSpeed,
                options: [.transitionFlipFromLeft, .showHideTransitionViews],
                completion: nil)
        }
    }
    
    func remove() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
            self.closeImageView.alpha = 0
            self.openImageView.alpha = 0
            self.isActive = false
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        addSubview(openImageView)
        addSubview(closeImageView)
        addSubview(numberLabel)
        numberLabel.frame = CGRect(x: 10, y: 20, width: 45, height: 20)
        numberLabel.backgroundColor = .white
        numberLabel.textColor = .red
        
        openImageView.frame = contentView.frame
        openImageView.contentMode = .scaleToFill
        closeImageView.frame = contentView.frame
        closeImageView.contentMode = .scaleToFill
        
        setCellLayout()

    }
 
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellLayout() {
        
        
        
//        self.contentView.layer.cornerRadius = 8.0
//        self.contentView.layer.borderWidth = 1.0
//        self.contentView.layer.borderColor = UIColor.clear.cgColor
//        self.contentView.layer.masksToBounds = true
//
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        self.layer.shadowRadius = 2.0
//        self.layer.shadowOpacity = 0.5
//        self.layer.masksToBounds = false
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
//    }
    
}



//extension CardsCollectionViewCell {
//
//
//    self.contentView.layer.cornerRadius = 2.0
//    self.contentView.layer.borderWidth = 1.0
//    self.contentView.layer.borderColor = UIColor.clear.cgColor
//    self.contentView.layer.masksToBounds = true
//
//    self.layer.shadowColor = UIColor.black.cgColor
//    self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//    self.layer.shadowRadius = 2.0
//    self.layer.shadowOpacity = 0.5
//    self.layer.masksToBounds = false
//    self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
//}
}
