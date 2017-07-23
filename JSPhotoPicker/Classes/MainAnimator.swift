//
//  MainAnimator.swift
//  IceCream
//
//  Created by jesse on 16/11/9.
//  Copyright © 2016年 jesse. All rights reserved.
//

import UIKit

class MainAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var fromControl: UIViewController!
    var toControl: UIViewController!
    var containerView: UIView!
    var transitionContext: UIViewControllerContextTransitioning!
    var defaultTime = 0.3
    
    deinit {
        print("\(self.classForCoder.description()) - deinit")
    }
    
    func animateTransitionEvent() {}
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return defaultTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fromControl = transitionContext.viewController(forKey: .from)
        toControl = transitionContext.viewController(forKey: .to)
        containerView = transitionContext.containerView
        self.transitionContext = transitionContext
        
        animateTransitionEvent()
    }
    
    func completeTransition() {
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
}
