//
//  JSPreviewCell.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/4/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

class JSPreviewCell: UICollectionViewCell {
    
    var singleTapBlock: (() -> Void)?
    lazy var previewView: JSPreviewView = {
        let previewView = JSPreviewView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        previewView.backgroundColor = UIColor.black
        return previewView
    }()
    var asset: PHAsset! {
        didSet {
            previewView.asset = asset
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black
        addSubview(previewView)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.scalePhoto(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.hideNav))
        addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self.classForCoder.description()) - deinit")
    }
    
    func recoverScrollZoom() {
        previewView.recoverScrollZoom()
    }
    
    func scalePhoto(_ gesture: UITapGestureRecognizer) {
        previewView.scalePhoto(gesture)
    }
    
    func hideNav() {
        singleTapBlock?()
    }
    
}
