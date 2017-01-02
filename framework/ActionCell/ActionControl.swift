//
//  ActionControl.swift
//  Pods
//
//  Created by 王继荣 on 9/14/16.
//
//

import UIKit

public protocol ActionControlDelegate: NSObjectProtocol {
    func didActionTriggered(action: String)
}

open class ActionControl: UIControl {
    
    var action: String
    var foreColor: UIColor
    var backColor: UIColor
    var width: CGFloat
    
    /// Delegate
    weak var delegate: ActionControlDelegate? = nil
    weak var constraintLeading: NSLayoutConstraint? = nil
    weak var constraintTrailing: NSLayoutConstraint? = nil
    
    public init(action: String, foreColor: UIColor, backColor: UIColor, width: CGFloat) {
        self.action = action
        self.foreColor = foreColor
        self.backColor = backColor
        self.width = width
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
    
    /// Action is triggered
    func actionTriggered() {
        delegate?.didActionTriggered(action: action)
    }
    
    func setState(_ state: State) {
        switch state {
        case .outside:
            alpha = 1
        case .inside:
            alpha = 1
        case .active:
            alpha = 1
        case .inactive:
            alpha = 0
        default:
            break
        }
    }
}

extension ActionControl {
    
    enum State {
        case outside // action stands outside of the cell
        case outside_inside(progress: CGFloat) // action state between outside & inside, progress is between 0 & 1
        case inside // action stands inside of the cell
        case active // action is to be triggered
        case inactive // other action is to be triggered, and this not
    }
}

open class IconAction: ActionControl {
    
    var iconImage: UIImage
    var iconSize: CGSize
    
    var icon: UIImageView = UIImageView()
    
    public init(action: String, iconImage: UIImage, iconSize: CGSize = CGSize(width: 20, height: 20), foreColor: UIColor = .white, backColor: UIColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00), width: CGFloat = 80) {
        self.iconImage = iconImage
        self.iconSize = iconSize
        super.init(action: action, foreColor: foreColor, backColor: backColor, width: width)
        
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0, constant: iconSize.width))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: iconSize.height))
        
        icon.image = iconImage.withRenderingMode(.alwaysTemplate)
        icon.tintColor = foreColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setState(_ state: ActionControl.State) {
        super.setState(state)
        
        switch state {
        case .outside:
            icon.alpha = 0
        case .inside:
            icon.alpha = 1
        case let .outside_inside(progress):
            icon.alpha = progress
        default:
            break
        }
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
    
    public init(action: String, labelText: String, labelFont: UIFont = UIFont.systemFont(ofSize: 12), foreColor: UIColor = .white, backColor: UIColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00), width: CGFloat = 80) {
        self.labelText = labelText
        self.labelFont = labelFont
        super.init(action: action, foreColor: foreColor, backColor: backColor, width: width)
        
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
    
    override func setState(_ state: ActionControl.State) {
        super.setState(state)
        
        switch state {
        case .outside:
            label.alpha = 0
        case .inside:
            label.alpha = 1
        case let .outside_inside(progress):
            label.alpha = progress
        default:
            break
        }
    }
}
