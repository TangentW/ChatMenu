//
//  BundleTool.swift
//  ChatMenu
//
//  Created by Tan on 2017/8/12.
//

import UIKit

extension Bundle {
    static var myBundle: Bundle {
        return Bundle(for: ChatMenu.Controller.self)
    }
}

extension UIImage {
    static func chatMenuImage(name: String) -> UIImage? {
        return UIImage(named: "Images.bundle/" + name, in: Bundle.myBundle, compatibleWith: nil)
    }
}
