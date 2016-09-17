//
//  SwipeCell.swift
//  SwipeCell
//
//  Created by 王继荣 on 9/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class ActionCell<CellAction: ActionControl where CellAction: CellActionProtocol>: UITableViewCell {
    
    // MARK: SwipeCell - 动作设置
    /// Actions - Left
    public var actionsLeft: [CellAction] {
        get {
            return actionSheetLeft.actions
        }
        set {
            actionSheetLeft.actions = newValue
            actionSheetLeft.actions.forEach {
                $0.delegate = self
            }
        }
    }
    /// Actions - Right
    public var actionsRight: [CellAction] {
        get {
            return actionSheetRight.actions
        }
        set {
            actionSheetRight.actions = newValue
            actionSheetRight.actions.forEach {
                $0.delegate = self
            }
        }
    }
    
    // MARK: SwipeCell - 样式设置
    /// Action 动画形式
    public var animationStyle: AnimationStyle = .concurrent
    /// The propotion of (state public to state trigger-prepare / state public to state trigger), about where the default action is triggered
    public var defaultActionTriggerPropotion: CGFloat = 0.3 {
        willSet {
            guard newValue > 0.1 && newValue < 0.5 else {
                fatalError("defaultActionTriggerPropotion -- value out of range, value must between 0.1 and 0.5")
            }
        }
    }
    /// Default action's icon color
    public var defaultActionIconColor: UIColor? = nil
    /// Default action's back image
    public var defaultActionBackImage: UIImage? = nil
    /// Default action's back color
    public var defaultActionBackColor: UIColor? = nil
    
    // MARK: SwipeCell - 行为设置
    /// Enable default action to be triggered when the content is panned to far enough
    public var enableDefaultAction: Bool = true
    /// Index of default action - Left
    public var defaultActionIndexLeft: Int = 0
    /// Index of default action - Right
    public var defaultActionIndexRight: Int = 0
    
    // MARK: SwipeCell - 动画设置
    /// Spring animation - duration of the animation
    public var animationDuration: TimeInterval = 0.3
    /// Spring animation - delay of the animation
    public var animationDelay: TimeInterval = 0
    /// Spring animation - spring damping of the animation
    public var springDamping: CGFloat = 1 {
        willSet {
            guard newValue > 0 else {
                fatalError("springDamping -- value is not valid, value must be greater than 0")
            }
        }
    }
    /// Spring animation - initial spring velocity of the animation
    public var initialSpringVelocity: CGFloat = 0
    /// Spring animation - options of the animation
    public var animationOptions: UIViewAnimationOptions = .curveLinear
    
    // MARK: SwipeCell - 私有属性
    /// actionSheet - Left
    var actionSheetLeft: ActionSheet = ActionSheet<CellAction>(side: .left)
    /// actionSheet - Right
    var actionSheetRight: ActionSheet = ActionSheet<CellAction>(side: .right)
    /// panGestureRecognizer
    var panGestureRecognizer: UIPanGestureRecognizer!
    /// tapGestureRecognizer
    var tapGestureRecognizer: UITapGestureRecognizer!
    /// Screenshot of the cell
    var contentScreenshot: UIImageView? = nil
    /// Current action side
    var currentActionSheet: ActionSheet<CellAction>? = nil
    /// Container for current actions
    var actionContainer: UIView = UIView()
    /// The default action to trigger when content is panned to the far side.
    var defaultAction: ActionControl? = nil
    /// The default action is triggered or not
    var isDefaultActionTriggered: Bool = false
    /// Enable log
    var enableLog: Bool = false
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.require(toFail: panGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        initialize()
    }
    
    // MARK: Initialization
    func initialize() {
        clearActionSheet()
    }
    
    /// Setup action sheet
    func setupActionSheet(side: ActionSide) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        if isCurrentActionSheetValid(side: side) {
            contentScreenshot = takeScreenShot()
            
            contentView.addSubview(actionContainer)
            currentActionSheet = getCurrentActionSheet(side: side)
            defaultAction = getDefaultAction(side: side)
            actionContainer.backgroundColor = defaultAction?.backgroundColor ?? UIColor.white
            currentActionSheet?.actions.reversed().forEach {
                actionContainer.addSubview($0)
            }
            setupActionConstraints()
            setActionAttributesForClose()
            
            contentView.addSubview(contentScreenshot!)
            
            tapGestureRecognizer.isEnabled = true
        }
    }
    
    /// Clear action sheet when action sheet is closed
    func clearActionSheet() {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        defaultAction?.refresh()
        defaultAction = nil
        
        currentActionSheet?.actions.forEach {
            $0.removeFromSuperview()
        }
        currentActionSheet = nil
        actionContainer.removeFromSuperview()
        
        contentScreenshot?.removeFromSuperview()
        contentScreenshot = nil
        
        tapGestureRecognizer.isEnabled = false
    }
    
    // MARK: Action Constraints
    /// Set actions' constraints for beginning
    func setupActionConstraints() {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        actionContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: .alignAllLastBaseline, metrics: nil, views: ["container" : actionContainer]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|", options: .alignAllLastBaseline, metrics: nil, views: ["container" : actionContainer]))
        
        actionContainer.removeConstraints(actionContainer.constraints)
        currentActionSheet?.actions.enumerated().forEach { (index, action) in
            action.translatesAutoresizingMaskIntoConstraints = false
            actionContainer.addConstraint(NSLayoutConstraint(item: action, attribute: .top, relatedBy: .equal, toItem: actionContainer, attribute: .top, multiplier: 1, constant: 0))
            actionContainer.addConstraint(NSLayoutConstraint(item: action, attribute: .bottom, relatedBy: .equal, toItem: actionContainer, attribute: .bottom, multiplier: 1, constant: 0))
            if let side = currentActionSheet?.side {
                let widthPre = currentActionSheet?.actionPreWidth(actionIndex: index) ?? 0
                switch animationStyle {
                case .none:
                    switch side {
                    case .left:
                        let constraintLeading = NSLayoutConstraint(item: action, attribute: .leading, relatedBy: .equal, toItem: actionContainer, attribute: .leading, multiplier: 1, constant: widthPre)
                        action.constraintLeading = constraintLeading
                        actionContainer.addConstraint(constraintLeading)
                        let constraintTrailing = NSLayoutConstraint(item: action, attribute: .trailing, relatedBy: .equal, toItem: actionContainer, attribute: .leading, multiplier: 1, constant: widthPre + action.width)
                        action.constraintTrailing = constraintTrailing
                        actionContainer.addConstraint(constraintTrailing)
                    case .right:
                        let constraintLeading = NSLayoutConstraint(item: action, attribute: .leading, relatedBy: .equal, toItem: actionContainer, attribute: .trailing, multiplier: 1, constant: -1 * (widthPre + action.width))
                        action.constraintLeading = constraintLeading
                        actionContainer.addConstraint(constraintLeading)
                        let constraintTrailing = NSLayoutConstraint(item: action, attribute: .trailing, relatedBy: .equal, toItem: actionContainer, attribute: .trailing, multiplier: 1, constant: -1 * widthPre)
                        action.constraintTrailing = constraintTrailing
                        actionContainer.addConstraint(constraintTrailing)
                    }
                case .ladder, .ladder_emergence, .concurrent:
                    switch side {
                    case .left:
                        let constraintLeading = NSLayoutConstraint(item: action, attribute: .leading, relatedBy: .equal, toItem: actionContainer, attribute: .leading, multiplier: 1, constant: -1 * action.width)
                        action.constraintLeading = constraintLeading
                        actionContainer.addConstraint(constraintLeading)
                        let constraintTrailing = NSLayoutConstraint(item: action, attribute: .trailing, relatedBy: .equal, toItem: actionContainer, attribute: .leading, multiplier: 1, constant: 0)
                        action.constraintTrailing = constraintTrailing
                        actionContainer.addConstraint(constraintTrailing)
                    case .right:
                        let constraintLeading = NSLayoutConstraint(item: action, attribute: .leading, relatedBy: .equal, toItem: actionContainer, attribute: .trailing, multiplier: 1, constant: 0)
                        action.constraintLeading = constraintLeading
                        actionContainer.addConstraint(constraintLeading)
                        let constraintTrailing = NSLayoutConstraint(item: action, attribute: .trailing, relatedBy: .equal, toItem: actionContainer, attribute: .trailing, multiplier: 1, constant: action.width)
                        action.constraintTrailing = constraintTrailing
                        actionContainer.addConstraint(constraintTrailing)
                    }
                }
            }
        }
        actionContainer.setNeedsLayout()
        actionContainer.layoutIfNeeded()
    }
    
    /// Set actions' constraints for state Close
    func setActionConstraintsForClose() {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        currentActionSheet?.actions.enumerated().forEach({ (index, action) in
            if let side = currentActionSheet?.side {
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
        actionContainer.setNeedsLayout()
        actionContainer.layoutIfNeeded()
    }
    
    /// Set actions' constraints for state Open
    func setActionConstraintsForOpen() {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        currentActionSheet?.actions.enumerated().forEach({ (index, action) in
            if let side = currentActionSheet?.side {
                let widthPre = currentActionSheet?.actionPreWidth(actionIndex: index) ?? 0
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
        actionContainer.setNeedsLayout()
        actionContainer.layoutIfNeeded()
    }
    
    /// Get actions' constraints for position
    func setActionConstraintsForPosition(position: CGFloat) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        currentActionSheet?.actions.enumerated().forEach({ (index, action) in
            if let side = currentActionSheet?.side {
                let widthPre = currentActionSheet?.actionPreWidth(actionIndex: index) ?? 0
                if isDefaultActionTriggered && action == defaultAction {
                    setDefaultActionConstraintsForPosition(position: position)
                } else {
                    switch animationStyle {
                    case .none:
                        break
                    case .ladder, .ladder_emergence:
                        updateSingleActionConstraints(action: action) {
                            let currentActionIndex = ladderingIndex(side: side, position: position)
                            if index >= currentActionIndex {
                                switch side {
                                case .left:
                                    action.constraintLeading?.constant = position - action.width
                                    action.constraintTrailing?.constant = position
                                case .right:
                                    action.constraintLeading?.constant = position
                                    action.constraintTrailing?.constant = position + action.width
                                }
                            } else {
                                switch side {
                                case .left:
                                    action.constraintLeading?.constant = widthPre
                                    action.constraintTrailing?.constant = widthPre + action.width
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
                            let actionTrailingPosition = targetPosition * (getCurrentActionSheet(side: side).actionPreWidth(actionIndex: index) + action.width) / getCurrentActionSheet(side: side).width
                            switch side {
                            case .left:
                                action.constraintLeading?.constant = actionTrailingPosition - action.width
                                action.constraintTrailing?.constant = actionTrailingPosition
                            case .right:
                                action.constraintLeading?.constant = actionTrailingPosition
                                action.constraintTrailing?.constant = actionTrailingPosition + action.width
                            }
                        }
                    }
                }
            }
        })
        actionContainer.setNeedsLayout()
        actionContainer.layoutIfNeeded()
    }
    
    // MARK: Action Attributes
    /// Set actions' attributes for state Close
    func setActionAttributesForClose() {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        currentActionSheet?.actions.forEach {
            $0.setForeAlpha(alpha: 1)
        }
    }
    
    /// Set actions' attributes for state Open
    func setActionAttributesForOpen() {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        currentActionSheet?.actions.forEach {
            $0.setForeAlpha(alpha: 1)
        }
    }
    
    /// Set actions' attributes for position
    func setActionAttributesForPosition(position: CGFloat) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        currentActionSheet?.actions.enumerated().forEach { (index, action) in
            if let side = currentActionSheet?.side {
                let widthPre = currentActionSheet?.actionPreWidth(actionIndex: index) ?? 0
                switch animationStyle {
                case .ladder_emergence:
                    let currentLadderIndex = ladderingIndex(side: side, position: position)
                    if index == currentLadderIndex {
                        let currentForeAlpha = ((abs(position) - widthPre) / action.width).truncatingRemainder(dividingBy: 1)
                        action.setForeAlpha(alpha: currentForeAlpha)
                    } else if index < currentLadderIndex {
                        action.setForeAlpha(alpha: 1)
                    } else {
                        action.setForeAlpha(alpha: 0)
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
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let side = currentActionSheet?.side {
            switch side {
            case .left:
                defaultAction?.constraintLeading?.constant = 0
                defaultAction?.constraintTrailing?.constant = position
            case .right:
                defaultAction?.constraintLeading?.constant = position
                defaultAction?.constraintTrailing?.constant = 0
            }
        }
        actionContainer.setNeedsLayout()
        actionContainer.layoutIfNeeded()
    }
    
    /// Animate when default action is triggered
    func animateDefaultActionTriggered(completionHandler: (() -> ())? = nil) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let side = currentActionSheet?.side {
            setDefaultActionConstraintsForPosition(position: self.positionForTriggerPrepare(side: side))
            currentActionSheet?.actions.forEach {
                if $0 == self.defaultAction {
                    $0.setForeColor(color: self.defaultActionIconColor ?? $0.foreColor)
                    $0.backgroundColor = self.defaultActionBackColor ?? $0.backColor
                } else {
                    $0.alpha = 0
                }
            }
            completionHandler?()
        }
    }
    
    /// Animate when default action's trigger is cancelled
    func animateDefaultActionCancelled(completionHandler: (() -> ())? = nil) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let side = currentActionSheet?.side {
            setActionConstraintsForOpen()
            currentActionSheet?.actions.forEach {
                if $0 == self.defaultAction {
                    $0.refresh()
                } else {
                    $0.alpha = 1
                }
            }
            completionHandler?()
        }
    }
    
    // MARK: Action Animate
    /// Animate actions & contentScreenshot from state OpenPrepare to state Close, when gesture recognizer ended or cancelled
    func animateOpenPreToClose(_ completionHandler: (() -> ())? = nil) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let contentScreenshot = contentScreenshot {
            UIView.animate(withDuration: animationDuration, delay: animationDelay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
                contentScreenshot.frame.origin.x = self.positionForClose()
                self.setActionConstraintsForClose()
                self.setActionAttributesForClose()
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.clearActionSheet()
                    }
            })
        }
    }
    
    /// Animate actions & contentScreenshot from state OpenPrepare to state Open, when gesture recognizer ended or cancelled
    func animateOpenPreToOpen(_ completionHandler: (() -> ())? = nil) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let contentScreenshot = contentScreenshot, let side = currentActionSheet?.side {
            UIView.animate(withDuration: animationDuration, delay: animationDelay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
                contentScreenshot.frame.origin.x = self.positionForOpen(side: side)
                self.setActionConstraintsForOpen()
                self.setActionAttributesForOpen()
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                    }
            })
        }
    }
    
    /// Animate actions & contentScreenshot from state TriggerPrepare to state Open, when gesture recognizer ended or cancelled
    func animateTriggerPreToOpen(_ completionHandler: (() -> ())? = nil) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let contentScreenshot = contentScreenshot, let side = currentActionSheet?.side {
            UIView.animate(withDuration: animationDuration, delay: animationDelay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
                contentScreenshot.frame.origin.x = self.positionForOpen(side: side)
                self.defaultAction?.refresh()
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                    }
            })
        }
    }
    
    /// Animate actions & contentScreenshot to state Trigger, when gesture recognizer ended or cancelled
    func animateTriggerPreToTrigger(_ completionHandler: (() -> ())? = nil) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let contentScreenshot = contentScreenshot, let side = currentActionSheet?.side {
            UIView.animate(withDuration: animationDuration, delay: animationDelay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
                contentScreenshot.frame.origin.x = self.positionForTrigger(side: side)
                self.setDefaultActionConstraintsForPosition(position: self.positionForTrigger(side: side))
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.defaultAction?.actionTriggered()
                        self.clearActionSheet()
                    }
            })
        }
    }
    
    /// Animate actions & contentScreenshot from state Open to state Close, when tap gesture is recognized to close the action sheet
    func animateOpenToClose(_ completionHandler: (() -> ())? = nil) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let contentScreenshot = contentScreenshot, let side = currentActionSheet?.side {
            UIView.animate(withDuration: animationDuration, delay: animationDelay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: animationOptions, animations: {
                contentScreenshot.frame.origin.x = self.positionForClose()
                self.setActionConstraintsForClose()
                self.setActionAttributesForClose()
                }, completion: { finished in
                    if finished {
                        completionHandler?()
                        self.clearActionSheet()
                    }
            })
        }
    }
    
    /// Animate actions to position, when the cell is panned
    func animateToPosition(_ position: CGFloat, completionHandler: (() -> ())? = nil) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        if let side = currentActionSheet?.side {
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
    
    // MARK: UIGestureRecognizerDelegate
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
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
    func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        enableLog ? { print("\(#function)" + "") }() : {}()
        
        let translation = gestureRecognizer.translation(in: self)
        let velocity = gestureRecognizer.velocity(in: self)
        switch gestureRecognizer.state {
        case .began, .changed:
            enableLog ? { print("\(#function)" + " -- gesture recognizer state Began / Changed") }() : {}()
            var actionSide: ActionSide? = nil
            if let contentScreenshot = contentScreenshot {
                let contentPosition = contentScreenshot.frame.origin.x
                actionSide = contentPosition == 0 ? (velocity.x == 0 ? nil : (velocity.x > 0 ? .left : .right)) : (contentPosition > 0 ? .left : .right)
            } else {
                actionSide = velocity.x > 0 ? .left : .right
            }
            if actionSide != currentActionSheet?.side {
                clearActionSheet()
                if let actionSide = actionSide {
                    setupActionSheet(side: actionSide)
                }
            }
            
            if let contentScreenshot = contentScreenshot, let side = currentActionSheet?.side , isCurrentActionSheetValid(side: side) {
                let openPosition = positionForOpen(side: side)
                
                contentScreenshot.frame.origin.x += translation.x
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                if enableDefaultAction == false, abs(contentScreenshot.frame.origin.x) >= openPosition {
                    contentScreenshot.frame.origin.x = openPosition
                }
                animateToPosition(contentScreenshot.frame.origin.x)
            }
        case .ended, .cancelled:
            enableLog ? { print("\(#function)" + " -- gesture recognizer state Ended / Cancelled") }() : {}()
            var closure: (() -> ())? = nil
            if let contentScreenshot = contentScreenshot, let side = currentActionSheet?.side {
                switch positionSection(side: side, position: contentScreenshot.frame.origin.x) {
                case .close_OpenPre:
                    closure = { [weak self] in
                        self?.animateOpenPreToClose()
                    }
                case .openPre_Open:
                    closure = { [weak self] in
                        self?.animateOpenPreToOpen()
                    }
                case .open_TriggerPre:
                    closure = enableDefaultAction ? { [weak self] in
                        self?.animateTriggerPreToOpen()
                        } : nil
                case .triggerPre_Trigger:
                    closure = { [weak self] in
                        self?.animateTriggerPreToTrigger()
                    }
                }
                animateToPosition(contentScreenshot.frame.origin.x, completionHandler: closure)
            }
        default:
            break
        }
    }
    
    func handleTapGestureRecognizer(_ gestureRecognizer: UISwipeGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        if let contentScreenshot = contentScreenshot, let side = currentActionSheet?.side {
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
    
    // MARK: Action
    /// Get current action sheet
    func getCurrentActionSheet(side: ActionSide) -> ActionSheet<CellAction> {
        switch side {
        case .left:
            return actionSheetLeft
        case .right:
            return actionSheetRight
        }
    }
    
    /// Get current side actions
    func getCurrentActionSheetActions(side: ActionSide) -> [CellAction] {
        return getCurrentActionSheet(side: side).actions
    }
    
    /// Get default action
    func getDefaultAction(side: ActionSide) -> CellAction? {
        switch side {
        case .left:
            return getCurrentActionSheetActions(side: side)[defaultActionIndexLeft]
        case .right:
            return getCurrentActionSheetActions(side: side)[defaultActionIndexRight]
        }
    }
    
    /// Does current side have actions to show
    func isCurrentActionSheetValid(side: ActionSide) -> Bool {
        return getCurrentActionSheet(side: side).actions.count > 0
    }
    
    /// Update single action's constraints
    func updateSingleActionConstraints(action: ActionControl, updateClosure: () -> ()) {
        if let constraintLeading = action.constraintLeading, let constraintTrailing = action.constraintTrailing {
            actionContainer.removeConstraints([constraintLeading, constraintTrailing])
            updateClosure()
            actionContainer.addConstraints([constraintLeading, constraintTrailing])
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
            return getCurrentActionSheet(side: side).width
        case .right:
            return -1 * getCurrentActionSheet(side: side).width
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
        let actionSheetWidth = getCurrentActionSheet(side: side).width
        switch side {
        case .left:
            return actionSheetWidth + (bounds.width - actionSheetWidth) * defaultActionTriggerPropotion
        case .right:
            return -1 * (actionSheetWidth + (bounds.width - actionSheetWidth) * defaultActionTriggerPropotion)
        }
    }
    
    /// Get the section of current position
    func positionSection(side: ActionSide, position: CGFloat) -> PositionSection {
        let absPosition = abs(position)
        if absPosition < abs(positionForOpenPrepare(side: side)) {
            return .close_OpenPre
        } else if absPosition < abs(positionForOpen(side: side)) {
            return .openPre_Open
        } else if absPosition < abs(positionForTriggerPrepare(side: side)) {
            return .open_TriggerPre
        } else {
            return .triggerPre_Trigger
        }
    }
    
    /// Get laddering index
    func ladderingIndex(side: ActionSide, position: CGFloat) -> Int {
        let position = abs(position)
        
        var result: [(Int, CellAction)] = []
        result = getCurrentActionSheetActions(side: side).enumerated().filter({ (index, action) -> Bool in
            let widthPre = getCurrentActionSheet(side: side).actionPreWidth(actionIndex: index)
            return abs(position) >= widthPre && abs(position) < widthPre + action.width
        })
        if let currentAction = result.first {
            return currentAction.0
        } else {
            return getCurrentActionSheetActions(side: side).count
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
    
    /// 创建当前单元格的视图（针对选中状态做了特殊处理）
    func takeScreenShot() -> UIImageView {
        let isContentBackgroundClear = (contentView.backgroundColor == nil || contentView.backgroundColor == UIColor.clear)
        if isContentBackgroundClear {
            contentView.backgroundColor = UIColor.white
        }
        let contentScreenshotImage = screenshotImageOfView(view: contentView)
        if isContentBackgroundClear {
            contentView.backgroundColor = nil
        }
        return UIImageView(image: contentScreenshotImage)
    }
    
    // MARK: Interface
    /// Close opened action sheet
    public func closeActionSheet() {
        animateOpenToClose()
    }
}

extension ActionCell: ActionDelegate {
    public func didActionTriggered(action: (() -> ())?) {
        animateOpenPreToClose(action)
    }
}

public class ActionSheet<CellAction: ActionControl where CellAction: CellActionProtocol> {
    var side: ActionSide
    var actions: [CellAction] = []
    
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
    func actionPreWidth(actionIndex index: Int) -> CGFloat {
        return actions.prefix(upTo: index).reduce(0, { (result, action) -> CGFloat in
            result + action.width
        })
    }
}

public enum ActionSide {
    case left
    case right
}

public enum AnimationStyle {
    case none
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
