//
//  JSPhotoCell.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/30/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

protocol JSPhotoCellDelegate: class {
    func chooseImage(cell: JSPhotoCell)
}

class JSPhotoCell: UICollectionViewCell {
    weak var delegate: JSPhotoCellDelegate?
    var indexPath: IndexPath!
    var choosed: Bool = false {
        didSet {
            chooseView.isSelected = choosed
            shadeView.isHidden = !choosed
            chooseView.setImage(choosed ? Image(named: "image-choose") : Image(named: "image-unchoose"), for: .normal)
        }
    }
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    fileprivate lazy var chooseView: UIButton = {
        let chooseView: UIButton = UIButton(frame: CGRect(x: self.bounds.width - 35, y: 0, width: 35, height: 35))
        chooseView.setImage(Image(named: "image-unchoose"), for: .normal)
        chooseView.addTarget(self, action: #selector(self.choose), for: .touchUpInside)
        return chooseView
    }()
    fileprivate lazy var shadeView: UIView = {
        let shadeView: UIView = UIView(frame: self.bounds)
        shadeView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        shadeView.isHidden = true
        return shadeView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        uiSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
}

extension JSPhotoCell {
    fileprivate func uiSet() {
        addSubview(imageView)
        addSubview(shadeView)
        addSubview(chooseView)
    }
    
    @objc fileprivate func choose() {
        delegate?.chooseImage(cell: self)
    }
}
