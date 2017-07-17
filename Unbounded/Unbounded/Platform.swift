//
//  Platform.swift
//  Unbounded
//
//  Created by Paxon Yu on 6/26/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit

//platform class filled with a bunch of confusing shit
class Platform : SKShapeNode {
    
    //timer to determine despawn
    var timer: CFTimeInterval = 0
    var start: CGPoint?
    var end: CGPoint?
    var forceScalar: CGFloat?
    var collision: UInt32?
    var exist: Bool = true
    var defaultLimit: Double = 3
    var length: CGFloat?
    
    //ok so this is where it gets weird, you add the child platform node to the scene node but there's another node here that needs to be added to the platform object and the properties get really weird
    init(_ startPoint: CGPoint, _ endPoint: CGPoint, _ color: UIColor) {
        super.init()
        //creates the line
        var line: [CGPoint] = [startPoint, endPoint]
        
        //initializes the line as a shape node
        let actualLine = SKShapeNode(points: &line, count: 2)
        
        //creates the physics body which overlaps the line
        actualLine.physicsBody = SKPhysicsBody(edgeFrom: startPoint, to: endPoint)
        
        //assigns the start and end values
        start = startPoint
        end = endPoint
        
        //assigns the line width, stroke color, and line cap
        actualLine.lineWidth = 4
        actualLine.strokeColor = color
        actualLine.lineCap = .round
        actualLine.zPosition = -1
        //THIS LINE OF CODE IS SUPER DUPER IMPORTANT
        addChild(actualLine)
        
        
        //since I don't know which body is the real body, the physics body or the class body I just modified both of them and set the masks accordingly
        actualLine.physicsBody?.categoryBitMask = 8
        self.physicsBody?.categoryBitMask = 8
        actualLine.physicsBody?.contactTestBitMask = 4294967295
        actualLine.physicsBody?.collisionBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        collision = actualLine.physicsBody?.collisionBitMask
        actualLine.name = "platform"
        
       //calculates the distance of the line and then sets the forceScalar relative to the length of the line (the larger the number, the more extreme the scalar becomes)
        length = calcDistance()
        forceScalar = CGFloat(340 / length!)
        
        //if the line is too long then set the timer to something lower to discourage spam
       // if length! > CGFloat(260) {
        //    defaultLimit = 0.7
      //  }
    }
    
    //updates the time interval and removes the platform if it exceeds the limit
    func update() {
        
        if timer > CFTimeInterval(defaultLimit - 0.5) {
            self.run(SKAction.fadeOut(withDuration: 0.5))
        }
        
        if timer >  CFTimeInterval(defaultLimit) {
            removeFromParent()
            exist = false
        }
        timer += fixedDelta
        
    }
    
    func calcDistance() -> CGFloat {
        let xDist = start!.x - end!.x
        let yDist = start!.y - end!.y
        let dist = sqrt((xDist*xDist) + (yDist*yDist))
        return dist
    
    }
    
   
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
