//
//  Items.swift
//  Unbounded
//
//  Created by Paxon Yu on 7/13/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
enum itemType {
    case platform, ball
}

class Items: SKSpriteNode {
    
    var bought: Bool = false
    var cost: Int!
    var type: itemType!
    var itemColor: UIColor!
    var inUse: Bool = false
    var boughtTexture: SKTexture!
    var costLabel: SKLabelNode!
 
    var selected: SKSpriteNode!
    
    
    
    
    init(cost: Int, type: itemType, boughtTexture: SKTexture, color: UIColor){
        
        selected = SKSpriteNode(imageNamed: "selected")
        selected.scale(to: CGSize(width: 210, height: 150))
        selected.isHidden = true
        costLabel = SKLabelNode(fontNamed: "Exo2-ExtraLight")
        costLabel.text = String(cost)
        costLabel.fontSize = 50
        costLabel.zPosition = 5
        costLabel.position = CGPoint(x: 0, y: -25)
        let locked: SKTexture
        self.type = type
        self.cost = cost
        if type == .ball{
             locked = SKTexture(imageNamed: "lockedBall")
        }else {
             locked = SKTexture(imageNamed: "lockedPlatform")
        }
        super.init(texture: locked, color:  .clear, size: locked.size())
        self.scale(to: CGSize(width: 80, height: 60))
        self.boughtTexture = boughtTexture
        self.size = CGSize(width: 80, height: 60)
        addChild(selected)
        self.texture = locked
        self.isUserInteractionEnabled = true
        itemColor = color
        addChild(costLabel)
        

    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func update() {
        if inUse == true {
            selected.isHidden = false
            costLabel.isHidden = true
        }else {
            selected.isHidden = true
        }
    }
 
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch  = touches.first!
        if cost < bankDefault.integer(forKey: "bank") && bought == false {
            for item in itemArray {
                if item.type == self.type {
                item.inUse = false
                }
            }
            print("I ran inside")
            self.texture = boughtTexture
            inUse = true
            bought = true
            costLabel.isHidden = true
        }else if bought == true {
            for item in itemArray {
                if item.type == self.type {
                item.inUse = false
                }
            }
            inUse = true
        }
        
    }
    
    

}
