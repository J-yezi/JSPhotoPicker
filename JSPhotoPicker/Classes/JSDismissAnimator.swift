//
//  JSPreviewPopAnimator.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/7/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

class JSDismissAnimator: MainAnimator {
    
    override func animateTransitionEvent() {
        if !transitionContext.isInteractive {
            guard let navControl = toControl as? UINavigationController else { return }
            
            guard let toControl = navControl.top as? JSPhotoViewController,
                let fromControl = fromControl as? JSPreviewController else { return }
            
            let initialView: UIImageView = UIImageView(frame: fromControl.animationRect(index: fromControl.currentPage))
            initialView.contentMode = .scaleAspectFill
            initialView.clipsToBounds = true
            if let image = fromControl.animationImage(index: fromControl.currentPage) {
                initialView.image = image
            }else {
                initialView.image = UIImage(color: defaultColor, size: CGSize(width: 1, height: 1))
            }
            containerView.addSubview(initialView)
            
            /// 将原来的view隐藏
            fromControl.animationView(index: fromControl.currentPage)?.isHidden = true
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                initialView.frame = toControl.animationRect(index: fromControl.currentPage)
                self.fromControl.view.backgroundColor = UIColor.clear
            }) { _ in
                initialView.removeFromSuperview()
                toControl.animationView(index: fromControl.currentPage)?.isHidden = false
                self.completeTransition()
            }
        }
    }

}
