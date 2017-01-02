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
    
}

public protocol ActionResultDelegate: NSObjectProtocol {
    /// When action finished or cancelled, reset actionsheet accordingly
    func actionFinished(cancelled: Bool)
}

extension UITableViewCell: ActionResultDelegate {
    
}

open class ActionCell: UIView {

    // MARK: Logging
    /// Enable logging debug information
    var isLogEnabled: Bool = true

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

    // MARK: Computed properties
    /// Actions - Left
    var actionsLeft: [ActionControl] {
        get {
            return actionsheetLeft.actions
        }
        set {
            actionsheetLeft.actions = newValue
            actionsheetLeft.actions.forEach {
                $0.delegate = self
            }
        }
    }
    
    /// Actions - Right
    var actionsRight: [ActionControl] {
        get {
            return actionsheetRight.actions
        }
        set {
            actionsheetRight.actions = newValue
            actionsheetRight.actions.forEach {
                $0.delegate = self
            }
        }
    }
    
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
    public func wrap(cell target: UITableViewCell, leftActions: [ActionControl] = [], rightActions: [ActionControl] = []) {
        cell = target
        actionsLeft = leftActions
        actionsRight = rightActions

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

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        panGestureRecognizer.require(toFail: swipeLeftGestureRecognizer)
        panGestureRecognizer.require(toFail: swipeRightGestureRecognizer)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.require(toFail: panGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.isEnabled = false

        setup()
    }
    
    func setup() {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()
        
        [actionsheetLeft, actionsheetRight].forEach { (actionsheet) in
            actionsheet.actions.reversed().forEach {
                addSubview($0)
            }
        }
        setupActionConstraints()
        setupActionAttributes()
    }

    // MARK: Actionsheet
    /// Setup actionsheet
    func setupActionsheet(side: ActionSide) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if isCurrentActionsheetValid(side: side) {
            contentScreenshot = takeScreenshot()
            addSubview(contentScreenshot!)

            currentActionsheet = getCurrentActionsheet(side: side)
            defaultAction = getDefaultAction(side: side)
            backgroundColor = defaultAction?.backgroundColor ?? UIColor.white
            tapGestureRecognizer.isEnabled = true
        }
    }

    /// Clear actionsheet when actionsheet is closed
    public func clearActionsheet(_ completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if isActionSheetOpened {
            backgroundColor = UIColor.clear
            setActionConstraintsForClose()
            
            currentActionsheet?.actions.forEach({ (action) in
                action.setState(.outside)
            })
            currentActionsheet = nil
            
            defaultAction = nil
            contentScreenshot?.removeFromSuperview()
            contentScreenshot = nil
            
            tapGestureRecognizer.isEnabled = false
        }
        completionHandler?()
    }

    /// Open actionsheet
    public func openActionsheet(side: ActionSide) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        setupActionsheet(side: side)
        animateCloseToOpen()
    }

    /// Close opened actionsheet
    public func closeActionsheet() {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if isActionSheetOpened {
            animateOpenToClose()
        }
    }

    // MARK: Action Constraints
    /// Set actions' constraints for beginning
    func setupActionConstraints() {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        [actionsheetLeft, actionsheetRight].forEach { (actionsheet) in
            actionsheet.actions.enumerated().forEach { (index, action) in
                action.translatesAutoresizingMaskIntoConstraints = false
                addConstraint(NSLayoutConstraint(item: action, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                addConstraint(NSLayoutConstraint(item: action, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
                switch actionsheet.side {
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
        }
        setNeedsLayout()
        layoutIfNeeded()
    }

    /// Set actions' constraints for state Close
    func setActionConstraintsForClose() {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

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
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        currentActionsheet?.actions.enumerated().forEach({ (index, action) in
            if let side = currentActionsheet?.side {
                let widthPre = currentActionsheet?.actionPreWidth(actionIndex: index) ?? 0
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
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        currentActionsheet?.actions.enumerated().forEach({ (index, action) in
            if let side = currentActionsheet?.side {
                let widthPre = currentActionsheet?.actionPreWidth(actionIndex: index) ?? 0
                if isDefaultActionTriggered && action == defaultAction {
                    setDefaultActionConstraintsForPosition(position: position)
                } else {
                    switch animationStyle {
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
                            let actionTrailingPosition = targetPosition * (getCurrentActionsheet(side: side).actionPreWidth(actionIndex: index) + action.width) / getCurrentActionsheet(side: side).width
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
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: Action Attributes
    /// Setup actions' attributes
    func setupActionAttributes() {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()
        
        [actionsheetLeft, actionsheetRight].forEach { (actionsheet) in
            actionsheet.actions.forEach {
                $0.setState(.outside)
            }
        }
    }
    
    /// Set actions' attributes for state Close
    func setActionAttributesForClose() {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        currentActionsheet?.actions.forEach {
            $0.setState(.outside)
        }
    }

    /// Set actions' attributes for state Open
    func setActionAttributesForOpen() {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        currentActionsheet?.actions.forEach {
            $0.setState(.inside)
        }
    }

    /// Set actions' attributes for position
    func setActionAttributesForPosition(position: CGFloat) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        currentActionsheet?.actions.enumerated().forEach { (index, action) in
            if let side = currentActionsheet?.side {
                let widthPre = currentActionsheet?.actionPreWidth(actionIndex: index) ?? 0
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
            }
        }
    }

    // MARK: Default Action
    /// Set defaultAction's constraints for position, when defaultAction is triggered
    func setDefaultActionConstraintsForPosition(position: CGFloat) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if let side = currentActionsheet?.side {
            switch side {
            case .left:
                defaultAction?.constraintLeading?.constant = 0
                defaultAction?.constraintTrailing?.constant = position
            case .right:
                defaultAction?.constraintLeading?.constant = position
                defaultAction?.constraintTrailing?.constant = 0
            }
        }
        setNeedsLayout()
        layoutIfNeeded()
    }

    /// Animate when default action is triggered
    func animateDefaultActionTriggered(completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if let side = currentActionsheet?.side {
            setDefaultActionConstraintsForPosition(position: self.positionForTriggerPrepare(side: side))
            currentActionsheet?.actions.forEach {
                if $0 != self.defaultAction {
                    $0.setState(.inactive)
                }
            }
            completionHandler?()
        }
    }

    /// Animate when default action's trigger is cancelled
    func animateDefaultActionCancelled(completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if (currentActionsheet?.side) != nil {
            setActionConstraintsForOpen()
            currentActionsheet?.actions.forEach {
                $0.setState(.inside)
            }
            completionHandler?()
        }
    }

    // MARK: Action Animate
    /// Animate actions & contentScreenshot with orientation Open to Close
    func animateOpenToClose(_ completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if let contentScreenshot = contentScreenshot {
            UIView.animate(withDuration: animationDuration, animations: {
                contentScreenshot.frame.origin.x = self.positionForClose()
                self.setActionConstraintsForClose()
                self.setActionAttributesForClose()
            }, completion: { finished in
                if finished {
                    completionHandler?()
                    self.clearActionsheet()
                }
            })
        }
    }

    /// Animate actions & contentScreenshot with orientation Close to Open
    func animateCloseToOpen(_ completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            UIView.animate(withDuration: animationDuration, animations: {
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

    /// Animate actions & contentScreenshot with orientation Trigger to Open
    func animateTriggerToOpen(_ completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            UIView.animate(withDuration: animationDuration, animations: {
                contentScreenshot.frame.origin.x = self.positionForOpen(side: side)
                self.defaultAction?.setState(.inside)
            }, completion: { finished in
                if finished {
                    completionHandler?()
                }
            })
        }
    }

    /// Animate actions & contentScreenshot with orientation Open to Trigger
    func animateOpenToTrigger(_ completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side {
            UIView.animate(withDuration: animationDuration, animations: {
                contentScreenshot.frame.origin.x = self.positionForTrigger(side: side)
                self.setDefaultActionConstraintsForPosition(position: self.positionForTrigger(side: side))
            }, completion: { finished in
                if finished {
                    completionHandler?()
                    self.defaultAction?.actionTriggered()
                }
            })
        }
    }

    /// Animate actions to position, when the cell is panned
    func animateToPosition(_ position: CGFloat, completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

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

    /// Actionsheet's animation when action is finished
    func animateActionFinished(_ completionHandler: (() -> ())? = nil) {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()
        
        clearActionsheet(completionHandler)
    }

    /// Actionsheet's animation when action is cancelled
    func animateActionCancelled() {
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        closeActionsheet()
    }

    // MARK: Action
    /// Get current actionsheet
    func getCurrentActionsheet(side: ActionSide) -> Actionsheet {
        switch side {
        case .left:
            return actionsheetLeft
        case .right:
            return actionsheetRight
        }
    }

    /// Get current side actions
    func getCurrentActionsheetActions(side: ActionSide) -> [ActionControl] {
        return getCurrentActionsheet(side: side).actions
    }

    /// Get default action
    func getDefaultAction(side: ActionSide) -> ActionControl? {
        switch side {
        case .left:
            return getCurrentActionsheetActions(side: side).first
        case .right:
            return getCurrentActionsheetActions(side: side).first
        }
    }

    /// Does current side have actions to show
    func isCurrentActionsheetValid(side: ActionSide) -> Bool {
        return getCurrentActionsheet(side: side).actions.count > 0
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
            return getCurrentActionsheet(side: side).width
        case .right:
            return -1 * getCurrentActionsheet(side: side).width
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
        let actionsheetWidth = getCurrentActionsheet(side: side).width
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

        var result: [(Int, ActionControl)] = []
        result = getCurrentActionsheetActions(side: side).enumerated().filter({ (index, action) -> Bool in
            let widthPre = getCurrentActionsheet(side: side).actionPreWidth(actionIndex: index)
            return abs(position) >= widthPre && abs(position) < widthPre + action.width
        })
        if let currentAction = result.first {
            return currentAction.0
        } else {
            return getCurrentActionsheetActions(side: side).count
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
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

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
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

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
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

        let translation = gestureRecognizer.translation(in: self)
        let velocity = gestureRecognizer.velocity(in: self)
        switch gestureRecognizer.state {
        case .began, .changed:
            isLogEnabled ? { print("\(#function) -- " + "gesture recognizer state Began / Changed") }() : {}()
            var actionSide: ActionSide? = nil
            if let contentScreenshot = contentScreenshot {
                let contentPosition = contentScreenshot.frame.origin.x
                actionSide = contentPosition == 0 ? (velocity.x == 0 ? nil : (velocity.x > 0 ? .left : .right)) : (contentPosition > 0 ? .left : .right)
            } else {
                actionSide = velocity.x > 0 ? .left : .right
            }
            if actionSide != currentActionsheet?.side {
                clearActionsheet()
                if let actionSide = actionSide {
                    setupActionsheet(side: actionSide)
                }
            }

            if let contentScreenshot = contentScreenshot, let side = currentActionsheet?.side , isCurrentActionsheetValid(side: side) {
                let openPosition = positionForOpen(side: side)

                contentScreenshot.frame.origin.x += translation.x
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)

                if enableDefaultAction == false, abs(contentScreenshot.frame.origin.x) >= openPosition {
                    contentScreenshot.frame.origin.x = openPosition
                }
                animateToPosition(contentScreenshot.frame.origin.x)
            }
        case .ended, .cancelled:
            isLogEnabled ? { print("\(#function) -- " + "gesture recognizer state Ended / Cancelled") }() : {}()
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
        isLogEnabled ? { print("\(#function) -- " + "") }() : {}()

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
}

extension ActionCell: ActionControlDelegate {
    public func didActionTriggered(action: String) {
        isLogEnabled ? { print("\(#function) -- " + "action triggered: \(action)") }() : {}()

        animateActionFinished { [weak self] in
            self?.delegate?.didActionTriggered(cell: (self?.cell)!, action: action)
        }
    }
}

extension ActionCell: ActionResultDelegate {

    public func actionFinished(cancelled: Bool) {
        isLogEnabled ? { print("\(#function) -- " + "action " + (cancelled ? "cancelled" : "finished")) }() : {}()

        cancelled ? { animateActionCancelled() }() : { animateActionFinished() }()
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
