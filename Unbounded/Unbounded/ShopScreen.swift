//
//  ShopScreen.swift
//  Unbounded
//
//  Created by Paxon Yu on 7/13/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit

//universal array used to store items and what condtiion they are in (note: please implement User Defaults for this some time soon
var itemArray = [Items]()




func updateShop() {
    
    var itemsBought = [Bool]()
    for item in itemArray {
        itemsBought.append(item.bought)
    }
    itemDefault.set(itemsBought, forKey: "itemsBought")
}



//welcome to the class that stores all the items in this game, items being aesthetic customization options for the balls and paddles, the ball items will change the color of the ball and the tails of the ball while the platform items will change the color of the platform and the particle effect named impact.sks
class ShopScreen: SKScene{
    
    
    //variable to determine which page of the shop the user is currently viewing
    var pageNum: Int = 1
    
    //return button, next page and previous page buttons
    var returnHome: MSButtonNode!
    var nextPage: MSButtonNode?
    var prevPage: MSButtonNode?
    
    
    //label to tell the user how much currency the user has
    var bankLabel: SKLabelNode!
 
    
    
    override func didMove(to view: SKView) {
        returnHome = childNode(withName: "returnHome") as! MSButtonNode
        bankLabel = childNode(withName: "bankLabel") as! SKLabelNode
        bankLabel.text = String(bankDefault.integer(forKey: "bank"))
        nextPage = childNode(withName: "nextPage") as? MSButtonNode
        prevPage = childNode(withName: "prevPage") as? MSButtonNode
        
        //jank solution to only initialize the shop once, will initialize the entire shop in this exact order exactly once
        
        if itemArray.count ==  0 {
            addItem(cost: 0, type: .ball, boughtTexture: SKTexture(imageNamed: "whiteBallBought"), color: .white)
            itemArray[0].inUse = true
            itemArray[0].texture = itemArray[0].boughtTexture
            addItem(cost: 0, type: .platform, boughtTexture: SKTexture(imageNamed: "whitePlatBought"), color: .white)
            itemArray[1].inUse = true
            itemArray[1].texture = itemArray[1].boughtTexture
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed: "blueBallBought"), color: .blue)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "bluePlatBought"), color: .blue)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed:"greenPlatBought"), color: .green)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed: "imgurGreenBallBought"), color: imgurGreen)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "imgurGreenPlatBought"), color: imgurGreen)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed: "greenBallBought"), color: .green)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed:"cyanBallBought"), color: .cyan)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed:"cyanPlatBought"), color: .cyan)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed:"starburstOrangeBallBought"), color: starburstOrange)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "starburstOrangePlatBought"), color: starburstOrange)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed:"royalPurpleBallBought"), color: royalPurple)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "royalPurplePlatBought"), color: royalPurple)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed: "ceruleanBallBought"), color: cerulean)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "ceruleanPlatBought"), color: cerulean)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed: "redBallBought"), color: .red)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "redPlatBought"), color: .red)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "yellowPlatBought"), color: .yellow)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed: "yellowBallBought"), color: .yellow)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed: "goldBallBought"), color: gold)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "goldPlatBought"), color: gold)
            addItem(cost: 200, type: .ball, boughtTexture: SKTexture(imageNamed: "ghostBallBought"), color: .clear)
            addItem(cost: 1000, type: .bonus, boughtTexture: SKTexture(imageNamed: "sparkleBought"), color: .clear)
        }
        
        if itemDefault.array(forKey: "itemsBought") == nil{
            var itemsBought = [Bool]()
            for item in itemArray {
                itemsBought.append(item.bought)
            }
            itemDefault.set(itemsBought, forKey: "itemsBought")
            
        }else {
            var itemsBought = itemDefault.value(forKey: "itemsBought") as! [Bool]
            while itemsBought.count < itemArray.count {
                itemsBought.append(false)
            }
            var index = 0
            for item in itemArray {
                item.bought = itemsBought[index]
                index += 1
            }
            
        }
        //called to place all of the items on the appropriate part of the page
        placeItems()
        
        
        //brings the view to the previous page provided that one exists
        prevPage?.selectedHandler = {  [unowned self] in
            let reveal = SKTransition.push(with: SKTransitionDirection.right, duration: 0.3)
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                if let scene = ShopScreen.shopScreen(self.pageNum - 1){
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    // Present the scene
                    self.view?.presentScene(scene, transition: reveal)
                }
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = true
                view.showsNodeCount = true
                
            }

        }
        
        //brings the view to the next page provided that one exists
        nextPage?.selectedHandler = {  [unowned self] in
            let reveal = SKTransition.push(with: SKTransitionDirection.left, duration: 0.3)
            if let view = self.view as! SKView? {
    
                if let scene = ShopScreen.shopScreen(self.pageNum + 1){
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    // Present the scene
                    self.view?.presentScene(scene, transition: reveal)
                }
                
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = true
                view.showsNodeCount = true
                
            }
        }
        
        //brings the player back to the main game screen while passing in the values
        returnHome.selectedHandler = { [unowned self] in
            var ballColor: UIColor = .white
            var platColor: UIColor = .white
            for item in itemArray {
                if item.type == .ball && item.inUse == true {
                    ballColor = item.itemColor
                }
                if item.type == .platform && item.inUse == true {
                    platColor = item.itemColor
                }
            }
            
            //removes all of the items from the current page for whatever reason
            for item in itemArray {
                item.removeFromParent()
            }
            
            
            let reveal = SKTransition.flipVertical(withDuration: 0.3)
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                if let scene = GameScene.colors(ballColor: ballColor, platColor: platColor){
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    // Present the scene
                    self.view?.presentScene(scene, transition: reveal)
                }
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = true
                view.showsNodeCount = true
                
            }
        }
    }
    
    
    
    //initializes an item from the item class and appends it to the item array
    func addItem(cost: Int, type: itemType, boughtTexture: SKTexture, color: UIColor) {
        let itemToAdd = Items(cost: cost, type: type, boughtTexture: boughtTexture, color: color)
        itemArray.append(itemToAdd)
    }
    
    //places the items in a grid of 3x5 per screen
    func placeItems() {
        if pageNum == 1 {
            for index in  0...14 {
                if index % 3 == 0 {
                    itemArray[index].position.x = -100
                }else if index % 3 == 1 {
                    itemArray[index].position.x = 0
                }else {
                    itemArray[index].position.x = 100
                }
                let numRows = Int((index) / 3)
                itemArray[index].position.y = CGFloat(85 - 80 * numRows)
                addChild(itemArray[index])
            }
        }else {
            for index in 15...itemArray.count - 1 {
                if index % 3 == 0 {
                    itemArray[index].position.x = -100
                }else if index % 3 == 1 {
                    itemArray[index].position.x = 0
                }else {
                    itemArray[index].position.x = 100
                }
                let numRows = Int((index % 15) / 3)
                itemArray[index].position.y = CGFloat(85 - 80 * numRows)
                addChild(itemArray[index])
            }
        }
        
    }
    
    //updates the bankLabel and updates each item to make sure that they are properly used
    override func update(_ currentTime: TimeInterval) {
        bankLabel.text = String(bankDefault.integer(forKey: "bank"))
        for item in itemArray {
            item.update()
        }
    }
    

    //function used to pass in different pages of the shop
    class func shopScreen(_ page: Int) -> ShopScreen? {
        guard let scene = ShopScreen(fileNamed: "ShopScreen_\(page)")else {
            return nil
        }
        for item in itemArray {
            item.removeFromParent()
        }
        scene.pageNum = page
        scene.scaleMode = .aspectFit
        return scene
    }
    
    
}
