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
    case platform, ball, bonus
}

//welcome to the item class that populates the shop in this god forsaken game
class Items: SKSpriteNode {
    
    //boolean to determine whether the item has been bought or not
    var bought: Bool = false
    
    //cost of the item in coins
    var cost: Int!
    
    //what the item affects
    var type: itemType!
    
    //what color the item is
    var itemColor: UIColor!
    
    //boolean to determine whether the item is being used
    var inUse: Bool = false
    
    //what the item looks like when it's bought
    var boughtTexture: SKTexture!
    var costLabel: SKLabelNode!
    
    //the selected border
    var selected: SKSpriteNode!
    
    
    
    
    //initializer that determines the cost, item type, texture and color
    init(cost: Int, type: itemType, boughtTexture: SKTexture, color: UIColor){
        
        selected = SKSpriteNode(imageNamed: "selected")
        selected.scale(to: CGSize(width: 210, height: 150))
        selected.isHidden = true
        
        //positioning the cost label so that it appears super clear
        costLabel = SKLabelNode(fontNamed: "Exo2-ExtraLight")
        costLabel.text = String(cost)
        costLabel.fontSize = 50
        costLabel.zPosition = 5
        costLabel.position = CGPoint(x: 0, y: -25)
        let locked: SKTexture
        self.type = type
        self.cost = cost
        
        //determining the locked texture
        if type == .ball{
             locked = SKTexture(imageNamed: "lockedBall")
        }else if type == .platform {
             locked = SKTexture(imageNamed: "lockedPlatform")
        }else {
            locked = SKTexture(imageNamed: "lockedMystery")
        }
        super.init(texture: locked, color:  .clear, size: locked.size())
        
        //some size shit
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
    
 
    //updates the inUse boolean
    func update() {
        if inUse == true {
            selected.isHidden = false
            costLabel.isHidden = true
        }else {
            selected.isHidden = true
        }
        
        if bought == true {
            self.texture = boughtTexture
            costLabel.isHidden = true
        }
    }
 
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
       
        //if statement that determines whether the user is buying the item or selecting the item (note: please implement decrementing the currency for final version)
        if cost <= bankDefault.integer(forKey: "bank") && bought == false {
            for item in itemArray {
                if item.type == self.type {
                item.inUse = false
                }
            }
            self.texture = boughtTexture
            inUse = true
            bought = true
            costLabel.isHidden = true
            //bankDefault.set(bankDefault.integer(forKey: "bank")-cost, forKey: "bank")
            
            //the line of code above decrements the bank value and what not, pls uncomment for final version otherwise the shop will not work at all k thanks bye
            
            //select the item if bought already
        }else if bought == true && self.type != .bonus {
            for item in itemArray {
                if item.type == self.type {
                item.inUse = false
                }
            }
            inUse = true
        }
        
        if bought == true && self.type == .bonus {
            inUse = !inUse
        }
        
         updateShop()
        
    }
    
    

}
