# ActionCell

[![CI Status](http://img.shields.io/travis/wonderbear/ActionCell.svg?style=flat)](https://travis-ci.org/wonderbear/ActionCell) [![Version](https://img.shields.io/cocoapods/v/ActionCell.svg?style=flat)](http://cocoapods.org/pods/ActionCell) [![Platform](https://img.shields.io/cocoapods/p/ActionCell.svg?style=flat)](http://cocoapods.org/pods/ActionCell)
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![License](https://img.shields.io/cocoapods/l/ActionCell.svg?style=flat)](http://cocoapods.org/pods/ActionCell)

Easy to use UITableViewCell implementing swiping to trigger actions (known from the Mailbox App)

![ActionCell](ScreenShot/ActionCell.gif "ActionCell")

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Example](#example)
- [Installation](#installation)
- [Protocols](#protocols)
- [Usage](#usage)
- [Properties](#properties)
- [Author](#author)
- [License](#license)

## Features

- [x] Flexible action support
- [x] Support default action
- [x] Customized action width
- [x] Customized action control

## Requirements

- iOS 8.0+ / Mac OS X 10.11+ / tvOS 9.0+
- Xcode 8.0+
- Swift 3.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ActionCell into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'ActionCell', '~> 1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate ActionCell into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "xiongxiong/ActionCell" ~> 1.0.0
```

Run `carthage update` to build the framework and drag the built `ActionCell.framework` into your Xcode project.

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate ActionCell into your project manually.

## Example

Open the example project, build and run.

## Protocols

### CellActionProtocol

```swift
public protocol CellActionProtocol {
    func setForeColor(color: UIColor)
    func setForeAlpha(alpha: CGFloat)
}
```

## Usage

### Inherit ActionControl & implement CellActionProtocol

```swift
public class ActionControl: UIControl {}
```

```swift
public class TextAction: ActionControl, CellActionProtocol {
    var label: UILabel = UILabel()
    ...

    public func setForeColor(color: UIColor) {
        label.tintColor = color
    }

    public func setForeAlpha(alpha: CGFloat) {
        label.alpha = alpha
    }
  }
```

IconAction & TextAction are already implemented, you can use it straightforwardly without implementing CellActionProtocol, or you can choose to implement CellActionProtocol to use your own ActionControl.

### Initialize ActionCell

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            let cell = ActionCell<IconAction>() // create ActionCell
            cell.textLabel?.text = "Colorful actions"
            cell.defaultActionIndexLeft = 1 // set default action index to be triggered, default is the first one.
            cell.actionsLeft = [
                IconAction(iconImage: UIImage(named: "0")!, backColor: UIColor(red:0.95, green:0.33, blue:0.58, alpha:1.00)) {
                    self.output.text = ("cell 0 -- left 0 clicked")
                },
                IconAction(iconImage: UIImage(named: "1")!, backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00), width: 140) {
                    self.output.text = ("cell 0 -- left 1 clicked")
                },
                IconAction(iconImage: UIImage(named: "2")!, backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) {
                    self.output.text = ("cell 0 -- left 2 clicked")
                },
            ] // set actions of the action cell
            cell.defaultActionIndexRight = 2 // set default action index to be triggered, default is the first one.
            cell.actionsRight = [
                IconAction(iconImage: UIImage(named: "0")!, backColor: UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)) {
                    self.output.text = ("cell 0 -- left 0 clicked")
                },
                IconAction(iconImage: UIImage(named: "1")!, backColor: UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)) {
                    self.output.text = ("cell 0 -- left 1 clicked")
                },
                IconAction(iconImage: UIImage(named: "2")!, backColor: UIColor(red:1.00, green:0.78, blue:0.80, alpha:1.00), width: 140) {
                    self.output.text = ("cell 0 -- left 2 clicked")
                },
            ] // set actions of the action cell
            return cell
        default:
          break
        }
```

## Properties

### Actions

- actionsLeft: [CellAction] // Actions - Left
- actionsRight: [CellAction] // Actions - Right

### Style
- animationStyle: AnimationStyle = none | ladder | ladder_emergence | concurrent // Action animation style
- defaultActionTriggerPropotion: CGFloat // The propotion of (state public to state trigger-prepare / state public to state trigger), about where the default action is triggered
- defaultActionIconColor: UIColor? // Default action's icon color
- defaultActionBackImage: UIImage? // Default action's back image
- defaultActionBackColor: UIColor? // Default action's back color

### Behavior

- enableDefaultAction: Bool // Enable default action to be triggered when the content is panned to far enough
- defaultActionIndexLeft: Int // Index of default action - Left
- defaultActionIndexRight: Int // Index of default action - Right

### Animation

- animationDuration: NSTimeInterval // Spring animation - duration of the animation
- animationDelay: TimeInterval // Spring animation - delay of the animation
- springDamping: CGFloat // Spring animation - spring damping of the animation
- initialSpringVelocity: CGFloat // Spring animation - initial spring velocity of the animation
- animationOptions: UIViewAnimationOptions // Spring animation - options of the animation

## Author

xiongxiong, ximengwuheng@163.com

## License

ActionCell is available under the MIT license. See the LICENSE file for more info.
