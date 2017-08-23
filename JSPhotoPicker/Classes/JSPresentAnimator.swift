//
//  JSPreviewPushAnimator.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/7/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

class JSPresentAnimator: MainAnimator {

    override func animateTransitionEvent() {
        guard let navControl = fromControl as? UINavigationController else { return }
        
        guard let fromControl = navControl.top as? JSPhotoViewController,
            let toControl = toControl as? JSPreviewController else { return }
        
        containerView.addSubview(self.toControl.view)
        
        let initialView: UIImageView = UIImageView(frame: fromControl.animationRect(index: fromControl.selectIndexPath.row))
        initialView.contentMode = .scaleAspectFill
        initialView.clipsToBounds = true
        if let image = fromControl.animationImage(index: fromControl.selectIndexPath.row) {
            initialView.image = image
        }else {
            initialView.image = UIImage(color: defaultColor, size: CGSize(width: 1, height: 1))
        }
        containerView.addSubview(initialView)

        /// 将原来的view隐藏
        fromControl.animationView(index: fromControl.selectIndexPath.row)?.isHidden = true
        toControl.animationView(index: fromControl.selectIndexPath.row)?.isHidden = true
        
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            initialView.frame = adaptationRect(size: fromControl.animationSize(index: fromControl.selectIndexPath.row))
            self.toControl.view.backgroundColor = UIColor.black
        }) { finished in
            initialView.removeFromSuperview()
            toControl.animationView(index: fromControl.selectIndexPath.row)?.isHidden = false
            self.completeTransition()
        }
    }
    
}
