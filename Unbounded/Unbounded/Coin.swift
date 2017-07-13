//
//  Coin.swift
//  Unbounded
//
//  Created by Paxon Yu on 7/12/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit

class Coin: SKSpriteNode {
    
    var timer: CFTimeInterval = 0
   
    
    init(){
        let texture = SKTexture(imageNamed: "coinTexture")
        let color = UIColor.gray
        let size = CGSize(width: 40, height: 40)
        super.init(texture: texture, color: color, size: size)
        run(SKAction(named: "coin")!)
        physicsBody = SKPhysicsBody(circleOfRadius: 20)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = 32
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        self.name = "coin"
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
