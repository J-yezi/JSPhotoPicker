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
    func iCloudDownLoad(row: Int)
}

struct JSPhotoCellData {
    var choosedImage: UIImage
    var indexPath: IndexPath
    var delegate: JSPhotoCellDelegate?
    var iCloudColor: UIColor
}

class JSPhotoCell: UICollectionViewCell {
    
    // MARK: - Data
    
    var data: JSPhotoCellData!
    var choosed: Bool = false {
        didSet {
            chooseView.isSelected = choosed
            chooseView.setImage(choosed ? data.choosedImage : Image(named: "image_unchoose"), for: .normal)
        }
    }
    
    // MARK: - UI
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    fileprivate lazy var chooseView: UIButton = {
        let chooseView: UIButton = UIButton(frame: CGRect(x: self.bounds.width - 35, y: 0, width: 35, height: 35))
        chooseView.setImage(Image(named: "image_unchoose"), for: .normal)
        chooseView.addTarget(self, action: #selector(self.choose), for: .touchUpInside)
        return chooseView
    }()
    /// 主要是图片为iCloud的时候的遮罩
    var iCloudView: JSiCloudView?
    
    // MARK: - Lifecycle
    
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
        backgroundColor = defaultColor
        addSubview(imageView)
        addSubview(chooseView)
    }
    
    @objc fileprivate func choose() {
        data.delegate?.chooseImage(cell: self)
    }
    
    @objc fileprivate func iCloudDownload() {
        /// 暂时不提供iCloud下载的功能
//        data.delegate?.iCloudDownLoad(row: data.indexPath.row)
    }
    
    /// 显示iCloud标识
    func showiCloud(_ isShow: Bool) {
        if isShow {
            iCloudView = JSiCloudView(frame: CGRect(x: self.bounds.width - 29.8, y: self.bounds.height - 21.4, width: 22.8, height: 14.4), color: data.iCloudColor)
            iCloudView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iCloudDownload)))
            addSubview(iCloudView!)
        }else {
            iCloudView?.gestureRecognizers?.forEach {
                iCloudView?.removeGestureRecognizer($0)
            }
            iCloudView?.removeFromSuperview()
            iCloudView = nil
        }
        chooseView.isHidden = isShow
    }
    
}
