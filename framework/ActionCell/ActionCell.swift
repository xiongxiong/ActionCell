//
//  ActionCell.swift
//  ActionCell
//
//  Created by 王继荣 on 27/12/16.
//  Copyright © 2016 WonderBear. All rights reserved.
//

import UIKit

public protocol ActionCellDelegate: NSObjectProtocol {
    
    var tableView: UITableView! { get }
    var navigationController: UINavigationController? { get }
    /// Do something when action is triggered
    func didActionTriggered(cell: UITableViewCell, action: String)
}

extension ActionCellDelegate {
    /// Close other cell's actionsheet before open own actionsheet
    func closeActionsheet() {
        tableView.visibleCells.forEach { (cell) in
            cell.subviews.forEach({ (view) in
                if let wrapper = view as? ActionCell {
                    wrapper.closeActionsheet()
                }
            })
        }
    }
}

open class ActionCell: UIView {
    
    // MARK: ActionCell - 动作设置
    /// ActionCellDelegate
    public weak var delegate: ActionCellDelegate? = nil
    
    // MARK: ActionCell - 行为设置
    /// Enable default action to be triggered when the content is panned to far enough
    public var enableDefaultAction: Bool = true
    /// The propotion of (state public to state trigger-prepare / state public to state trigger), about where the default action is triggered
    public var defaultActionTriggerPropotion: CGFloat = 0.3 {
        willSet {
            guard newValue > 0.1 && newValue < 0.5 else {
                fatalError("defaultActionTriggerPropotion -- value out of range, value must between 0.1 and 0.5")
            }
        }
    }
    
    // MARK: ActionCell - 动画设置
    /// Action 动画形式
    public var animationStyle: ActionsheetOpenStyle = .concurrent
    /// Spring animation - duration of the animation
    public var animationDuration: TimeInterval = 0.3
    
    // MARK: ActionCell - 私有属性
    /// cell
    weak var cell: UITableViewCell?
    /// actionsheet container
    var container: UIView = UIView()
    /// actionsheet - Left
    var actionsheetLeft: Actionsheet = Actionsheet(side: .left)
    /// actionsheet - Right
    var actionsheetRight: Actionsheet = Actionsheet(side: .right)
    /// swipeLeftGestureRecognizer
    var swipeLeftGestureRecognizer: UISwipeGestureRecognizer!
    /// swipeRightGestureRecognizer
    var swipeRightGestureRecognizer: UISwipeGestureRecognizer!
    /// panGestureRecognizer
    var panGestureRecognizer: UIPanGestureRecognizer!
    /// tapGestureRecognizer
    var tapGestureRecognizer: UITapGestureRecognizer!
    /// tempTapGestureRecognizer
    var tempTapGestureRecognizer: UITapGestureRecognizer!
    /// Screenshot of the cell
    var contentScreenshot: UIImageView?
    /// Current actionsheet
    var currentActionsheet: Actionsheet?
    /// The default action to trigger when content is panned to the far side.
    var defaultAction: ActionControl?
    /// The default action is triggered or not
    var isDefaultActionTriggered: Bool = false
    /// Actionsheet opened or not
    open var isActionsheetOpened: Bool {
        return currentActionsheet != nil
    }
    
    // MARK: Initialization
    public func wrap(cell target: UITableViewCell, actionsLeft: [ActionControl] = [], actionsRight: [ActionControl] = []) {
        cell = target
        
        target.selectionStyle = .none
        target.addSubview(self)
        target.sendSubview(toBack: self)
        
        target.contentView.addSubview(container)
        target.contentView.sendSubview(toBack: container)
        container.translatesAutoresizingMaskIntoConstraints = false
        target.addConstraint(NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .equal, toItem: target, attribute: .leading, multiplier: 1, constant: 0))
        target.addConstraint(NSLayoutConstraint(item: container, attribute: .trailing, relatedBy: .equal, toItem: target, attribute: .trailing, multiplier: 1, constant: 0))
        target.addConstraint(NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal, toItem: target, attribute: .top, multiplier: 1, constant: 0))
        target.addConstraint(NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .equal, toItem: target, attribute: .bottom, multiplier: 1, constant: 0))
        
        swipeLeftGestureRecognizer = {
            let the = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer(_:)))
            target.contentView.addGestureRecognizer(the)
            the.delegate = self
            the.direction = .left
            return the
        }()
        swipeRightGestureRecognizer = {
            let the = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer(_:)))
            target.contentView.addGestureRecognizer(the)
            the.delegate = self
            the.direction = .right
            the.require(toFail: swipeLeftGestureRecognizer)
            return the
        }()
        panGestureRecognizer = {
            let the = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
            target.contentView.addGestureRecognizer(the)
            the.delegate = self
            the.require(toFail: swipeLeftGestureRecognizer)
            the.require(toFail: swipeRightGestureRecognizer)
            return the
        }()
        tapGestureRecognizer = {
            let the = UITapGestureRecognizer()
            target.contentView.addGestureRecognizer(the)
            the.delegate = self
            the.numberOfTapsRequired = 1
            the.cancelsTouchesInView = false
            the.require(toFail: swipeLeftGestureRecognizer)
            the.require(toFail: swipeRightGestureRecognizer)
            the.require(toFail: panGestureRecognizer)
            the.isEnabled = false 
            return the
        }()
        tempTapGestureRecognizer = {
            let the = UITapGestureRecognizer(target: self, action: #selector(handleTempTapGestureRecognizer(_:)))
            the.numberOfTapsRequired = 1
            the.require(toFail: swipeLeftGestureRecognizer)
            the.require(toFail: swipeRightGestureRecognizer)
            the.require(toFail: panGestureRecognizer)
            return the
        }()
        
        setupActionsheet(side: .left, actions: actionsLeft)
        setupActionsheet(side: .right, actions: actionsRight)
    }
    
    // MARK: Actionsheet
    /// Setup actionsheet
    func setupActionCell(side: ActionSide) {
        #if DEVELOPMENT
            print("\(#function) -- " + "side: \(side)")
        #endif
        
        if isActionsheetValid(side: side) {
            cell!.contentView.bringSubview(toFront: container)
            
            contentScreenshot = takeScreenshot()
            contentScreenshot?.isUserInteractionEnabled = true
            contentScreenshot?.addGestureRecognizer(tempTapGestureRecognizer)
            container.addSubview(contentScreenshot!)
            
            currentActionsheet = actionsheet(side: side)
            defaultAction = defaultAction(side: side)
            container.backgroundColor = defaultAction?.backgroundColor
            
            tapGestureRecognizer.isEnabled = true
        }
    }
    
    /// Clear actionsheet when actionsheet is closed
    func clearActionCell(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if isActionsheetOpened {
            setActionsheet(for: .close, orientation: .close)
        }
        
        tapGestureRecognizer.isEnabled = false
        
        isDefaultActionTriggered = false
        defaultAction = nil
        
        contentScreenshot?.removeFromSuperview()
        contentScreenshot?.removeGestureRecognizer(tempTapGestureRecognizer)
        contentScreenshot = nil
        
        container.backgroundColor = UIColor.clear
        cell!.contentView.sendSubview(toBack: container)
        
        completionHandler?()
    }
    
    /// Setup action sheet
    func setupActionsheet(side: ActionSide, actions: [ActionControl]) {
        #if DEVELOPMENT
            print("\(#function) -- " + "side: \(side)")
        #endif
        
        actionsheet(side: side).actions.forEach {
            $0.removeFromSuperview()
        }
        actionsheet(side: side).actions = actions
        actionsheet(side: side).actions.reversed().forEach {
            $0.delegate = self
            container.addSubview($0)
        }
        resetActionConstraints(side: side)
        resetActionAttributes(side: side)
    }
    
    /// Open action sheet
    public func openActionsheet(side: ActionSide, completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "side: \(side)")
        #endif
        
        setupActionCell(side: side)
        animateCloseToOpen(completionHandler)
    }
    
    /// Close opened action sheet
    public func closeActionsheet(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if isActionsheetOpened {
            animateOpenToClose(completionHandler)
        }
    }
    
    /// Set actions' constraints for beginning
    func resetActionConstraints(side: ActionSide) {
        #if DEVELOPMENT
            print("\(#function) -- " + "side: \(side)")
        #endif
        
        actionsheet(side: side).actions.enumerated().forEach { (index, action) in
            action.translatesAutoresizingMaskIntoConstraints = false
            container.addConstraint(NSLayoutConstraint(item: action, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0))
            container.addConstraint(NSLayoutConstraint(item: action, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0))
            switch side {
            case .left:
                let constraintHead = NSLayoutConstraint(item: action, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: -1 * action.width)
                action.constraintHead = constraintHead
                container.addConstraint(constraintHead)
                let constraintTail = NSLayoutConstraint(item: action, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0)
                action.constraintTail = constraintTail
                container.addConstraint(constraintTail)
            case .right:
                let constraintHead = NSLayoutConstraint(item: action, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: action.width)
                action.constraintHead = constraintHead
                container.addConstraint(constraintHead)
                let constraintTail = NSLayoutConstraint(item: action, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0)
                action.constraintTail = constraintTail
                container.addConstraint(constraintTail)
            }
        }
        container.setNeedsLayout()
        container.layoutIfNeeded()
    }
    
    /// Setup actions' attributes
    func resetActionAttributes(side: ActionSide) {
        #if DEVELOPMENT
            print("\(#function) -- " + "side: \(side)")
        #endif
        
        actionsheet(side: side).actions.forEach {
            $0.update(position: .close)
            $0.update(state: .active)
        }
    }
    
    /// Set action sheet according to it's state
    func setActionsheet(for state: ActionsheetState, orientation: AnimateOrientation) {
        #if DEVELOPMENT
            print("\(#function) -- " + "state: \(state)")
        #endif
        
        if let side = currentActionsheet?.side {
            switch state {
            case .close:
                actionsheet(side: side).actions.enumerated().forEach({ (index, action) in
                    updateActionConstraints(action: action, orientation: .close, constantHead: (side == .left ? -1 : 1) * action.width, constantTail: 0)
                    action.update(position: .close)
                })
                resetActionAttributes(side: side)
                currentActionsheet = nil
            case .open:
                actionsheet(side: side).actions.enumerated().forEach({ (index, action) in
                    let widthPre = currentActionsheet?.actionWidthBefore(actionIndex: index) ?? 0
                    updateActionConstraints(action: action, orientation: orientation, constantHead: (side == .left ? 1 : -1) * widthPre, constantTail: (side == .left ? 1 : -1) * (widthPre + action.width))
                    action.update(position: .open)
                })
            case .position(let position):
                actionsheet(side: side).actions.enumerated().forEach({ (index, action) in
                    let widthPre = currentActionsheet?.actionWidthBefore(actionIndex: index) ?? 0
                    switch positionSection(side: side, position: position) {
                    case .close_OpenPre, .openPre_Open:
                        switch animationStyle {
                        case .ladder_emergence:
                            let currentLadderIndex = ladderingIndex(side: side, position: position)
                            if index == currentLadderIndex {
                                let progress = ((abs(position) - widthPre) / action.width).truncatingRemainder(dividingBy: 1)
                                action.update(position: .opening(progress: progress))
                            } else if index < currentLadderIndex {
                                action.update(position: .open)
                            }
                            fallthrough
                        case .ladder:
                            let currentActionIndex = ladderingIndex(side: side, position: position)
                            if index >= currentActionIndex {
                                updateActionConstraints(action: action, orientation: orientation, constantHead: position + (side == .left ? -1 : 1) * action.width, constantTail: position)
                            } else {
                                updateActionConstraints(action: action, orientation: orientation, constantHead: (side == .left ? 1 : -1) * widthPre, constantTail: (side == .left ? 1 : -1) * (widthPre + action.width))
                                action.update(position: .open)
                            }
                        case .concurrent:
                            var targetPosition = position
                            if abs(targetPosition) > abs(positionForOpen(side: side)) {
                                targetPosition = positionForOpen(side: side)
                            }
                            let actionAnchorPosition = targetPosition * (actionsheet(side: side).actionWidthBefore(actionIndex: index) + action.width) / actionsheet(side: side).width
                            updateActionConstraints(action: action, orientation: orientation, constantHead: actionAnchorPosition + (side == .left ? -1 : 1) * action.width, constantTail: actionAnchorPosition)
                            action.update(position: .open)
                        }
                    case .open_TriggerPre:
                        if isDefaultActionTriggered {
                            if action == defaultAction {
                                updateActionConstraints(action: action, orientation: orientation, constantHead: position + (side == .left ? -1 : 1) * action.width, constantTail: position)
                            }
                        } else {
                            updateActionConstraints(action: action, orientation: orientation, constantHead: position + (side == .left ? -1 : 1) * (actionsheet(side: side).actionWidthAfter(actionIndex: index) + action.width), constantTail: position + (side == .left ? -1 : 1) * actionsheet(side: side).actionWidthAfter(actionIndex: index))
                        }
                    case .triggerPre_Trigger:
                        if isDefaultActionTriggered && action == defaultAction {
                            updateActionConstraints(action: action, orientation: orientation, constantHead: position + (side == .left ? -1 : 1) * action.width, constantTail: position)
                        }
                    }
                })
            }
        }
    }
    
    /// Get actionsheet
    func actionsheet(side: ActionSide) -> Actionsheet {
        switch side {
        case .left:
            return actionsheetLeft
        case .right:
            return actionsheetRight
        }
    }
    
    /// Get action sheet actions
    func actionsheetActions(side: ActionSide) -> [ActionControl] {
        return actionsheet(side: side).actions
    }
    
    /// Get default action
    func defaultAction(side: ActionSide) -> ActionControl? {
        switch side {
        case .left:
            return actionsheetActions(side: side).first
        case .right:
            return actionsheetActions(side: side).first
        }
    }
    
    /// Does action sheet have actions to show
    func isActionsheetValid(side: ActionSide) -> Bool {
        return actionsheet(side: side).actions.count > 0
    }
    
    /// Update action's constraints
    func updateActionConstraints(action: ActionControl, orientation: AnimateOrientation,constantHead: CGFloat, constantTail: CGFloat) {
        switch orientation {
        case .close:
            action.constraintHead?.constant = constantHead
            action.constraintTail?.constant = constantTail
        case .triggered:
            action.constraintTail?.constant = constantTail
            action.constraintHead?.constant = constantHead
        }
        container.setNeedsLayout()
    }
    
    // MARK: Default Action
    
    /// Animate when default action is triggered
    func animateDefaultActionTriggered(completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let side = currentActionsheet?.side {
            actionsheet(side: side).actions.forEach {
                if $0 != self.defaultAction {
                    $0.update(state: .inactive)
                }
            }
            self.cell!.isUserInteractionEnabled = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear], animations: { [unowned self] in
                let position = self.positionForTriggerPrepare(side: side)
                if let action = self.defaultAction {
                    self.updateActionConstraints(action: action, orientation: .triggered, constantHead: position + (side == .left ? -1 : 1) * action.width, constantTail: position)
                }
                self.container.layoutIfNeeded()
                }, completion: { [unowned self] _ in
                    self.cell!.isUserInteractionEnabled = true
                    completionHandler?()
            })
        }
    }
    
    /// Animate when default action's trigger is cancelled
    func animateDefaultActionCancelled(completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let side = currentActionsheet?.side, let contentScreenshot = contentScreenshot {
            self.cell!.isUserInteractionEnabled = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear], animations: { [unowned self] in
                self.setActionsheet(for: .position(contentScreenshot.frame.origin.x), orientation: .close)
                self.container.layoutIfNeeded()
                }, completion: { [unowned self] _ in
                    self.cell!.isUserInteractionEnabled = true
                    self.actionsheet(side: side).actions.forEach {
                        $0.update(state: .active)
                    }
                    completionHandler?()
            })
        }
    }
    
    // MARK: Action Animate
    /// Animate actions & contentScreenshot with orientation Open to Close
    func animateOpenToClose(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let contentScreenshot = contentScreenshot {
            self.cell!.isUserInteractionEnabled = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear], animations: { [unowned self] in
                contentScreenshot.frame.origin.x = self.positionForClose()
                self.setActionsheet(for: .close, orientation: .close)
                self.container.layoutIfNeeded()
                }, completion: { [unowned self] _ in
                    self.cell!.isUserInteractionEnabled = true
                    self.clearActionCell()
                    completionHandler?()
            })
        }
    }
    
    /// Animate actions & contentScreenshot with orientation Close to Open
    func animateCloseToOpen(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            self.cell!.isUserInteractionEnabled = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear], animations: { [unowned self] in
                contentScreenshot.frame.origin.x = self.positionForOpen(side: side)
                self.setActionsheet(for: .open, orientation: .triggered)
                self.container.layoutIfNeeded()
                }, completion: { [unowned self] _ in
                    self.cell!.isUserInteractionEnabled = true
                    completionHandler?()
            })
        }
    }
    
    /// Animate actions & contentScreenshot with orientation Trigger to Open
    func animateTriggerToOpen(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            self.cell!.isUserInteractionEnabled = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear], animations: { [unowned self] in
                contentScreenshot.frame.origin.x = self.positionForOpen(side: side)
                self.setActionsheet(for: .open, orientation: .close)
                self.container.layoutIfNeeded()
                }, completion: { [unowned self] _ in
                    self.cell!.isUserInteractionEnabled = true
                    completionHandler?()
            })
        }
    }
    
    /// Animate actions & contentScreenshot with orientation Open to Trigger
    func animateOpenToTrigger(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            actionsheet(side: side).actions.forEach {
                if $0 != self.defaultAction {
                    $0.update(state: .inactive)
                }
            }
            self.cell!.isUserInteractionEnabled = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear], animations: { [unowned self] in
                contentScreenshot.frame.origin.x = self.positionForTrigger(side: side)
                let position = self.positionForTrigger(side: side)
                if let action = self.defaultAction {
                    self.updateActionConstraints(action: action, orientation: .triggered, constantHead: position + (side == .left ? -1 : 1) * action.width, constantTail: position)
                }
                self.container.layoutIfNeeded()
                }, completion: { [unowned self] _ in
                    self.cell!.isUserInteractionEnabled = true
                    let action = self.defaultAction
                    self.clearActionCell {
                        action?.actionTriggered()
                    }
                    completionHandler?()
            })
        }
    }
    
    /// Animate actions to position, when the cell is panned
    func animateToPosition(_ position: CGFloat, orientation: AnimateOrientation, completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let side = currentActionsheet?.side {
            switch positionSection(side: side, position: position) {
            case .close_OpenPre, .openPre_Open, .open_TriggerPre:
                if isDefaultActionTriggered == true {
                    isDefaultActionTriggered = false
                    animateDefaultActionCancelled(completionHandler: completionHandler)
                } else {
                    setActionsheet(for: .position(position), orientation: orientation)
                    completionHandler?()
                }
            case .triggerPre_Trigger:
                if isDefaultActionTriggered == false {
                    isDefaultActionTriggered = true
                    animateDefaultActionTriggered(completionHandler: completionHandler)
                } else {
                    setActionsheet(for: .position(position), orientation: orientation)
                    completionHandler?()
                }
            }
        }
    }
    
    // MARK: Handle Gestures
    func handleSwipeGestureRecognizer(_ gestureRecognizer: UISwipeGestureRecognizer) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        switch gestureRecognizer.state {
        case .ended:
            if gestureRecognizer.direction == UISwipeGestureRecognizerDirection.left {
                respondToSwipe(side: .right)
            } else {
                respondToSwipe(side: .left)
            }
        default:
            break
        }
    }
    
    func respondToSwipe(side: ActionSide) {
        if let currentActionsheet = currentActionsheet {
            if currentActionsheet.side == side {
                if enableDefaultAction {
                    animateOpenToTrigger()
                }
            } else {
                animateOpenToClose()
            }
        } else {
            openActionsheet(side: side)
        }
    }
    
    func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        let translation = gestureRecognizer.translation(in: cell!.contentView)
        let velocity = gestureRecognizer.velocity(in: cell!.contentView)
        switch gestureRecognizer.state {
        case .began, .changed:
            #if DEVELOPMENT
                print("state -- " + "began | changed")
            #endif
            
            var actionSide: ActionSide? = nil
            if let contentScreenshot = contentScreenshot {
                let contentPosition = contentScreenshot.frame.origin.x
                actionSide = contentPosition == 0 ? (velocity.x == 0 ? nil : (velocity.x > 0 ? .left : .right)) : (contentPosition > 0 ? .left : .right)
            } else {
                actionSide = velocity.x > 0 ? .left : .right
            }
            if actionSide != currentActionsheet?.side {
                clearActionCell()
                if let actionSide = actionSide {
                    setupActionCell(side: actionSide)
                }
            }
            
            if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side, isActionsheetValid(side: side) {
                switch positionSection(side: side, position: contentScreenshot.frame.origin.x) {
                case .open_TriggerPre, .triggerPre_Trigger:
                    if enableDefaultAction == true { fallthrough }
                default:
                    contentScreenshot.frame.origin.x += translation.x
                    gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                    let orientation: AnimateOrientation = (side == .left) ? (velocity.x > 0 ? .triggered : .close) : (velocity.x < 0 ? .triggered : .close)
                    animateToPosition(contentScreenshot.frame.origin.x, orientation: orientation)
                }
            }
        case .ended, .cancelled:
            #if DEVELOPMENT
                print("state -- " + "ended | cancelled")
            #endif
            
            var closure: (() -> ())? = nil
            if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
                switch positionSection(side: side, position: contentScreenshot.frame.origin.x) {
                case .close_OpenPre:
                    closure = { [weak self] in
                        self?.animateOpenToClose()
                    }
                case .openPre_Open:
                    closure = { [weak self] in
                        self?.animateCloseToOpen()
                    }
                case .open_TriggerPre:
                    closure = enableDefaultAction ? { [weak self] in
                        self?.animateTriggerToOpen()
                        } : nil
                case .triggerPre_Trigger:
                    closure = enableDefaultAction ? { [weak self] in
                        self?.animateOpenToTrigger()
                        } : nil
                }
                let orientation: AnimateOrientation = (side == .left) ? (velocity.x > 0 ? .triggered : .close) : (velocity.x < 0 ? .triggered : .close)
                animateToPosition(contentScreenshot.frame.origin.x, orientation: orientation, completionHandler: closure)
            }
        default:
            break
        }
    }
    
    func handleTempTapGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        animateOpenToClose()
    }
    
    // MARK: Position of cell state
    /// Threshold for state Close
    func positionForClose() -> CGFloat {
        return 0
    }
    
    /// Threshold for state Open
    func positionForOpen(side: ActionSide) -> CGFloat {
        switch side {
        case .left:
            return actionsheet(side: side).width
        case .right:
            return -1 * actionsheet(side: side).width
        }
    }
    
    /// Threshold for state OpenPrepare
    func positionForOpenPrepare(side: ActionSide) -> CGFloat {
        return positionForOpen(side: side) / 2.0
    }
    
    /// Threshold for state Trigger
    func positionForTrigger(side: ActionSide) -> CGFloat {
        switch side {
        case .left:
            return cell!.contentView.frame.width
        case .right:
            return -1 * cell!.contentView.frame.width
        }
    }
    
    /// Threshold for state TriggerPrepare
    func positionForTriggerPrepare(side: ActionSide) -> CGFloat {
        let actionsheetWidth = actionsheet(side: side).width
        switch side {
        case .left:
            return actionsheetWidth + (bounds.width - actionsheetWidth) * defaultActionTriggerPropotion
        case .right:
            return -1 * (actionsheetWidth + (bounds.width - actionsheetWidth) * defaultActionTriggerPropotion)
        }
    }
    
    /// Get the section of current position
    func positionSection(side: ActionSide, position: CGFloat) -> PositionSection {
        let absPosition = abs(position)
        if absPosition <= abs(positionForOpenPrepare(side: side)) {
            return .close_OpenPre
        } else if absPosition <= abs(positionForOpen(side: side)) {
            return .openPre_Open
        } else if absPosition <= abs(positionForTriggerPrepare(side: side)) {
            return .open_TriggerPre
        } else {
            return .triggerPre_Trigger
        }
    }
    
    /// Get laddering index
    func ladderingIndex(side: ActionSide, position: CGFloat) -> Int {
        let position = abs(position)
        
        var result: [(Int, ActionControl)] = []
        result = actionsheetActions(side: side).enumerated().filter({ (index, action) -> Bool in
            let widthPre = actionsheet(side: side).actionWidthBefore(actionIndex: index)
            return abs(position) >= widthPre && abs(position) < widthPre + action.width
        })
        if let currentAction = result.first {
            return currentAction.0
        } else {
            return actionsheetActions(side: side).count
        }
    }
    
    // MARK: Auxiliary
    /// 创建视图的截图
    func screenshotImageOfView(view: UIView) -> UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// Create screenshot of cell's contentView
    func takeScreenshot() -> UIImageView {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        let isBackgroundClear = cell!.contentView.backgroundColor == nil
        if isBackgroundClear {
            cell!.contentView.backgroundColor = UIColor.white
        }
        let screenshot = UIImageView(image: screenshotImageOfView(view: cell!.contentView))
        if isBackgroundClear {
            cell!.contentView.backgroundColor = nil
        }
        return screenshot
    }
}

extension ActionCell: UIGestureRecognizerDelegate {
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer, let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: self)
            return abs(velocity.x) > abs(velocity.y)
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == panGestureRecognizer || gestureRecognizer == tapGestureRecognizer || gestureRecognizer == swipeLeftGestureRecognizer || gestureRecognizer == swipeRightGestureRecognizer) && ( otherGestureRecognizer == delegate?.tableView.panGestureRecognizer || otherGestureRecognizer == delegate?.navigationController?.barHideOnSwipeGestureRecognizer || otherGestureRecognizer == delegate?.navigationController?.barHideOnTapGestureRecognizer) {
            return true
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == panGestureRecognizer || gestureRecognizer == tapGestureRecognizer || gestureRecognizer == swipeLeftGestureRecognizer || gestureRecognizer == swipeRightGestureRecognizer) && ( otherGestureRecognizer == delegate?.tableView.panGestureRecognizer || otherGestureRecognizer == delegate?.navigationController?.barHideOnSwipeGestureRecognizer || otherGestureRecognizer == delegate?.navigationController?.barHideOnTapGestureRecognizer) {
            return false
        }
        return true
    }
}

extension ActionCell: ActionControlDelegate {
    public func didActionTriggered(action: String) {
        #if DEVELOPMENT
            print("\(#function) -- " + "action: \(action)")
        #endif

        if currentActionsheet != nil {
            closeActionsheet() { [unowned self] in
                self.delegate?.didActionTriggered(cell: self.cell!, action: action)
            }
        } else {
            delegate?.didActionTriggered(cell: cell!, action: action)
        }
    }
}

public class Actionsheet {
    var side: ActionSide
    var actions: [ActionControl] = []
    
    /// sum of all actions' width
    var width: CGFloat {
        return actions.reduce(0, { (result, action) -> CGFloat in
            result + action.width
        })
    }
    
    init(side: ActionSide) {
        self.side = side
    }
    
    /// sum of width of actions which is previous to the action
    func actionWidthBefore(actionIndex index: Int) -> CGFloat {
        return actions.prefix(upTo: index).reduce(0, { (result, action) -> CGFloat in
            result + action.width
        })
    }
    
    /// sum of width of actions which is previous to the action
    func actionWidthAfter(actionIndex index: Int) -> CGFloat {
        return actions.suffix(from: index + 1).reduce(0, { (result, action) -> CGFloat in
            result + action.width
        })
    }
}

public enum ActionSide {
    case left
    case right
}

public enum ActionsheetOpenStyle {
    /// 动作按钮阶梯滑出
    case ladder
    /// 动作按钮阶梯滑出 + 图标文字渐显效果
    case ladder_emergence
    /// 动作按钮并列滑出
    case concurrent
}

public enum ActionsheetState {
    case close
    case open
    case position(CGFloat)
}

public enum AnimateOrientation {
    case close
    case triggered
}

public enum PositionSection {
    case close_OpenPre
    case openPre_Open
    case open_TriggerPre
    case triggerPre_Trigger
}
