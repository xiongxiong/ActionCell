//
//  ViewController.swift
//  ActionCell
//
//  Created by xiongxiong on 09/01/2016.
//  Copyright (c) 2016 xiongxiong. All rights reserved.
//

import UIKit
import ActionCell

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView! = UITableView()
    var output: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsOnTap = true
        
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())

        view.addSubview(output)
        output.translatesAutoresizingMaskIntoConstraints = false
        output.textAlignment = .center
        output.backgroundColor = UIColor.lightGray

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: .alignAllLastBaseline, metrics: nil, views: ["tableView":tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[output]|", options: .alignAllLastBaseline, metrics: nil, views: ["output":output]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]-[output(60)]|", options: .alignAllLeading, metrics: nil, views: ["tableView":tableView, "output":output]))
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description())!
            cell.textLabel?.text = "style: ladder"
            let wrapper = ActionCell()
            wrapper.delegate = self
            wrapper.animationStyle = .ladder
            wrapper.wrap(cell: cell, 
                         actionsLeft: [
                            {
                                let action = IconTextAction(action: "cell 0 -- left 0")
                                action.icon.image = #imageLiteral(resourceName: "image_5").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.label.text = "Hello"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = TextAction(action: "cell 0 -- left 1")
                                action.label.text = "Long Sentence"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = IconAction(action: "cell 0 -- left 2")
                                action.icon.image = #imageLiteral(resourceName: "image_0").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
                                return action
                            }(),
                            ],
                         actionsRight: [
                            {
                                let action = IconTextAction(action: "cell 0 -- right 0")
                                action.icon.image = #imageLiteral(resourceName: "image_1").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.label.text = "Hello"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = TextAction(action: "cell 0 -- right 1")
                                action.label.text = "Long Sentence"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = IconAction(action: "cell 0 -- right 2")
                                action.icon.image = #imageLiteral(resourceName: "image_2").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)
                                return action
                            }(),
                            ])
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description())!
            cell.textLabel?.text = "style: ladder_emergence"
            let wrapper = ActionCell()
            wrapper.delegate = self
            wrapper.animationStyle = .ladder_emergence
            wrapper.wrap(cell: cell,
                         actionsLeft: [
                            {
                                let action = IconTextAction(action: "cell 1 -- left 0")
                                action.icon.image = #imageLiteral(resourceName: "image_5").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.label.text = "Hello"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = TextAction(action: "cell 1 -- left 1")
                                action.label.text = "Long Sentence"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = IconAction(action: "cell 1 -- left 2")
                                action.icon.image = #imageLiteral(resourceName: "image_0").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
                                return action
                            }(),
                            ],
                         actionsRight: [
                            {
                                let action = IconTextAction(action: "cell 1 -- right 0")
                                action.icon.image = #imageLiteral(resourceName: "image_1").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.label.text = "Hello"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = TextAction(action: "cell 1 -- right 1")
                                action.label.text = "Long Sentence"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = IconAction(action: "cell 1 -- right 2")
                                action.icon.image = #imageLiteral(resourceName: "image_2").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)
                                return action
                            }(),
                            ])
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description())!
            cell.textLabel?.text = "style: concurrent"
            let wrapper = ActionCell()
            wrapper.delegate = self
            wrapper.animationStyle = .concurrent
            wrapper.wrap(cell: cell,
                         actionsLeft: [
                            {
                                let action = IconTextAction(action: "cell 2 -- left 0")
                                action.icon.image = #imageLiteral(resourceName: "image_5").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.label.text = "Hello"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = TextAction(action: "cell 2 -- left 1")
                                action.label.text = "Long Sentence"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = IconAction(action: "cell 2 -- left 2")
                                action.icon.image = #imageLiteral(resourceName: "image_0").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
                                return action
                            }(),
                            ],
                         actionsRight: [
                            {
                                let action = IconTextAction(action: "cell 2 -- right 0")
                                action.icon.image = #imageLiteral(resourceName: "image_1").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.label.text = "Hello"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = TextAction(action: "cell 2 -- right 1")
                                action.label.text = "Long Sentence"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = IconAction(action: "cell 2 -- right 2")
                                action.icon.image = #imageLiteral(resourceName: "image_2").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)
                                return action
                            }(),
                            ])
            return cell
        case 3:
            let cell = CustomTableViewCell()
            cell.button.addTarget(self, action: #selector(cellButtonClicked), for: .touchUpInside)
            let wrapper = ActionCell()
            wrapper.delegate = self
            wrapper.animationStyle = .concurrent
            wrapper.wrap(cell: cell,
                         actionsLeft: [
                            {
                                let action = IconTextAction(action: "cell 3 -- left 0")
                                action.icon.image = #imageLiteral(resourceName: "image_5").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.label.text = "Hello"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = TextAction(action: "cell 3 -- left 1")
                                action.label.text = "Long Sentence"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = IconAction(action: "cell 3 -- left 2")
                                action.icon.image = #imageLiteral(resourceName: "image_0").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
                                return action
                            }(),
                            ],
                         actionsRight: [
                            {
                                let action = IconTextAction(action: "cell 3 -- right 0")
                                action.icon.image = #imageLiteral(resourceName: "image_1").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.label.text = "Hello"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = TextAction(action: "cell 3 -- right 1")
                                action.label.text = "Long Sentence"
                                action.label.font = UIFont.systemFont(ofSize: 12)
                                action.label.textColor = UIColor.white
                                action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
                                return action
                            }(),
                            {
                                let action = IconAction(action: "cell 3 -- right 2")
                                action.icon.image = #imageLiteral(resourceName: "image_2").withRenderingMode(.alwaysTemplate)
                                action.icon.tintColor = UIColor.white
                                action.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)
                                return action
                            }(),
                            ])
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func cellButtonClicked() {
        self.output.text = "cell button clicked"
    }
}

extension ViewController: ActionCellDelegate {

    public func didActionTriggered(cell: UITableViewCell, action: String) {
        self.output.text = action + " clicked"
    }
}

class CustomTableViewCell: UITableViewCell {
    
    var button: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        button = {
            let the = UIButton()
            the.setTitle("click me", for: .normal)
            the.setTitleColor(UIColor.white, for: .normal)
            the.backgroundColor = UIColor.brown
            return the
        }()
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 300))
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
