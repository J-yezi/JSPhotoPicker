//
//  JSPhotoViewLayout.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/23/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

class JSPhotoViewFlowLayout: UICollectionViewFlowLayout {
    
    var itemsPerRow: CGFloat = 4 {
        didSet {
            let width = (kScreenWidth - (itemsPerRow - 1) * minimumInteritemSpacing) / itemsPerRow
            itemSize = CGSize(width: width, height: width)
        }
    }
    
    override init() {
        super.init()
        minimumLineSpacing = 1
        minimumInteritemSpacing = minimumLineSpacing
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self.classForCoder.description()) - deinit")
    }
    
    override func prepare() {
        scrollDirection = .vertical
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
