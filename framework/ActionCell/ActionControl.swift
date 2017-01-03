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
    var width: CGFloat
    
    /// Delegate
    weak var delegate: ActionControlDelegate? = nil
    weak var constraintLeading: NSLayoutConstraint? = nil
    weak var constraintTrailing: NSLayoutConstraint? = nil
    
    public init(action: String, width: CGFloat) {
        self.action = action
        self.width = width
        super.init(frame: CGRect.zero)
        
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
        #if DEVELOPMENT
            print("\(#function) -- " + "action: \(action)")
        #endif
        
        delegate?.didActionTriggered(action: action)
    }
    
    func setState(_ state: State) {
        #if DEVELOPMENT
            print("\(#function) -- " + "state: \(state)")
        #endif
        
        switch state {
        case .inactive:
            isHidden = true
        default:
            isHidden = false
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
    
    public var icon: UIImageView = UIImageView()
    var iconSize: CGSize
    
    public init(action: String, width: CGFloat = 80, iconSize: CGSize = CGSize(width: 20, height: 20)) {
        self.iconSize = iconSize
        super.init(action: action, width: width)
        
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0, constant: iconSize.width))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: iconSize.height))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setState(_ state: ActionControl.State) {
        super.setState(state)
        
        switch state {
        case let .outside_inside(progress):
            icon.alpha = progress
        default:
            icon.alpha = 1
        }
    }
}

open class TextAction: ActionControl {
    
    public var label: UILabel = UILabel()
    
    override var width: CGFloat {
        get {
            return max(super.width, intrinsicContentSize.width)
        }
        set {
            super.width = width
        }
    }
    
    public override init(action: String, width: CGFloat = 80) {
        super.init(action: action, width: width)
        
        addSubview(label)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
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
        case let .outside_inside(progress):
            label.alpha = progress
        default:
            label.alpha = 1
        }
    }
}

open class IconTextAction: ActionControl {
    
    public var icon: UIImageView = UIImageView()
    public var label: UILabel = UILabel()
    
    var iconSize: CGSize
    var space: CGFloat
    var offset: CGFloat
    
    override var width: CGFloat {
        get {
            return max(super.width, intrinsicContentSize.width)
        }
        set {
            super.width = width
        }
    }
    
    public init(action: String, width: CGFloat = 80, iconSize: CGSize = CGSize(width: 20, height: 20), space: CGFloat = 5, offset: CGFloat = -3) {
        self.iconSize = iconSize
        self.space = space
        self.offset = offset
        super.init(action: action, width: width)
        
        addSubview(icon)
        addSubview(label)
        
        label.textAlignment = .center
        label.text = " "
        label.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: icon, attribute: .bottom, multiplier: 1, constant: space))
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -1 * (label.intrinsicContentSize.height + space) / 2 - offset))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0, constant: iconSize.width))
        addConstraint(NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: iconSize.height))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: max(iconSize.width, label.intrinsicContentSize.width) + 20, height: bounds.height)
    }
    
    override func setState(_ state: ActionControl.State) {
        super.setState(state)
        
        switch state {
        case let .outside_inside(progress):
            icon.alpha = progress
            label.alpha = progress
        default:
            icon.alpha = 1
            label.alpha = 1
        }
    }
}
