![ChatMenu](http://7xsfp9.com1.z0.glb.clouddn.com/image.png)
# ChatMenu
[![](https://img.shields.io/badge/language-Swift3.0-orange.svg)](https://github.com/TangentW/ChatMenu)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/ChatMenu.svg)](https://github.com/TangentW/ChatMenu)

![ChatMenu](http://7xsfp9.com1.z0.glb.clouddn.com/ChatMenu_gif.gif)
---

## Requirements
* iOS 9.0 or higher
* Swift 3.0

## Demo
Run the `Sample` project in Xcode to see `ChatMenu` in action.

## Installation
### Carthage
```
github "TangentW/ChatMenu"
```
###  Cocoapods
```
pod "ChatMenu"
```
## Usage
`ChatMenu` is very simple to use, All you need just call a function:
```Swift
/// Show a menu on a particular chat bubble view, with an action sheet
/// attached to it.
///
/// - Parameters:
///   - bubbleView: Chat bubble view.
///   - direction: The direction in which the bubble view is located.
///   - actions: Actions of the action sheet in menu.
///   - items: Items to show on the bubble view, such as emoji.
///   - dismissCallback: Called when menu will dismiss.
///   - completedDismissCallback: Called when menu did dismiss.
static func show(on bubbleView: UIView,
                     direction: Direction,
                     actions: [Action],
                     items: [BubbleItem],
                     dismissCallback: (() -> ())? = nil,
                     completedDismissCallback: (() -> ())? = nil)
```

### Example usage
```Swift
// Items
let emojis = "😀👍👎❤️🎉".characters.map { String($0) }
let items = emojis.map { emoji in
	ChatMenu.BubbleItem(title: emoji, image: nil, action: { 
		print("did Selected" + emoji)
	})
}

// Actions
let cameraAction = ChatMenu.Action(title: "Camera", tintColor: .green) {
	print("Open Camera")
}
let albumAction = ChatMenu.Action(title: "Album", tintColor: .orange) {
	print("Open Album")
}
let cancelAction = ChatMenu.Action(style: .cancel, title: "Cancel", tintColor: .red) { 
	print("Cancel")
}
let actions = [cameraAction, albumAction, cancelAction]

// Show
ChatMenu.show(on: bubbleView,
              direction: .left,
              actions: actions,
              items: items,
              dismissCallback: { print("ChatMenu will dismiss") },
              completedDismissCallback: { print("ChatMenu did dismiss") })
```

## License
The MIT License (MIT)

