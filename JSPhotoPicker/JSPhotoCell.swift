//
//  JSPhotoCell.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/30/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

class JSPhotoCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imageView
    }()
    lazy var gifLabel: UILabel = {
        let gifLabel = UILabel(frame: CGRect(x: 0, y: self.bounds.size.height - 20, width: self.bounds.size.width, height: 20))
        gifLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        gifLabel.text = "gif"
        gifLabel.textColor = UIColor.white
        return gifLabel
    }()
    var asset: PHAsset! {
        didSet {
            let filename = asset.value(forKey: "filename") as! String
            if filename.range(of: "GIF") != nil {
                gifLabel.isHidden = false
            }else {
                gifLabel.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(imageView)
        addSubview(gifLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
