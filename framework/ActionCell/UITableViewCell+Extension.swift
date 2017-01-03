//
//  UITableViewCell+Extension.swift
//  ActionCell
//
//  Created by 王继荣 on 03/01/2017.
//  Copyright © 2017 snowflyer. All rights reserved.
//

import UIKit

public protocol ActionSheetDelegate: NSObjectProtocol {
    /// Is action sheet opened
    var isActionSheetOpened: Bool { get }
    /// Setup action sheet
    func setupActionsheet(side: ActionSide, actions: [ActionControl])
    /// Open action sheet
    func openActionsheet(side: ActionSide, completionHandler: (() -> ())?)
    /// Close action sheet
    func closeActionsheet(_ completionHandler: (() -> ())?)
}

extension UITableViewCell: ActionSheetDelegate {
    
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
    
    // MARK: ActionSheetDelegate
    public var isActionSheetOpened: Bool {
        return actionCell?.isActionSheetOpened ?? false
    }
    
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
