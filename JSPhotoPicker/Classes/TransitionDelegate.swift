//
//  TransitionDelegate.swift
//  PresentTransition
//
//  Created by jesse on 2017/7/11.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit

class TransitionDelegate: NSObject {
    
    fileprivate var inAnimator: MainAnimator?
    fileprivate var outAnimator: MainAnimator?
    fileprivate var interactiveTransition: JSDismissInteractiveTransition?
    public var isDismissEnabled = true
    
    init(in inAnimator: MainAnimator? = nil, out outAnimator: MainAnimator? = nil, interactive interactiveTransition: JSDismissInteractiveTransition? = nil) {
        super.init()
        self.inAnimator = inAnimator
        self.outAnimator = outAnimator
        self.interactiveTransition = interactiveTransition
    }
    
    deinit {
        print("\(self.classForCoder.description()) - deinit")
    }

}

extension TransitionDelegate: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return inAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return outAnimator
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactiveTransition = interactiveTransition else {
            return nil
        }
        return interactiveTransition.isInteractive ? interactiveTransition : nil
    }
    
}

extension TransitionDelegate: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return inAnimator
        }else if operation == .pop {
            return outAnimator
        }
        return nil
    }
    
}
