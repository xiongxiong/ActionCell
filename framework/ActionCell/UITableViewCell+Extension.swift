//
//  UITableViewCell+Extension.swift
//  ActionCell
//
//  Created by 王继荣 on 03/01/2017.
//  Copyright © 2017 snowflyer. All rights reserved.
//

import UIKit

public protocol ActionsheetDelegate: NSObjectProtocol {
    /// Is action sheet opened
    var isActionsheetOpened: Bool { get }
    /// Setup action sheet
    func setupActionsheet(side: ActionSide, actions: [ActionControl])
    /// Open action sheet
    func openActionsheet(side: ActionSide, completionHandler: (() -> ())?)
    /// Close action sheet
    func closeActionsheet(_ completionHandler: (() -> ())?)
}

extension UITableViewCell: ActionsheetDelegate {
    
    /// UITableViewCell's ActionCell wrapper
    var actionCell: ActionCell? {
        var actionCell: ActionCell? = nil
        subviews.forEach({ (view) in
            if let wrapper = view as? ActionCell {
                actionCell = wrapper
            }
        })
        return actionCell
    }
    
    // MARK: ActionsheetDelegate
    public var isActionsheetOpened: Bool {
        return actionCell?.isActionsheetOpened ?? false
    }
    
    public func setupActionsheet(side: ActionSide, actions: [ActionControl] = []) {
        actionCell?.setupActionsheet(side: side, actions: actions)
    }
    
    public func openActionsheet(side: ActionSide, completionHandler: (() -> ())? = nil) {
        actionCell?.openActionsheet(side: side, completionHandler: completionHandler)
    }
    
    public func closeActionsheet(_ completionHandler: (() -> ())? = nil) {
        actionCell?.closeActionsheet(completionHandler)
    }
}

extension UITableViewCell {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if DEVELOPMENT
            print("\(#function) -- " + "")
        #endif
        
        super.touchesBegan(touches, with: event)
        next?.touchesBegan(touches, with: event)
        
        if !isActionsheetOpened {
            actionCell?.delegate?.closeActionsheet()
        }
    }
}
