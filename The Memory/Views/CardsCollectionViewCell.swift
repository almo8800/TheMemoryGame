//
//  CardCollectionViewCell.swift
//  The Memory
//
//  Created by Andrei on 14/6/23.
//

import UIKit

class CardsCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "CardsCollectionViewCell"
    
    var cardId: String!
    
    var openImageView = UIImageView()
    var closeImageView = UIImageView(image: UIImage(named: "iphone_pattern"))
    
    
    var isFlipped: Bool!
    var isMatched: Bool!
    var isActive: Bool = true
    
    func configureCell(_ image: UIImage) {
        
        self.isFlipped = false
        self.isMatched = false
        self.isActive = true
        
        closeImageView.image = UIImage(named: "iphone_pattern")
      
        closeImageView.layer.masksToBounds = true
        closeImageView.alpha = 1.0
        closeImageView.layer.cornerRadius = 6
        
        openImageView.image = image
        openImageView.layer.cornerRadius = 6
        openImageView.layer.masksToBounds = true
        openImageView.alpha = 1.0
        layer.cornerRadius = 10
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 2.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.5
        
        cardId = image.description
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
     
        openImageView.frame = contentView.frame
        openImageView.contentMode = .scaleToFill
        closeImageView.frame = contentView.frame
        closeImageView.contentMode = .scaleToFill
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
