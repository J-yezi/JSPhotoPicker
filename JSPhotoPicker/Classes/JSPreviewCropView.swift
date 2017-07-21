//
//  JSPreviewCropView.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/6/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

class JSPreviewCropView: UIView {
    
    enum CropType {
        case square
        case circle
    }
    fileprivate var type: CropType = .square
    fileprivate lazy var backLayer: CAShapeLayer = {
        let backLayer = CAShapeLayer()
        let path = UIBezierPath(rect: self.bounds)
        if self.type == .circle {
            path.append(UIBezierPath(arcCenter: self.center, radius: self.bounds.size.width / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false))
        }else {
            path.append(UIBezierPath(rect: CGRect(x: 0, y: (self.bounds.size.height - self.bounds.size.width) / 2, width: self.bounds.size.width, height: self.bounds.size.width)))
        }
        backLayer.path = path.cgPath
        backLayer.fillRule = kCAFillRuleEvenOdd
        backLayer.fillColor = UIColor.black.cgColor
        backLayer.opacity = 0.5
        return backLayer
    }()
    fileprivate lazy var rectLayer: CAShapeLayer = {
        let rectLayer = CAShapeLayer()
        rectLayer.fillColor = UIColor.clear.cgColor
        rectLayer.borderColor = UIColor.white.cgColor
        rectLayer.borderWidth = 1
        rectLayer.opacity = 0.5
        rectLayer.frame = CGRect(x: 0, y: (self.bounds.size.height - self.bounds.size.width) / 2, width: self.bounds.size.width, height: self.bounds.size.width)
        if self.type == .circle {
            rectLayer.cornerRadius = self.bounds.size.width / 2
        }
        return rectLayer
    }()

    init(frame: CGRect, cropType: CropType = .square) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        type = cropType
        layer.addSublayer(backLayer)
        layer.addSublayer(rectLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
