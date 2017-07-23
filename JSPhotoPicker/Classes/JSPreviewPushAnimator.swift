//
//  JSPreviewPushAnimator.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/7/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

class JSPreviewPushAnimator: MainAnimator {

    override func animateTransitionEvent() {
        let photoControl = fromControl as! JSPhotoViewController
        let previewControl = toControl as! JSPreviewController
        
        containerView.addSubview(previewControl.view)
        previewControl.view.alpha = 0
        
        let imageView = UIImageView(frame: photoControl.pushRect)
        imageView.image = photoControl.pushImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
        
        UIView.animate(withDuration: 0.3, animations: {
            imageView.frame = calculateImagePreviewRect(photoControl.pushImage.size)
        }) { finished in
            self.completeTransition()
        }
    }
    
}
