//
//  ShopScreen.swift
//  Unbounded
//
//  Created by Paxon Yu on 7/13/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit


var itemArray = [Items]()

class ShopScreen: SKScene{
    
    var pageNum: Int = 1
    var returnHome: MSButtonNode!
    var bankLabel: SKLabelNode!
    var nextPage: MSButtonNode?
    var prevPage: MSButtonNode?
    
    
    override func didMove(to view: SKView) {
        returnHome = childNode(withName: "returnHome") as! MSButtonNode
        bankLabel = childNode(withName: "bankLabel") as! SKLabelNode
        bankLabel.text = String(bankDefault.integer(forKey: "bank"))
        nextPage = childNode(withName: "nextPage") as? MSButtonNode
        prevPage = childNode(withName: "prevPage") as? MSButtonNode
        
        if itemArray.count ==  0 {
            addItem(cost: 0, type: .ball, boughtTexture: SKTexture(imageNamed: "whiteBallBought"), color: .white)
            itemArray[0].inUse = true
            itemArray[0].texture = itemArray[0].boughtTexture
            addItem(cost: 0, type: .platform, boughtTexture: SKTexture(imageNamed: "whitePlatBought"), color: .white)
            itemArray[1].inUse = true
            itemArray[1].texture = itemArray[1].boughtTexture
            addItem(cost: 20, type: .ball, boughtTexture: SKTexture(imageNamed: "blueBallBought"), color: .blue)
            addItem(cost: 20, type: .platform, boughtTexture: SKTexture(imageNamed: "bluePlatBought"), color: .blue)
            addItem(cost: 30, type: .platform, boughtTexture: SKTexture(imageNamed:"greenPlatBought"), color: .green)
            addItem(cost: 100, type: .ball, boughtTexture: SKTexture(imageNamed: "imgurGreenBallBought"), color: imgurGreen)
            addItem(cost: 100, type: .platform, boughtTexture: SKTexture(imageNamed: "imgurGreenPlatBought"), color: imgurGreen)
            addItem(cost: 20, type: .ball, boughtTexture: SKTexture(imageNamed: "greenBallBought"), color: .green)
            addItem(cost: 20, type: .ball, boughtTexture: SKTexture(imageNamed:"cyanBallBought"), color: .cyan)
            addItem(cost: 20, type: .platform, boughtTexture: SKTexture(imageNamed:"cyanPlatBought"), color: .cyan)
            addItem(cost: 20, type: .ball, boughtTexture: SKTexture(imageNamed:"starburstOrangeBallBought"), color: starburstOrange)
            addItem(cost: 20, type: .platform, boughtTexture: SKTexture(imageNamed: "starburstOrangePlatBought"), color: starburstOrange)
            addItem(cost: 20, type: .ball, boughtTexture: SKTexture(imageNamed:"royalPurpleBallBought"), color: royalPurple)
            addItem(cost: 20, type: .platform, boughtTexture: SKTexture(imageNamed: "royalPurplePlatBought"), color: royalPurple)
            addItem(cost: 20, type: .ball, boughtTexture: SKTexture(imageNamed: "ceruleanBallBought"), color: cerulean)
            addItem(cost: 20, type: .platform, boughtTexture: SKTexture(imageNamed: "ceruleanPlatBought"), color: cerulean)
            addItem(cost: 20, type: .ball, boughtTexture: SKTexture(imageNamed: "redBallBought"), color: .red)
            addItem(cost: 20, type: .platform, boughtTexture: SKTexture(imageNamed: "redPlatBought"), color: .red)
            
        }
        placeItems()
        
        prevPage?.selectedHandler = {
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
        
        nextPage?.selectedHandler = {
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
        
        
        returnHome.selectedHandler = {
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
    
    
    
    
    func addItem(cost: Int, type: itemType, boughtTexture: SKTexture, color: UIColor) {
        let itemToAdd = Items(cost: cost, type: type, boughtTexture: boughtTexture, color: color)
        itemArray.append(itemToAdd)
    }
    
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
                let numRows = Int((index-15) / 3)
                itemArray[index].position.y = CGFloat(85 - 80 * numRows)
                addChild(itemArray[index])
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        bankLabel.text = String(bankDefault.integer(forKey: "bank"))
        for item in itemArray {
            item.update()
        }
    }
    
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
