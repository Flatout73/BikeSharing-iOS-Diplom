//
//  FlipPresentAnimationController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 02/06/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(toVC.view)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.transition(from: fromVC.view, to: toVC.view, duration: duration, options: [.transitionFlipFromRight]) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }
    
    
}
