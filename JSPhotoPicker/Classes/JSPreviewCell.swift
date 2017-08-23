//
//  JSPreviewCell.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/4/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

protocol JSPreviewCellDelegate: class {
    /// 关闭图片浏览器
    func closeDisplay(cell: JSPreviewCell)
    func chooseImage(cell: JSPreviewCell)
}

struct JSPreviewCellData {
    var choosedImage: UIImage
    var indexPath: IndexPath
    var iCloudColor: UIColor
    weak var delegate: JSPreviewCellDelegate?
}

class JSPreviewCell: UICollectionViewCell {
    
    // MARK: - Data
    var data: JSPreviewCellData!
    var asset: PHAsset! {
        didSet {
            PHCachingImageManager.default().requestImageData(for: asset, options: nil) { (data, _, _, _) in
                if data != nil {
                    /// 判断是否被选中
                    selectAssets.forEach {
                        self.choosed = self.data.indexPath == $0.indexPath
                    }
                    
                    self.asset.requestImage(targetSize: .original) { [weak self] image, result in
                        guard let `self` = self, let image = image else { return }
                        self.imageView.frame = adaptationRect(size: image.size)
                        self.imageView.image = image
                        self.scrollView.contentSize = CGSize(width: kScreenWidth, height: max(self.imageView.frame.size.height, kScreenHeight))
                    }
                }else {
                    self.imageView.image = UIImage(color: defaultColor, size: CGSize(width: 1, height: 1))
                }
                self.showiCloud(data == nil)
            }
        }
    }
    var choosed: Bool = false {
        didSet {
            chooseView.isSelected = choosed
            chooseView.setImage(choosed ? data.choosedImage : Image(named: "image_unchoose"), for: .normal)
        }
    }
    
    // MARK: - UI
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
        scrollView.isMultipleTouchEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    fileprivate lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomPicture(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    fileprivate lazy var singleTap: UITapGestureRecognizer = {
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        singleTap.require(toFail: self.doubleTap)
        return singleTap
    }()
    fileprivate lazy var chooseView: UIButton = {
        let chooseView: UIButton = UIButton(frame: CGRect(x: self.bounds.width - 80, y: 00, width: 80, height: 80))
        chooseView.setImage(Image(named: "image_unchoose"), for: .normal)
        chooseView.addTarget(self, action: #selector(self.choose), for: .touchUpInside)
        return chooseView
    }()
    fileprivate lazy var iCloudView: JSiCloudView = {
        let iCloudView = JSiCloudView(frame: CGRect(x: 0, y: self.bounds.height - 30, width: 22.8, height: 14.4))
        iCloudView.center = CGPoint(x: self.chooseView.center.x, y: iCloudView.center.y)
        return iCloudView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        uiSet()
        configSet()
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

extension JSPreviewCell {
    
    fileprivate func configSet() {
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
        clipsToBounds = true
    }
    
    fileprivate func uiSet() {
        backgroundColor = UIColor.clear
        addSubview(chooseView)
        addSubview(iCloudView)
        /// 如果需要具有视觉差的效果，那么就需要在contentView上面添加视图
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }
    
    @objc fileprivate func zoomPicture(gesture: UITapGestureRecognizer) {
        if let _ = imageView.image {
            let point = gesture.location(in: gesture.view!)
            if scrollView.zoomScale == scrollView.minimumZoomScale {
                let width = bounds.width / scrollView.maximumZoomScale
                let height = bounds.height / scrollView.maximumZoomScale
                scrollView.zoom(to: CGRect(x: point.x - width / 2, y: point.y - height / 2, width: width, height: height), animated: true)
                scrollView.setZoomScale(2, animated: false)
            }else {
                scrollView.setZoomScale(1.0, animated: true)
            }
        }
    }
    
    @objc fileprivate func choose() {
        data.delegate?.chooseImage(cell: self)
    }
    
    @objc fileprivate func close() {
        data.delegate?.closeDisplay(cell: self)
    }
    
    /// 显示iCloud标识
    func showiCloud(_ isShow: Bool) {
        iCloudView.isHidden = !isShow
        chooseView.isHidden = isShow
    }
    
}

extension JSPreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let _ = imageView.image {
            let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width) / 2 : 0
            let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height) / 2 : 0
            imageView.center = CGPoint(x: self.scrollView.contentSize.width / 2 + offsetX, y: scrollView.contentSize.height / 2 + offsetY)
        }
    }
    
}
