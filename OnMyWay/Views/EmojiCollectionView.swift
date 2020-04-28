//
//  EmojiCollectionView.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 02/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

class EmojiCell: UICollectionViewCell {
    
    static let cellId = "EmojiCell"
    var emojiImageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var emojiFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
        emojiFrame.origin.x = frame.size.width/2 - 20
        emojiFrame.origin.y = frame.size.height/2 - 20
        emojiImageView = UIImageView(frame: emojiFrame)
        self.addSubview(emojiImageView)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EmojiCollection: UICollectionView {
    
    
    public var didSelectEmoji:((_ emoji:OMWEmoji, _ emojiView:UIImageView)->())?
    
    fileprivate var emojies:[OMWEmoji]!
    fileprivate let spaceCellToEdge:CGFloat = 2
    fileprivate let spaceBetweenCells:CGFloat = 2
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        let images = [#imageLiteral(resourceName: "Omw"), #imageLiteral(resourceName: "LMAO"), #imageLiteral(resourceName: "Lion"), #imageLiteral(resourceName: "Poop"), #imageLiteral(resourceName: "Getting_Laid"), #imageLiteral(resourceName: "Grimacing3"), #imageLiteral(resourceName: "Glacier"), #imageLiteral(resourceName: "Girafe"), #imageLiteral(resourceName: "LMAO"), #imageLiteral(resourceName: "Lion"), #imageLiteral(resourceName: "Poop"), #imageLiteral(resourceName: "Getting_Laid"), #imageLiteral(resourceName: "Grimacing3"), #imageLiteral(resourceName: "Glacier"), #imageLiteral(resourceName: "Girafe")]
        emojies = [OMWEmoji]()
        for im in images {
            emojies.append(OMWEmoji(image: im))
        }
        emojies[0].isOnMyWay = true
        
        super.init(frame: frame, collectionViewLayout: layout)
        self.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.cellId)
        self.delegate = self
        self.dataSource = self

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EmojiCollection: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(emojies.count, 12) //TODO: implement the paging if more emojies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.cellId, for: indexPath) as! EmojiCell
        
        cell.emojiImageView.image = emojies[indexPath.row].image
        
        return cell
        
    }
    
    
    
}

extension EmojiCollection: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
            didSelectEmoji?(emojies[indexPath.row], cell.emojiImageView)
        }
        
    }
    
}

extension EmojiCollection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let columnNb:CGFloat = 4
        let rowNb:CGFloat = 3
        
        let cellWidth:CGFloat = (collectionView.frame.size.width - 2 * spaceCellToEdge - (columnNb - 1) * spaceBetweenCells)/columnNb
        let cellHeight = (collectionView.frame.size.height - 2 * spaceCellToEdge - (rowNb - 1) * spaceBetweenCells)/rowNb
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spaceCellToEdge, left: spaceCellToEdge, bottom: spaceCellToEdge, right: spaceCellToEdge)
    }
    
}

