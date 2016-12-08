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
    
    var tableView: UITableView = UITableView()
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
        
        view.addSubview(output)
        output.translatesAutoresizingMaskIntoConstraints = false
        output.textAlignment = .center
        output.backgroundColor = UIColor.lightGray
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: .alignAllLastBaseline, metrics: nil, views: ["tableView":tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[output]|", options: .alignAllLastBaseline, metrics: nil, views: ["output":output]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]-[output(60)]|", options: .alignAllLeading, metrics: nil, views: ["tableView":tableView, "output":output]))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            let cell = ActionCell<IconAction>()
            cell.textLabel?.text = "Colorful actions"
            cell.defaultActionIndexLeft = 1
            cell.actionsLeft = [
                IconAction(action: "cell 0 -- left 0", iconImage: UIImage(named: "0")!, backColor: UIColor(red:0.95, green:0.33, blue:0.58, alpha:1.00)) {
                    self.output.text = ("cell 0 -- left 0 clicked")
                },
                IconAction(action: "cell 0 -- left 1", iconImage: UIImage(named: "1")!, backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00), width: 140) {
                    self.output.text = ("cell 0 -- left 1 clicked")
                },
                IconAction(action: "cell 0 -- left 2", iconImage: UIImage(named: "2")!, backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) {
                    self.output.text = ("cell 0 -- left 2 clicked")
                },
            ]
            cell.defaultActionIndexRight = 2
            cell.actionsRight = [
                IconAction(action: "cell 0 -- right 0", iconImage: UIImage(named: "0")!, backColor: UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)) {
                    self.output.text = ("cell 0 -- left 0 clicked")
                },
                IconAction(action: "cell 0 -- right 1", iconImage: UIImage(named: "1")!, backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) {
                    self.output.text = ("cell 0 -- left 1 clicked")
                },
                IconAction(action: "cell 0 -- right 2", iconImage: UIImage(named: "2")!, backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00), width: 140) {
                    self.output.text = ("cell 0 -- left 2 clicked")
                },
            ]
            cell.delegate = self
            cell.waitForFinish = false
            return cell
        case 1:
            let cell = ActionCell<TextAction>()
            cell.textLabel?.text = "Both sides have actions"
            cell.animationStyle = .ladder_emergence
            cell.defaultActionIndexLeft = 1
            cell.actionsLeft = [
                TextAction(action: "cell 1 -- left 0", labelText: "Hello", backColor: UIColor(red:0.95, green:0.33, blue:0.58, alpha:1.00)) {
                    self.output.text = ("cell 1 -- left 0 clicked")
                },
                TextAction(action: "cell 1 -- left 1", labelText: "Long Sentence", backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) {
                    self.output.text = ("cell 1 -- left 1 clicked")
                },
                TextAction(action: "cell 1 -- left 2", labelText: "Hello", backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) {
                    self.output.text = ("cell 1 -- left 2 clicked")
                },
            ]
            cell.defaultActionIndexRight = 2
            cell.actionsRight = [
                TextAction(action: "cell 1 -- right 0", labelText: "Hello", backColor: UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)) {
                    self.output.text = ("cell 1 -- left 0 clicked")
                },
                TextAction(action: "cell 1 -- right 1", labelText: "Hello", backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) {
                    self.output.text = ("cell 1 -- left 1 clicked")
                },
                TextAction(action: "cell 1 -- right 2", labelText: "Long Sentence", backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) {
                    self.output.text = ("cell 1 -- left 2 clicked")
                },
            ]
            cell.delegate = self
            return cell
        case 2:
            let cell = ActionCell<IconAction>()
            cell.textLabel?.text = "Actions have the same back color"
            cell.actionsLeft = [
                IconAction(action: "cell 2 -- left 0", iconImage: UIImage(named: "0")!) {
                    self.output.text = ("cell 2 -- left 0 clicked")
                },
                IconAction(action: "cell 2 -- left 1", iconImage: UIImage(named: "1")!) {
                    self.output.text = ("cell 2 -- left 1 clicked")
                },
                IconAction(action: "cell 2 -- left 2", iconImage: UIImage(named: "2")!) {
                    self.output.text = ("cell 2 -- left 2 clicked")
                },
                IconAction(action: "cell 2 -- left 3", iconImage: UIImage(named: "3")!) {
                    self.output.text = ("cell 2 -- left 3 clicked")
                },
            ]
            cell.actionsRight = [
                IconAction(action: "cell 2 -- right 0", iconImage: UIImage(named: "5")!) {
                    self.output.text = ("cell 2 -- right 0 clicked")
                },
                IconAction(action: "cell 2 -- right 1", iconImage: UIImage(named: "6")!) {
                    self.output.text = ("cell 2 -- right 1 clicked")
                },
                IconAction(action: "cell 2 -- right 2", iconImage: UIImage(named: "7")!) {
                    self.output.text = ("cell 2 -- right 2 clicked")
                },
                IconAction(action: "cell 2 -- right 3", iconImage: UIImage(named: "8")!) {
                    self.output.text = ("cell 2 -- right 3 clicked")
                },
            ]
            cell.delegate = self
            return cell
        case 3:
            let cell = ActionCell<IconAction>()
            cell.textLabel?.text = "Actions have the same back color"
            cell.animationStyle = .none
            cell.actionsLeft = [
                IconAction(action: "cell 3 -- left 0", iconImage: UIImage(named: "0")!, backColor: UIColor(red:0.43, green:0.68, blue:0.97, alpha:1.00)) {
                    self.output.text = ("cell 3 -- left 0 clicked")
                },
                IconAction(action: "cell 3 -- left 1", iconImage: UIImage(named: "1")!, backColor: UIColor(red:0.43, green:0.68, blue:0.97, alpha:1.00)) {
                    self.output.text = ("cell 3 -- left 1 clicked")
                },
                IconAction(action: "cell 3 -- left 2", iconImage: UIImage(named: "2")!, backColor: UIColor(red:0.43, green:0.68, blue:0.97, alpha:1.00)) {
                    self.output.text = ("cell 3 -- left 2 clicked")
                },
                IconAction(action: "cell 3 -- left 3", iconImage: UIImage(named: "3")!, backColor: UIColor(red:0.43, green:0.68, blue:0.97, alpha:1.00)) {
                    self.output.text = ("cell 3 -- left 3 clicked")
                },
            ]
            cell.actionsRight = [
                IconAction(action: "cell 3 -- right 0", iconImage: UIImage(named: "5")!, backColor: UIColor(red:0.43, green:0.68, blue:0.97, alpha:1.00)) {
                    self.output.text = ("cell 3 -- right 0 clicked")
                },
                IconAction(action: "cell 3 -- right 1", iconImage: UIImage(named: "6")!, backColor: UIColor(red:0.43, green:0.68, blue:0.97, alpha:1.00)) {
                    self.output.text = ("cell 3 -- right 1 clicked")
                },
                IconAction(action: "cell 3 -- right 2", iconImage: UIImage(named: "7")!, backColor: UIColor(red:0.43, green:0.68, blue:0.97, alpha:1.00)) {
                    self.output.text = ("cell 3 -- right 2 clicked")
                },
                IconAction(action: "cell 3 -- right 3", iconImage: UIImage(named: "8")!, backColor: UIColor(red:0.43, green:0.68, blue:0.97, alpha:1.00)) {
                    self.output.text = ("cell 3 -- right 3 clicked")
                },
            ]
            cell.delegate = self
            return cell
        case 4:
            let cell = ActionCell<IconAction>()
            cell.textLabel?.text = "This actionsheet has only one side"
            cell.animationStyle = .ladder
            cell.actionsRight = [
                IconAction(action: "cell 4 -- left 0", iconImage: UIImage(named: "0")!, backColor: UIColor(red:0.95, green:0.33, blue:0.58, alpha:1.00)) {
                    self.output.text = ("cell 4 -- left 0 clicked")
                },
                IconAction(action: "cell 4 -- left 1", iconImage: UIImage(named: "1")!, backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) {
                    self.output.text = ("cell 4 -- left 1 clicked")
                },
                IconAction(action: "cell 4 -- left 2", iconImage: UIImage(named: "2")!, backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) {
                    self.output.text = ("cell 4 -- left 2 clicked")
                },
            ]
            cell.delegate = self
            return cell
        case 5:
            let cell = ActionCell<IconAction>()
            cell.textLabel?.text = "This actionsheet has only one side"
            cell.actionsLeft = [
                IconAction(action: "cell 5 -- left 0", iconImage: UIImage(named: "0")!, backColor: UIColor(red:0.95, green:0.33, blue:0.58, alpha:1.00)) {
                    self.output.text = ("cell 5 -- left 0 clicked")
                },
                IconAction(action: "cell 5 -- left 1", iconImage: UIImage(named: "1")!, backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00)) {
                    self.output.text = ("cell 5 -- left 1 clicked")
                },
                IconAction(action: "cell 5 -- left 2", iconImage: UIImage(named: "2")!, backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) {
                    self.output.text = ("cell 5 -- left 2 clicked")
                },
            ]
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension ViewController: ActionCellActionDelegate {
    
    public func didActionTriggered(cell: UITableViewCell, action: String) {
        let alert = UIAlertController(title: "Select", message: "Select any", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
            print("select - ok")
            (cell as? ActionResultDelegate)?.actionFinished(cancelled: false)
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .default, handler: { (action) in
            print("select - cancel")
            (cell as? ActionResultDelegate)?.actionFinished(cancelled: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}

