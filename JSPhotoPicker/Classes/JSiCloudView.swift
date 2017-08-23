//
//  JSiCloudView.swift
//  JSPhotoPicker
//
//  Created by jesse on 2017/8/18.
//

import UIKit

class JSiCloudView: UIView {
    
    // MARK: - Data
    
    var color: UIColor! {
        didSet {
            progressLayer.strokeColor = color.cgColor
        }
    }
    var progress: Double! {
        didSet {
            if oldValue != nil {
                if progress > oldValue {
                    progressLayer.strokeEnd = CGFloat(progress)
                }
            }else {
                progressLayer.strokeEnd = CGFloat(progress)
            }
            if progress == 1 {
                isHidden = true
            }
        }
    }
    
    // MARK: - UI
    
    fileprivate lazy var progressLayer: CAShapeLayer = {
        let progressLayer: CAShapeLayer = CAShapeLayer()
        progressLayer.frame = self.bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = self.color.cgColor
        /// 防止临界边会漏一点白色出来
        progressLayer.lineWidth = self.bounds.height + 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -2, y: self.bounds.height / 2))
        path.addLine(to: CGPoint(x: self.bounds.width + 4, y: self.bounds.height / 2))
        progressLayer.path = path.cgPath
        progressLayer.strokeEnd = 0
        return progressLayer
    }()

    init(frame: CGRect, color: UIColor = UIColor.white) {
        super.init(frame: frame)
        self.color = color
        uiSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension JSiCloudView {
    
    fileprivate func uiSet() {
        let iCloudLayer = CALayer()
        iCloudLayer.frame = bounds
        iCloudLayer.contents = Image(named: "iCloud")?.cgImage
        layer.mask = iCloudLayer
        backgroundColor = UIColor.white
        
        layer.addSublayer(progressLayer)
    }
    
}
