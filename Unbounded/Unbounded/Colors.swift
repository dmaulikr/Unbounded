//
//  Colors.swift
//  Unbounded
//
//  Created by Paxon Yu on 7/17/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit

let imgurGreen = UIColor.init(netHex: 0x85BF25)
let starburstOrange = UIColor.init(netHex: 0xEA604E)
let royalPurple = UIColor.init(netHex: 0x663399)
let cerulean = UIColor.init(netHex: 0x2a52be)
let gold = UIColor.init(netHex: 0xFFD700)
let pink = UIColor.init(netHex: 0xff69b4)
let brick = UIColor.init(netHex: 0xad5050)
let steel = UIColor.init(netHex: 0x4682b4)
let beige = UIColor.init(netHex: 0xf5f5dc)
let spring = UIColor.init(netHex: 0x00ff7f)
let mediumPurple = UIColor.init(netHex: 0x9370db)


extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
  
}

