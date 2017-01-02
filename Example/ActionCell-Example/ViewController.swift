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
        // Do any additional setup after loading the view, typically from a nib.
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
        return 3
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
                            TextAction(action: "cell 1 -- left 0", labelText: "Hello", backColor: UIColor(red:0.95, green:0.33, blue:0.58, alpha:1.00)),
                            TextAction(action: "cell 1 -- left 1", labelText: "Long Sentence", backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) ,
                            TextAction(action: "cell 1 -- left 2", labelText: "World", backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) ,
                            ], 
                         actionsRight: [
                            TextAction(action: "cell 1 -- right 0", labelText: "Hello", backColor: UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)) ,
                            TextAction(action: "cell 1 -- right 1", labelText: "Long Sentence", backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) ,
                            TextAction(action: "cell 1 -- right 2", labelText: "World", backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) ,
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
                            TextAction(action: "cell 2 -- left 0", labelText: "Hello", backColor: UIColor(red:0.95, green:0.33, blue:0.58, alpha:1.00)) ,
                            TextAction(action: "cell 2 -- left 1", labelText: "Long Sentence", backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) ,
                            TextAction(action: "cell 2 -- left 2", labelText: "World", backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) ,
                            ],
                         actionsRight: [
                            TextAction(action: "cell 2 -- right 0", labelText: "Hello", backColor: UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)) ,
                            TextAction(action: "cell 2 -- right 1", labelText: "Long Sentence", backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) ,
                            TextAction(action: "cell 2 -- right 2", labelText: "World", backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) ,
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
                            TextAction(action: "cell 3 -- left 0", labelText: "Hello", backColor: UIColor(red:0.95, green:0.33, blue:0.58, alpha:1.00)) ,
                            TextAction(action: "cell 3 -- left 1", labelText: "Long Sentence", backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) ,
                            TextAction(action: "cell 3 -- left 2", labelText: "World", backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) ,
                            ],
                         actionsRight: [
                            TextAction(action: "cell 3 -- right 0", labelText: "Hello", backColor: UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)) ,
                            TextAction(action: "cell 3 -- right 1", labelText: "Long Sentence", backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) ,
                            TextAction(action: "cell 3 -- right 2", labelText: "World", backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) ,
                            ])
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension ViewController: ActionCellDelegate {

    public func didActionTriggered(cell: UITableViewCell, action: String) {
        self.output.text = action + " clicked"
    }
}
