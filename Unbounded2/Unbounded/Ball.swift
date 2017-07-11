//
//  Ball.swift
//  Unbounded
//
//  Created by Paxon Yu on 6/26/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit

//basic ball class
class Ball: SKSpriteNode {
    
    //boolean value that allows the game to know whether the ball has a negative velocity to prevent the slingshot effect of passing through the bottom of a platform and having an angular impulse added
    var readyToBounce: Bool = false
    
    //boolean value to compensate for the "Wes glitch"
    var justContact: Bool = false
    
    //prevent the ball being caught in the paddle
    var glitchTimer: CFTimeInterval = 0
    
    //initializes the ball to whatever size I want it to be aka this is a terrible way to initialize balls with associated physics bodies wtf
    init() {
        let texture = SKTexture(imageNamed: "circle")
        let color = UIColor.white
        let size = texture.size()
                
        super.init(texture: texture, color: color, size: size)
        
        self.xScale = 0.305
        self.yScale = 0.305
        physicsBody = SKPhysicsBody(circleOfRadius: 5)
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 15
        physicsBody?.contactTestBitMask = 10
        physicsBody?.friction = 0.2
        physicsBody?.mass = 0.5
        physicsBody?.restitution = 1
        physicsBody?.allowsRotation = true
        physicsBody?.linearDamping = 0.2
        self.name = "ball"
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
