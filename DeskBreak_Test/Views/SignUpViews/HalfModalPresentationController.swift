//
//  HalfModalPresentationController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 05/12/24.
//

import UIKit

class HalfModalPresentationController: UIPresentationController {

    private let dimmingView = UIView()

    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(
            x: 0,
            y: containerView!.bounds.height * 0.5,
            width: containerView!.bounds.width,
            height: containerView!.bounds.height * 0.5
        )
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        dimmingView.frame = containerView.bounds
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.insertSubview(dimmingView, at: 0)

        dimmingView.alpha = 0
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}
