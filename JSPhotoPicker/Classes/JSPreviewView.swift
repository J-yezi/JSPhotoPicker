//
//  JSPreviewView.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/4/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

class JSPreviewView: UIView {
    
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
        return scrollView
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    var asset: PHAsset! {
        didSet {
            JSImageManager.getPhoto(asset: asset, width: kScreenWidth) { (image, _) in
                guard let image = image else { return }
                self.imageView.frame = calculateImagePreviewRect(image.size)
                self.imageView.image = image
                self.imageView.backgroundColor = UIColor.red
                self.scrollView.contentSize = CGSize(width: kScreenWidth, height: max(self.imageView.frame.size.height, kScreenHeight))
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
    
    func scalePhoto(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.setZoomScale(1, animated: true)
        }else {
            let touchPoint = gesture.location(in: imageView)
            let x = frame.size.width / scrollView.maximumZoomScale
            let y = frame.size.height / scrollView.maximumZoomScale
            let rect = CGRect(x: touchPoint.x - x / 2, y: touchPoint.y - y / 2, width: x, height: y)
            scrollView.zoom(to: rect, animated: true)
        }
    }
    
    func recoverScrollZoom() {
        scrollView.setZoomScale(1, animated: false)
    }

}

extension JSPreviewView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print(scrollView.zoomScale)
    }
}
