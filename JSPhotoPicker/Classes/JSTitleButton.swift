//
//  JSTitleButton.swift
//  JSPhotoPicker
//
//  Created by jesse on 2017/7/21.
//

import UIKit

class JSTitleButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView?.contentMode = .center
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        adjustsImageWhenHighlighted = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reverse() {
        guard let label = titleLabel, let image = imageView?.image else { return }
        let distance: CGFloat = 2
        imageEdgeInsets = UIEdgeInsetsMake(0, label.bounds.width + distance, 0, -label.bounds.width - distance)
        titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width - distance, 0, image.size.width + distance)
    }
    
    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        reverse()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        reverse()
    }
    
}
