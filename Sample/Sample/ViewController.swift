//
//  ViewController.swift
//  Sample
//
//  Created by Tan on 2017/8/12.
//
//

import UIKit
import ChatMenu

class ViewController: UIViewController {
    @IBOutlet weak var leftBubble: UIView!
    @IBOutlet weak var rightBubble: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        leftBubble.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleRecognizer(recognizer:))))
        rightBubble.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleRecognizer(recognizer:))))
    }

    @objc func handleRecognizer(recognizer: UILongPressGestureRecognizer) {
        guard
            recognizer.state == .began,
            let view = recognizer.view
        else { return }
        let isLeft = view === leftBubble
        showChatMenu(on: view, isLeft: isLeft)
    }
}

extension ViewController {
    func showChatMenu(on bubbleView: UIView, isLeft: Bool) {
        let emojis = "😀👍👎❤️🎉".characters.map { String($0) }
        let items = emojis.map { emoji in
            ChatMenu.BubbleItem(title: emoji, image: nil, action: { 
                print("did Selected" + emoji)
            })
        }
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
        ChatMenu.show(on: bubbleView,
                      direction: isLeft ? .left : .right,
                      actions: actions,
                      items: items,
                      dismissCallback: { print("ChatMenu will dismiss") },
                      completedDismissCallback: { print("ChatMenu did dismiss") })
    }
}
