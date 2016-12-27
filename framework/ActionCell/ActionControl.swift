//
//  ActionControl.swift
//  Pods
//
//  Created by 王继荣 on 9/14/16.
//
//

import UIKit

public protocol ActionControlActionDelegate: NSObjectProtocol {
    func didActionTriggered(action: String, actionClosure: (() -> ())?)
}

open class ActionControl: UIControl {
    
    var action: String
    var foreColor: UIColor
    var backColor: UIColor
    var width: CGFloat
    var actionClosure: (() -> ())?
    
    /// Delegate
    weak var delegate: ActionControlActionDelegate? = nil
    weak var constraintLeading: NSLayoutConstraint? = nil
    weak var constraintTrailing: NSLayoutConstraint? = nil
    weak var iconConstraintWidth: NSLayoutConstraint? = nil
    weak var iconConstraintHeight: NSLayoutConstraint? = nil
    
    public init(action: String, foreColor: UIColor, backColor: UIColor, width: CGFloat, actionClosure: (() -> ())?) {
        self.action = action
        self.foreColor = foreColor
        self.backColor = backColor
        self.width = width
        self.actionClosure = actionClosure
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = backColor
        addTarget(self, action: #selector(actionTriggered), for: .touchUpInside)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeTarget(self, action: #selector(actionTriggered), for: .touchUpInside)
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        
        alpha = 1
        
        constraintLeading = nil
        constraintTrailing = nil
    }
    
    /// Reset attributes to initial state
    open func refresh() {
        backgroundColor = backColor
    }
    
    /// Action is triggered
    func actionTriggered() {
        delegate?.didActionTriggered(action: action, actionClosure: actionClosure)
    }
    
    public func setForeColor(color: UIColor) {
        
    }
    
    public func setForeAlpha(alpha: CGFloat) {
       
    }
}

open class IconAction: ActionControl {
    
    var iconImage: UIImage
    var iconSize: CGSize
    
    var icon: UIImageView = UIImageView()
    
    public init(action: String, iconImage: UIImage, iconSize: CGSize = CGSize(width: 20, height: 20), foreColor: UIColor = .white, backColor: UIColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00), width: CGFloat = 80, actionClosure: (() -> ())? = nil) {
        self.iconImage = iconImage
        self.iconSize = iconSize
        super.init(action: action, foreColor: foreColor, backColor: backColor, width: width, actionClosure: actionClosure)
        
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        let constraintWidth = NSLayoutConstraint(item: icon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0, constant: iconSize.width)
        iconConstraintWidth = constraintWidth
        addConstraint(constraintWidth)
        let constraintHeight = NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: iconSize.height)
        iconConstraintHeight = constraintHeight
        addConstraint(constraintHeight)
        
        icon.image = iconImage.withRenderingMode(.alwaysTemplate)
        icon.tintColor = foreColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        
        icon.alpha = 1
    }
    
    open override func refresh() {
        super.refresh()
        
        icon.image = iconImage.withRenderingMode(.alwaysTemplate)
        icon.tintColor = foreColor
        iconConstraintWidth?.constant = iconSize.width
        iconConstraintHeight?.constant = iconSize.height
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public override func setForeColor(color: UIColor) {
        icon.tintColor = color
    }
    
    public override func setForeAlpha(alpha: CGFloat) {
        icon.alpha = alpha
    }
}

open class TextAction: ActionControl {
    
    var labelText: String
    var labelFont: UIFont
    
    override var width: CGFloat {
        get {
            return max(super.width, intrinsicContentSize.width)
        }
        set {
            super.width = width
        }
    }
    
    var label: UILabel = UILabel()
    
    public init(action: String, labelText: String, labelFont: UIFont = UIFont.systemFont(ofSize: 12), foreColor: UIColor = .white, backColor: UIColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00), width: CGFloat = 80, actionClosure: (() -> ())? = nil) {
        self.labelText = labelText
        self.labelFont = labelFont
        super.init(action: action, foreColor: foreColor, backColor: backColor, width: width, actionClosure: actionClosure)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        
        label.textAlignment = .center
        label.font = labelFont
        label.text = labelText
        label.textColor = foreColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: label.intrinsicContentSize.width + 20, height: bounds.height)
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        
        label.alpha = 1
    }
    
    open override func refresh() {
        super.refresh()
        
        label.font = labelFont
        label.text = labelText
        label.textColor = foreColor
    }
    
    public override func setForeColor(color: UIColor) {
        label.tintColor = color
    }
    
    public override func setForeAlpha(alpha: CGFloat) {
        label.alpha = alpha
    }
}
