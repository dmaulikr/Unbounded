//
//  GameViewController.swift
//  Unbounded
//
//  Created by Paxon Yu on 6/26/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if #available(iOS 10.0, *) {
            
            buildShop()
            var ballColor: UIColor = .white
            var platColor: UIColor = .white
            
            
            
            if itemDefault.array(forKey: "itemsBought")?.count == itemArray.count {
                var itemsBought = itemDefault.array(forKey: "itemsBought") as! [Bool]
                var itemsSelect = itemDefault.array(forKey: "itemsSelect") as! [Bool]
                var index = 0
                
                while itemsBought.count < itemArray.count {
                    itemsBought.append(false)
                    itemsSelect.append(false)
                }

                for item in itemArray {
                    item.inUse = itemsSelect[index]
                    item.bought = itemsBought[index]
                    index += 1
                }
                
                for item in itemArray {
                    if item.inUse == true && item.type == .ball {
                        ballColor = item.itemColor
                    }
                    if item.inUse == true && item.type == .platform {
                        platColor = item.itemColor
                    }
                }
                
            }else {
                itemDefault.set(true, forKey: "showTutorial")
                var itemsBought = [Bool]()
                var itemsSelect = [Bool]()
                var index = 0
                for item in itemArray {
                    itemsBought.append(item.bought)
                    if index <= 1 {
                        itemsSelect.append(true)
                    }else {
                        itemsSelect.append(false)
                    }
                    
                    index += 1
                }
            }
            
                if let scene = GameScene.colors(ballColor: ballColor, platColor: platColor) {
                    
                    // Get the SKScene from the loaded GKScene
                    if let sceneNode = scene as GameScene? {
                        
                        // Copy gameplay related content over to the scene
                        
                        // Set the scale mode to scale to fit the window
                        sceneNode.scaleMode = .aspectFit
                        
                        // Present the scene
                        if let view = self.view as! SKView? {
                            view.presentScene(sceneNode)
                            
                            view.ignoresSiblingOrder = true
                    
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
