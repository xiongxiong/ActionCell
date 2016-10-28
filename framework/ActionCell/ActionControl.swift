//
//  ActionControl.swift
//  Pods
//
//  Created by 王继荣 on 9/14/16.
//
//

import UIKit

public protocol ActionDelegate: NSObjectProtocol {
    func didActionTriggered(action: (() -> ())?)
}

public protocol CellActionProtocol {
    func setForeColor(color: UIColor)
    func setForeAlpha(alpha: CGFloat)
}

public class ActionControl: UIControl {
    
    var foreColor: UIColor
    var backColor: UIColor
    var width: CGFloat
    var actionClosure: (() -> ())?
    
    /// Delegate
    weak var delegate: ActionDelegate? = nil
    weak var constraintLeading: NSLayoutConstraint? = nil
    weak var constraintTrailing: NSLayoutConstraint? = nil
    weak var iconConstraintWidth: NSLayoutConstraint? = nil
    weak var iconConstraintHeight: NSLayoutConstraint? = nil
    
    init(foreColor: UIColor, backColor: UIColor, width: CGFloat, actionClosure: (() -> ())?) {
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
    
    override public func removeFromSuperview() {
        super.removeFromSuperview()
        
        alpha = 1
        
        constraintLeading = nil
        constraintTrailing = nil
    }
    
    /// Reset attributes to initial state
    func refresh() {
        backgroundColor = backColor
    }
    
    /// Action is triggered
    func actionTriggered() {
        delegate?.didActionTriggered(action: actionClosure)
    }
}

public class IconAction: ActionControl {
    
    var iconImage: UIImage
    var iconSize: CGSize
    
    var icon: UIImageView = UIImageView()
    
    public init(iconImage: UIImage, iconSize: CGSize = CGSize(width: 20, height: 20), foreColor: UIColor = .white, backColor: UIColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00), width: CGFloat = 60, actionClosure: (() -> ())? = nil) {
        self.iconImage = iconImage
        self.iconSize = iconSize
        super.init(foreColor: foreColor, backColor: backColor, width: width, actionClosure: actionClosure)
        
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
    
    override public func removeFromSuperview() {
        super.removeFromSuperview()
        
        icon.alpha = 1
    }
    
    override func refresh() {
        super.refresh()
        
        icon.image = iconImage.withRenderingMode(.alwaysTemplate)
        icon.tintColor = foreColor
        iconConstraintWidth?.constant = iconSize.width
        iconConstraintHeight?.constant = iconSize.height
        setNeedsLayout()
        layoutIfNeeded()
    }
}

extension IconAction: CellActionProtocol {
    public func setForeColor(color: UIColor) {
        icon.tintColor = color
    }
    
    public func setForeAlpha(alpha: CGFloat) {
        icon.alpha = alpha
    }
}

public class TextAction: ActionControl {
    
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
    
    public init(labelText: String, labelFont: UIFont = UIFont.systemFont(ofSize: 12), foreColor: UIColor = .white, backColor: UIColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00), width: CGFloat = 60, actionClosure: (() -> ())? = nil) {
        self.labelText = labelText
        self.labelFont = labelFont
        super.init(foreColor: foreColor, backColor: backColor, width: width, actionClosure: actionClosure)
        
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
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: label.intrinsicContentSize.width + 20, height: bounds.height)
    }
    
    override public func removeFromSuperview() {
        super.removeFromSuperview()
        
        label.alpha = 1
    }
    
    override func refresh() {
        super.refresh()
        
        label.font = labelFont
        label.text = labelText
        label.textColor = foreColor
    }
}

extension TextAction: CellActionProtocol {
    public func setForeColor(color: UIColor) {
        label.tintColor = color
    }
    
    public func setForeAlpha(alpha: CGFloat) {
        label.alpha = alpha
    }
}
