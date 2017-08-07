//
//  moreCoins.swift
//  Unbounded
//
//  Created by Paxon Yu on 8/1/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit
import GoogleMobileAds

class moreCoins: SKScene, GADRewardBasedVideoAdDelegate {
    /// Tells the delegate that the reward based video ad has rewarded the user.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        
    }

    var watchAd: MSButtonNode!
    var backToShop: MSButtonNode!
    var bankLabel: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        watchAd = childNode(withName: "watchAd") as! MSButtonNode
        backToShop = childNode(withName: "backToShop") as! MSButtonNode
        bankLabel = childNode(withName: "bankLabel") as! SKLabelNode
        updateLabel()
        
        let scene = SKScene(fileNamed: "ShopScreen_1")
     
        watchAd.selectedHandler = {
                    
            if GADRewardBasedVideoAd.sharedInstance().isReady == true {
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: (self.view?.window?.rootViewController)!)
            }
        }
        
        backToShop.selectedHandler = { [unowned self] in
            let reveal = SKTransition.doorsCloseVertical(withDuration: 0.3)
            if let view = self.view {
                // Load the SKScene from 'GameScene.sks'
                
             
                    // Set the scale mode to scale to fit the window
                    scene?.scaleMode = .aspectFit
                    // Present the scene
                
                    self.view?.presentScene(scene!, transition: reveal)
                
                
                
                view.ignoresSiblingOrder = true
                

                
            
            }

        }
    }
    
    func updateLabel() {
        bankLabel.text = String(bankDefault.integer(forKey: "bank"))
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateLabel()
    }
    
    
}
