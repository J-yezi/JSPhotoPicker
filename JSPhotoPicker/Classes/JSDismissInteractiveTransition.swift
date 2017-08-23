//
//  JSDismissInteractiveTransition.swift
//  PictureBrowser
//
//  Created by jesse on 2017/8/14.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit

let kScaleModulus: CGFloat = UIScreen.main.bounds.height * 1.8
let kAlphaModulus: CGFloat = UIScreen.main.bounds.height
let kPercent: CGFloat = 0.2

class JSDismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    fileprivate(set) var transitionContext: UIViewControllerContextTransitioning!
    fileprivate weak var toControl: JSPhotoViewController!
    fileprivate weak var fromControl: JSPreviewController!
    fileprivate weak var scrollView: UIScrollView!
    fileprivate weak var containerView: UIView!
    fileprivate var initialView: UIImageView!
    /// 是否使用手势进行转场
    var isInteractive: Bool = false
    
    init(from: JSPreviewController, to: JSPhotoViewController) {
        super.init()
        self.fromControl = from
        self.toControl = to
        self.fromControl.changeScrollView = { [weak self] in
            guard let `self` = self else { return }
            self.scrollView = $0
            $0.panGestureRecognizer.addTarget(self, action: #selector(self.handlePanGesture(_:)))
        }
    }
    
    deinit {
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView
        super.startInteractiveTransition(transitionContext)
    }
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        /// 如果zoomScale不为1，不执行手势返回，暂时先做成这样，后面有时间再修改
//        guard scrollView.zoomScale == 1 else { return }
        
        let translation = gesture.translation(in: toControl.view)
        
        guard let imageView = scrollView.subviews.first else { return }
        
        if gesture.state == .began {
            /// 上边滚出头或者下面滚出头
            if scrollView.contentOffset.y <= 0 {
                isInteractive = true
                fromControl.dismiss(animated: true, completion: nil)
                return
            }
        }

        switch gesture.state {
        case .changed:
            if isInteractive {
                if translation.y > 0 {
                    scrollView.contentOffset = .zero
                    
                    let scale: CGFloat = (kScaleModulus - CGFloat(translation.y)) / kScaleModulus
                    let alpha: CGFloat = (kAlphaModulus - CGFloat(translation.y)) / kAlphaModulus
                    var transform = CGAffineTransform.identity
                    transform = transform.scaledBy(x: scale, y: scale)
                    transform = transform.translatedBy(x: translation.x, y: translation.y)
                    imageView.transform = transform
                    fromControl.view.backgroundColor = UIColor.black.withAlphaComponent(alpha)
                }else {
                    fromControl.view.backgroundColor = UIColor.black
                    let scale: CGFloat = (kScaleModulus - CGFloat(abs(translation.y))) / kScaleModulus
                    imageView.transform = CGAffineTransform.identity.translatedBy(x: translation.x * scale, y: translation.y * scale)
                }
            }
        case .cancelled:
            if isInteractive {
                isInteractive = false
                transitionContext.cancelInteractiveTransition()
            }
        case .ended:
            if isInteractive {
                isInteractive = false
                /// 保证scrollView不跳动
                scrollView.setContentOffset(.zero, animated: false)
                
                if translation.y / UIScreen.main.bounds.height > kPercent {
                    finish()
                    let initialView: UIImageView = UIImageView(frame: fromControl.animationRect(index: fromControl.currentPage))
                    initialView.contentMode = .scaleAspectFill
                    initialView.clipsToBounds = true
                    if let image = fromControl.animationImage(index: fromControl.currentPage) {
                        initialView.image = image
                    }else {
                        initialView.image = UIImage(color: defaultColor, size: CGSize(width: 1, height: 1))
                    }
                    containerView.addSubview(initialView)
                    fromControl.animationView(index: fromControl.currentPage)?.isHidden = true

                    UIView.animate(withDuration: 5, animations: {
                        initialView.frame = self.toControl.animationRect(index: self.fromControl.currentPage)
                        self.fromControl.view.backgroundColor = UIColor.clear
                    }) { _ in
                        initialView.removeFromSuperview()
                        self.toControl.animationView(index: self.fromControl.currentPage)?.isHidden = false
                        self.transitionContext.completeTransition(!self.transitionContext.transitionWasCancelled)
                    }
                }else {
                    cancel()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.fromControl.view.backgroundColor = UIColor.black
                        imageView.transform = CGAffineTransform.identity
                    }, completion: { _ in
                        self.transitionContext.completeTransition(!self.transitionContext.transitionWasCancelled)
                    })
                }
            }
        default:
            break
        }
    }

}
