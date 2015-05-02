//
//  ChildInteractiveTransition.swift
//
//
//  Created by Dmitry Ratkevich on 3/8/15.
//  Copyright (c) 2015 Dmitry Ratkevich. All rights reserved.
//

import UIKit

let CITParalaxCoefficient: CGFloat = 0.6
let CITMinPercentageToFinish: CGFloat = 0.15
let CITDuration = 0.2

enum ChildInteractiveTransitionDirection {
    case Left
    case Right
}

class ChildInteractiveTransitionViewController: UIViewController {
    func updateTransition(percentComplete: CGFloat, direction: ChildInteractiveTransitionDirection, presenting: Bool, duration: NSTimeInterval?) {
        
    }
    
    func cancelTransition(direction: ChildInteractiveTransitionDirection, presenting: Bool, duration: NSTimeInterval?) {
        self.updateTransition(0.0, direction: direction, presenting: presenting, duration: duration)
    }
    
    func finishTransition(direction: ChildInteractiveTransitionDirection, presenting: Bool, duration: NSTimeInterval?) {
        self.updateTransition(1.0, direction: direction, presenting: presenting, duration: duration)
    }
}

protocol ChildInteractiveTransitionDelegate: class {
    func cancelTransition()
    func finishTransition()
    func updateTransition(percentComplete: CGFloat, direction: ChildInteractiveTransitionDirection, duration: NSTimeInterval?)
}

class ChildInteractiveTransition: NSObject {
    var percentComplete: CGFloat = 0.0
    var fromViewController: ChildInteractiveTransitionViewController
    var toViewController: ChildInteractiveTransitionViewController
    var containerView: UIView
    var direction: ChildInteractiveTransitionDirection
    weak var delegate: ChildInteractiveTransitionDelegate?
    
    init(containerView: UIView, fromViewController:ChildInteractiveTransitionViewController, toViewController:ChildInteractiveTransitionViewController, direction:ChildInteractiveTransitionDirection) {
        self.containerView = containerView
        self.fromViewController = fromViewController
        self.toViewController = toViewController
        self.direction = direction
        switch direction {
        case .Left:
            toViewController.view.frame = CGRectOffset(toViewController.view.bounds, CGRectGetWidth(toViewController.view.bounds), 0)
        case .Right:
            toViewController.view.frame = CGRectOffset(toViewController.view.bounds, -CGRectGetWidth(toViewController.view.bounds), 0)
        }
        
        containerView.addSubview(toViewController.view)
        
        super.init()
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        var toViewFrame: CGRect = self.toViewController.view.bounds
        var fromViewFrame: CGRect = self.fromViewController.view.bounds
        switch direction {
        case .Left:
            toViewFrame.origin.x = CGRectGetWidth(toViewFrame)*(1.0 - percentComplete)
            fromViewFrame.origin.x = CITParalaxCoefficient*CGRectGetWidth(fromViewFrame)*(-percentComplete)
        case .Right:
            toViewFrame.origin.x = CGRectGetWidth(toViewFrame)*(percentComplete - 1.0)
            fromViewFrame.origin.x = CITParalaxCoefficient*CGRectGetWidth(fromViewFrame)*percentComplete
        }
        
        self.toViewController.view.frame = toViewFrame
        self.delegate?.updateTransition(percentComplete, direction: self.direction, duration: nil)
        self.toViewController.updateTransition(percentComplete, direction: self.direction, presenting: true, duration: nil)
        self.fromViewController.updateTransition(percentComplete, direction: self.direction, presenting: false, duration: nil)
        self.percentComplete = percentComplete
    }
    
    func finishInteractiveTransition(#force: Bool) {
        var toViewFrame: CGRect = self.toViewController.view.bounds
        var fromViewFrame: CGRect = self.fromViewController.view.bounds
        if force || self.percentComplete >= CITMinPercentageToFinish {
            //finish
            switch self.direction {
            case .Left:
                toViewFrame.origin.x = 0
                fromViewFrame.origin.x = -CITParalaxCoefficient*CGRectGetWidth(fromViewFrame)
            case .Right:
                toViewFrame.origin.x = 0
                fromViewFrame.origin.x = CITParalaxCoefficient*CGRectGetWidth(fromViewFrame)
            }
            
            self.delegate?.updateTransition(1.0, direction: self.direction, duration: CITDuration)
            self.toViewController.finishTransition(self.direction, presenting: true, duration: CITDuration)
            self.fromViewController.finishTransition(self.direction, presenting: false, duration: CITDuration)
            UIView.animateWithDuration(CITDuration, animations: {
                self.toViewController.view.frame = toViewFrame
                }, completion: { finished in
                    self.delegate?.finishTransition()
            })
        }
        else {
            //cancel
            switch self.direction {
            case .Left:
                toViewFrame.origin.x = CGRectGetWidth(toViewFrame)
                fromViewFrame.origin.x = 0
            case .Right:
                toViewFrame.origin.x = -CGRectGetWidth(toViewFrame)
                fromViewFrame.origin.x = 0
            }
            
            self.delegate?.updateTransition(0.0, direction: self.direction, duration: CITDuration)
            self.toViewController.cancelTransition(self.direction, presenting: true, duration: CITDuration)
            self.fromViewController.cancelTransition(self.direction, presenting: false, duration: CITDuration)
            UIView.animateWithDuration(CITDuration, animations: {
                self.toViewController.view.frame = toViewFrame
                }, completion: { finished in
                    self.delegate?.cancelTransition()
            })
        }
    }
}

