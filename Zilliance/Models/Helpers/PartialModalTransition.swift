//
//  PartialModalTransition.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/26/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

final class PartialModalTrasition: NSObject {
    
    enum TransitionType {
        case presenting
        case dismissing
    }
    
    fileprivate let transitionDuration = 0.3
    fileprivate var type: TransitionType
    
    init(withType type: TransitionType) {
        self.type = type
        super.init()
    }
}

extension PartialModalTrasition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        switch self.type {
        case .presenting:
            self.presentTransition(with: transitionContext)
        case .dismissing:
            self.dismissTransition(with: transitionContext)
        }
        
    }
    
    private func presentTransition(with transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        guard let frame = fromViewController?.view.frame else { return }
    
        toViewController?.view.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: frame.height)
        containerView.addSubview((toViewController?.view)!)
        
        
        UIView.animate(withDuration: self.transitionDuration, animations: {
            toViewController?.view.transform = CGAffineTransform(translationX: 0, y: -frame.height/2)
        }) { (_) in
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromViewController?.view.alpha = 0.5
            }, completion: { (completed) in
                transitionContext.completeTransition(completed)
            })
        }

    }
    
    private func dismissTransition(with transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        guard let frame = fromViewController?.view.frame else { return }

        UIView.animate(withDuration: self.transitionDuration, animations: {
            toViewController?.view.alpha = 1.0
            fromViewController?.view.transform = CGAffineTransform(translationX: 0, y: frame.height/2)
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
        
    }
}
