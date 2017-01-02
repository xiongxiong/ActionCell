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

public protocol ActionSheetDelegate: NSObjectProtocol {
    /// Setup action sheet
    func setupActionsheet(side: ActionSide, actions: [ActionControl])
    /// Open action sheet
    func openActionsheet(side: ActionSide, completionHandler: (() -> ())?)
    /// Close action sheet
    func closeActionsheet(_ completionHandler: (() -> ())?)
}

extension UITableViewCell: ActionSheetDelegate {
    
    /// UITableViewCell's ActionCell wrapper
    public var actionCell: ActionCell? {
        var actionCell: ActionCell? = nil
        subviews.forEach({ (view) in
            if let wrapper = view as? ActionCell {
                actionCell = wrapper
            }
        })
        return actionCell
    }
    
    // MARK: ActionSheetDelegate
    public func setupActionsheet(side: ActionSide, actions: [ActionControl] = []) {
        actionCell?.setupActionSheet(side: side, actions: actions)
    }
    
    public func openActionsheet(side: ActionSide, completionHandler: (() -> ())? = nil) {
        actionCell?.openActionsheet(side: side, completionHandler: completionHandler)
    }
    
    public func closeActionsheet(_ completionHandler: (() -> ())? = nil) {
        actionCell?.closeActionsheet(completionHandler)
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
    /// Screenshot of the cell
    var contentScreenshot: UIImageView?
    /// Current actionsheet
    var currentActionsheet: Actionsheet?
    /// The default action to trigger when content is panned to the far side.
    var defaultAction: ActionControl?
    /// The default action is triggered or not
    var isDefaultActionTriggered: Bool = false
    /// ActionSheet opened or not
    open var isActionSheetOpened: Bool {
        return currentActionsheet != nil
    }
    
    /// If the cell's action sheet is about to open, ask delegate to close other cell's action sheet
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        next?.touchesBegan(touches, with: event)
        
        if !isActionSheetOpened {
            delegate?.closeActionsheet()
        }
    }
    
    // MARK: Initialization
    public func wrap(cell target: UITableViewCell, actionsLeft: [ActionControl] = [], actionsRight: [ActionControl] = []) {
        cell = target
        
        target.selectionStyle = .none
        target.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        target.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: target, attribute: .leading, multiplier: 1, constant: 0))
        target.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: target, attribute: .trailing, multiplier: 1, constant: 0))
        target.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: target, attribute: .top, multiplier: 1, constant: 0))
        target.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: target, attribute: .bottom, multiplier: 1, constant: 0))
        
        swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer(_:)))
        addGestureRecognizer(swipeLeftGestureRecognizer)
        swipeLeftGestureRecognizer.delegate = self
        swipeLeftGestureRecognizer.direction = .left
        
        swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer(_:)))
        addGestureRecognizer(swipeRightGestureRecognizer)
        swipeRightGestureRecognizer.delegate = self
        swipeRightGestureRecognizer.direction = .right
        swipeRightGestureRecognizer.require(toFail: swipeLeftGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        panGestureRecognizer.require(toFail: swipeLeftGestureRecognizer)
        panGestureRecognizer.require(toFail: swipeRightGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.require(toFail: swipeLeftGestureRecognizer)
        tapGestureRecognizer.require(toFail: swipeRightGestureRecognizer)
        tapGestureRecognizer.require(toFail: panGestureRecognizer)
        tapGestureRecognizer.isEnabled = false
        
        setupActionSheet(side: .left, actions: actionsLeft)
        setupActionSheet(side: .right, actions: actionsRight)
    }
    
    // MARK: Actionsheet
    /// Setup actionsheet
    func setupActionCell(side: ActionSide) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if isActionsheetValid(side: side) {
            contentScreenshot = takeScreenshot()
            addSubview(contentScreenshot!)
            
            currentActionsheet = actionsheet(side: side)
            defaultAction = defaultAction(side: side)
            backgroundColor = defaultAction?.backgroundColor
            tapGestureRecognizer.isEnabled = true
        }
    }
    
    /// Clear actionsheet when actionsheet is closed
    func clearActionCell(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if isActionSheetOpened {
            backgroundColor = UIColor.clear
            setActionConstraintsForClose()
            
            currentActionsheet?.actions.forEach({ (action) in
                action.setState(.outside)
            })
            currentActionsheet = nil
            
            isDefaultActionTriggered = false
            defaultAction = nil
            contentScreenshot?.removeFromSuperview()
            contentScreenshot = nil
            
            tapGestureRecognizer.isEnabled = false
        }
        completionHandler?()
    }
    
    /// Setup action sheet
    func setupActionSheet(side: ActionSide, actions: [ActionControl]) {
        #if DEVELOPMENT
            print("\(#function) -- " + "side: \(side)")
        #endif
        
        actionsheet(side: side).actions = actions
        actionsheet(side: side).actions.reversed().forEach {
            $0.delegate = self
            addSubview($0)
        }
        setupActionConstraints(side: side)
        setupActionAttributes(side: side)
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
        
        if isActionSheetOpened {
            animateOpenToClose(completionHandler)
        }
    }
    
    // MARK: Action Constraints
    /// Set actions' constraints for beginning
    func setupActionConstraints(side: ActionSide) {
        #if DEVELOPMENT
            print("\(#function) -- " + "side: \(side)")
        #endif
        
        actionsheet(side: side).actions.enumerated().forEach { (index, action) in
            action.translatesAutoresizingMaskIntoConstraints = false
            addConstraint(NSLayoutConstraint(item: action, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: action, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            switch side {
            case .left:
                let constraintLeading = NSLayoutConstraint(item: action, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: -1 * action.width)
                action.constraintLeading = constraintLeading
                addConstraint(constraintLeading)
                let constraintTrailing = NSLayoutConstraint(item: action, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
                action.constraintTrailing = constraintTrailing
                addConstraint(constraintTrailing)
            case .right:
                let constraintLeading = NSLayoutConstraint(item: action, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
                action.constraintLeading = constraintLeading
                addConstraint(constraintLeading)
                let constraintTrailing = NSLayoutConstraint(item: action, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: action.width)
                action.constraintTrailing = constraintTrailing
                addConstraint(constraintTrailing)
            }
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// Set actions' constraints for state Close
    func setActionConstraintsForClose() {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        currentActionsheet?.actions.enumerated().forEach({ (index, action) in
            if let side = currentActionsheet?.side {
                updateSingleActionConstraints(action: action) {
                    switch side {
                    case .left:
                        action.constraintLeading?.constant = -1 * action.width
                        action.constraintTrailing?.constant = 0
                    case .right:
                        action.constraintTrailing?.constant = action.width
                        action.constraintLeading?.constant = 0
                    }
                }
            }
        })
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// Set actions' constraints for state Open
    func setActionConstraintsForOpen() {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        currentActionsheet?.actions.enumerated().forEach({ (index, action) in
            if let side = currentActionsheet?.side {
                let widthPre = currentActionsheet?.actionWidthBefore(actionIndex: index) ?? 0
                updateSingleActionConstraints(action: action) {
                    switch side {
                    case .left:
                        action.constraintTrailing?.constant = widthPre + action.width
                        action.constraintLeading?.constant = widthPre
                    case .right:
                        action.constraintLeading?.constant = -1 * (widthPre + action.width)
                        action.constraintTrailing?.constant = -1 * widthPre
                    }
                }
            }
        })
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// Get actions' constraints for position
    func setActionConstraintsForPosition(position: CGFloat) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        currentActionsheet?.actions.enumerated().forEach({ (index, action) in
            if let side = currentActionsheet?.side {
                let widthPre = currentActionsheet?.actionWidthBefore(actionIndex: index) ?? 0
                if isDefaultActionTriggered && action == defaultAction {
                    setDefaultActionConstraintsForPosition(position: position)
                } else {
                    switch positionSection(side: side, position: position) {
                    case .close_OpenPre, .openPre_Open:
                        switch animationStyle {
                        case .ladder, .ladder_emergence:
                            updateSingleActionConstraints(action: action) {
                                let currentActionIndex = ladderingIndex(side: side, position: position)
                                if index >= currentActionIndex {
                                    switch side {
                                    case .left:
                                        action.constraintTrailing?.constant = position
                                        action.constraintLeading?.constant = position - action.width
                                    case .right:
                                        action.constraintLeading?.constant = position
                                        action.constraintTrailing?.constant = position + action.width
                                    }
                                } else {
                                    switch side {
                                    case .left:
                                        action.constraintTrailing?.constant = widthPre + action.width
                                        action.constraintLeading?.constant = widthPre
                                    case .right:
                                        action.constraintLeading?.constant = -1 * (widthPre + action.width)
                                        action.constraintTrailing?.constant = -1 * widthPre
                                    }
                                }
                            }
                        case .concurrent:
                            var targetPosition = position
                            if abs(targetPosition) > abs(positionForOpen(side: side)) {
                                targetPosition = positionForOpen(side: side)
                            }
                            updateSingleActionConstraints(action: action) {
                                let actionAnchorPosition = targetPosition * (actionsheet(side: side).actionWidthBefore(actionIndex: index) + action.width) / actionsheet(side: side).width
                                switch side {
                                case .left:
                                    action.constraintTrailing?.constant = actionAnchorPosition
                                    action.constraintLeading?.constant = actionAnchorPosition - action.width
                                case .right:
                                    action.constraintLeading?.constant = actionAnchorPosition
                                    action.constraintTrailing?.constant = actionAnchorPosition + action.width
                                }
                            }
                        }
                    case .open_TriggerPre:
                        switch side {
                        case .left:
                            action.constraintTrailing?.constant = position - actionsheet(side: side).actionWidthAfter(actionIndex: index)
                        case .right:
                            action.constraintLeading?.constant = position + actionsheet(side: side).actionWidthAfter(actionIndex: index)
                        }
                        if action != defaultAction {
                            switch side {
                            case .left:
                                action.constraintLeading?.constant = position - actionsheet(side: side).actionWidthAfter(actionIndex: index) - action.width
                            case .right:
                                action.constraintTrailing?.constant = position + actionsheet(side: side).actionWidthAfter(actionIndex: index) + action.width
                            }
                        }
                    default:
                        break
                    }
                    
                }
            }
        })
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: Action Attributes
    /// Setup actions' attributes
    func setupActionAttributes(side: ActionSide) {
        #if DEVELOPMENT
            print("\(#function) -- " + "side: \(side)")
        #endif
        
        actionsheet(side: side).actions.forEach {
            $0.setState(.outside)
        }
    }
    
    /// Set actions' attributes for state Close
    func setActionAttributesForClose() {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        currentActionsheet?.actions.forEach {
            $0.setState(.outside)
        }
    }
    
    /// Set actions' attributes for state Open
    func setActionAttributesForOpen() {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        currentActionsheet?.actions.forEach {
            $0.setState(.inside)
        }
    }
    
    /// Set actions' attributes for position
    func setActionAttributesForPosition(position: CGFloat) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        currentActionsheet?.actions.enumerated().forEach { (index, action) in
            if let side = currentActionsheet?.side {
                switch positionSection(side: side, position: position) {
                case .close_OpenPre, .openPre_Open:
                    let widthPre = currentActionsheet?.actionWidthBefore(actionIndex: index) ?? 0
                    switch animationStyle {
                    case .ladder_emergence:
                        let currentLadderIndex = ladderingIndex(side: side, position: position)
                        if index == currentLadderIndex {
                            let progress = ((abs(position) - widthPre) / action.width).truncatingRemainder(dividingBy: 1)
                            action.setState(.outside_inside(progress: progress))
                        } else if index < currentLadderIndex {
                            action.setState(.inside)
                        }
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
    }
    
    // MARK: Default Action
    /// Set defaultAction's constraints for position, when defaultAction is triggered
    func setDefaultActionConstraintsForPosition(position: CGFloat) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let side = currentActionsheet?.side, let defaultAction = defaultAction {
            switch side {
            case .left:
                defaultAction.constraintTrailing?.constant = position
                defaultAction.constraintLeading?.constant = position - defaultAction.width
            case .right:
                defaultAction.constraintLeading?.constant = position
                defaultAction.constraintTrailing?.constant = position + defaultAction.width
            }
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// Animate when default action is triggered
    func animateDefaultActionTriggered(completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        self.currentActionsheet?.actions.forEach {
            if $0 != self.defaultAction {
                $0.setState(.inactive)
            }
        }
        if let side = currentActionsheet?.side {
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.enableGestureRecognizers(false)
                self.setDefaultActionConstraintsForPosition(position: self.positionForTriggerPrepare(side: side))
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.enableGestureRecognizers(true)
                    }
            })
        }
    }
    
    /// Animate when default action's trigger is cancelled
    func animateDefaultActionCancelled(completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let side = currentActionsheet?.side, let contentScreenshot = contentScreenshot {
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.enableGestureRecognizers(false)
                self.setActionConstraintsForPosition(position: contentScreenshot.frame.origin.x)
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.enableGestureRecognizers(true)
                        self.actionsheet(side: side).actions.forEach {
                            $0.setState(.inside)
                        }
                    }
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
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.enableGestureRecognizers(false)
                contentScreenshot.frame.origin.x = self.positionForClose()
                self.setActionConstraintsForClose()
                self.setActionAttributesForClose()
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.enableGestureRecognizers(true)
                        self.clearActionCell()
                    }
            })
        }
    }
    
    /// Animate actions & contentScreenshot with orientation Close to Open
    func animateCloseToOpen(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.enableGestureRecognizers(false)
                contentScreenshot.frame.origin.x = self.positionForOpen(side: side)
                self.setActionConstraintsForOpen()
                self.setActionAttributesForOpen()
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.enableGestureRecognizers(true)
                    }
            })
        }
    }
    
    /// Animate actions & contentScreenshot with orientation Trigger to Open
    func animateTriggerToOpen(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.enableGestureRecognizers(false)
                contentScreenshot.frame.origin.x = self.positionForOpen(side: side)
                self.defaultAction?.setState(.inside)
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.enableGestureRecognizers(true)
                    }
            })
        }
    }
    
    /// Animate actions & contentScreenshot with orientation Open to Trigger
    func animateOpenToTrigger(_ completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.enableGestureRecognizers(false)
                contentScreenshot.frame.origin.x = self.positionForTrigger(side: side)
                self.setDefaultActionConstraintsForPosition(position: self.positionForTrigger(side: side))
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.enableGestureRecognizers(true)
                        if let defaultAction = self.defaultAction {
                            self.clearActionCell {
                                defaultAction.actionTriggered()
                            }
                        }
                    }
            })
        }
    }
    
    /// Animate actions to position, when the cell is panned
    func animateToPosition(_ position: CGFloat, completionHandler: (() -> ())? = nil) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let side = currentActionsheet?.side {
            setActionConstraintsForPosition(position: position)
            setActionAttributesForPosition(position: position)
            
            switch positionSection(side: side, position: position) {
            case .close_OpenPre, .openPre_Open, .open_TriggerPre:
                if isDefaultActionTriggered == true {
                    isDefaultActionTriggered = false
                    animateDefaultActionCancelled(completionHandler: completionHandler)
                } else {
                    completionHandler?()
                }
            case .triggerPre_Trigger:
                if isDefaultActionTriggered == false {
                    isDefaultActionTriggered = true
                    animateDefaultActionTriggered(completionHandler: completionHandler)
                } else {
                    completionHandler?()
                }
            }
        }
    }
    
    // MARK: Action
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
    
    /// Update single action's constraints
    func updateSingleActionConstraints(action: ActionControl, updateClosure: () -> ()) {
        if let constraintLeading = action.constraintLeading, let constraintTrailing = action.constraintTrailing {
            removeConstraints([constraintLeading, constraintTrailing])
            updateClosure()
            addConstraints([constraintLeading, constraintTrailing])
        }
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
            return bounds.width
        case .right:
            return -1 * bounds.width
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
    
    // MARK: UIGestureRecognizerDelegate
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        if let g = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = g.velocity(in: self)
            if fabs(velocity.x) > fabs(velocity.y) {
                return true
            } else {
                return false
            }
        } else {
            return true
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
        if !isActionSheetOpened {
            openActionsheet(side: side)
        } else if currentActionsheet?.side == side {
            animateOpenToTrigger()
        } else {
            animateOpenToClose()
        }
    }
    
    func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        let translation = gestureRecognizer.translation(in: self)
        let velocity = gestureRecognizer.velocity(in: self)
        switch gestureRecognizer.state {
        case .began, .changed:
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
            
            if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side , isActionsheetValid(side: side) {
                let openPosition = positionForOpen(side: side)
                
                contentScreenshot.frame.origin.x += translation.x
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                if enableDefaultAction == false, abs(contentScreenshot.frame.origin.x) >= openPosition {
                    contentScreenshot.frame.origin.x = openPosition
                }
                animateToPosition(contentScreenshot.frame.origin.x)
            }
        case .ended, .cancelled:
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
                    closure = { [weak self] in
                        self?.animateOpenToTrigger()
                    }
                }
                animateToPosition(contentScreenshot.frame.origin.x, completionHandler: closure)
            }
        default:
            break
        }
    }
    
    func handleTapGestureRecognizer(_ gestureRecognizer: UISwipeGestureRecognizer) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        let location = gestureRecognizer.location(in: self)
        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            switch side {
            case .left:
                if location.x >= contentScreenshot.frame.origin.x {
                    animateOpenToClose()
                }
            case .right:
                if location.x <= bounds.width + contentScreenshot.frame.origin.x {
                    animateOpenToClose()
                }
            }
        }
    }
    
    /// Enable or disable gesture recognizers
    func enableGestureRecognizers(_ isEnabled: Bool) {
        swipeLeftGestureRecognizer.isEnabled = isEnabled
        swipeRightGestureRecognizer.isEnabled = isEnabled
        panGestureRecognizer.isEnabled = isEnabled
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

public enum PositionSection {
    case close_OpenPre
    case openPre_Open
    case open_TriggerPre
    case triggerPre_Trigger
}
