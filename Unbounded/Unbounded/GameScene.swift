//
//  GameScene.swift
//  Unbounded
//
//  Created by Paxon Yu on 6/26/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import SpriteKit
import GameplayKit

let scoreDefault = UserDefaults.standard
let bankDefault = UserDefaults.standard
let itemDefault = UserDefaults.standard

let fixedDelta: CFTimeInterval = 1.0 / 60.0
enum GameState {
    case play, gameOver, mainMenu, paused
}

//function used to scale a vector based on a given scalar
public func scale(_ vector: CGVector, _ scalar: CGFloat) -> CGVector {
    let dx = vector.dx * CGFloat(scalar)
    let dy = vector.dy * CGFloat(scalar)
    return CGVector(dx: dx, dy: dy)
    
}

//used to calculate distance since fucking .lineLength isn't doing its job
public func calcDistance(_ start: CGPoint, _ end: CGPoint) -> CGFloat {
    let xDist = start.x - end.x
    let yDist = start.y - end.y
    let dist = sqrt((xDist*xDist) + (yDist*yDist))
    return dist
    
}

//personal clamp function
func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value,lower),upper)
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var ballColor: UIColor = .white
    var platformColor: UIColor = .white
    
    //world node used to add objects to so that pause can be implemented effectively
    let worldNode = SKNode()
    
    //empty node used for convenience to move the camera to the main menu
    var mainMenuPos: SKNode!
    
    //boolean used to determine whether the game has started and then begin incrementing timers
    var gameStarted: Bool = false
    
    var coinExist: Bool = false
    
    //boolean used to determine whether a cameraTarget is assigned
    var targetFound: Bool = false
    var rightWall: SKSpriteNode!
    var leftWall: SKSpriteNode!
    var ground: SKSpriteNode!
    var state: GameState = .mainMenu
    var scoreLabel: SKLabelNode!
    var loseScoreNum: SKLabelNode!
    var lineStart: CGPoint?
    var lineEnd: CGPoint?
    var loseArea: SKSpriteNode!
    var highscoreNum: SKLabelNode!
    var loseCamera: SKCameraNode!
    var cameraTarget: SKNode?
    var previewLine: SKShapeNode?
    var previewEnd: CGPoint?
    var bank: SKLabelNode!
  
    var pauseButton: SKSpriteNode!
    
    //Buttons!!
    var resetButton: MSButtonNode!
    var playStart: MSButtonNode!
    var pauseButtonNode: MSButtonNode!
    var homeButton: MSButtonNode!
    var shopButton: MSButtonNode!
    
    
 
    
    var bounds: SKSpriteNode!
    let ball = Ball()
    
    //minimum length of a platform allowed
    let minLength: CGFloat =  15
    
    //array used to store the platforms (note: only stores the information for convenient access)
    var platforms: [Platform] = []
    
    //Timer used to determine how often a ball gets added
    var ballTimer: CFTimeInterval = 0
    var coinTimer: CFTimeInterval = 0
    var randomTime = CFTimeInterval(arc4random_uniform(10) + 15)
    
    //used to add each ball to a different z Position
    var zIncrement:CGFloat = 1
    
    //first ball (note: use this for tutorial purposes)
    var firstBall: SKSpriteNode!
    
    //determines the intensity of richochet off of the left and right wall
    let wallBounce = 10
    var score = 0
    var highscore = 0
    var bankNum = 0
    
    var hitSound = SKAction.playSoundFileNamed("HitSound", waitForCompletion: false)
    let trail = SKEmitterNode(fileNamed: "Trail.sks")
    let emitter = SKEmitterNode(fileNamed: "Impact.sks")
    var whoosh = SKAction.playSoundFileNamed("whoosh", waitForCompletion: true)
    
    
    //initializes all of the nodes and sets the physical properties of the left and right wall
    override func didMove(to view: SKView) {

        print(ballColor)
        if bankDefault.integer(forKey: "bank") != 0 {
            bankNum = bankDefault.integer(forKey: "bank")
        }else {
            bankNum = 0
        }
        
        trail?.particleColorSequence = nil
        trail?.particleColorBlendFactor = 1.0
        trail?.particleColor = ballColor
        emitter?.particleColorSequence = nil
        emitter?.particleColorBlendFactor = 1.0
        emitter?.particleColor = platformColor
        emitter?.zPosition = -1
        
        shopButton = childNode(withName: "shopButton") as! MSButtonNode
       
        playStart = childNode(withName: "playStart") as! MSButtonNode
        mainMenuPos = childNode(withName: "mainMenuPos")!
        homeButton = childNode(withName: "homeButton") as! MSButtonNode
        resetButton = childNode(withName: "resetButton") as! MSButtonNode
        pauseButtonNode = childNode(withName: "pauseButtonNode") as! MSButtonNode
        
        
        self.addChild(worldNode)
        pauseButton = childNode(withName: "pauseButton") as! SKSpriteNode
    
        bounds = childNode(withName: "bounds") as! SKSpriteNode
        
        highscoreNum = childNode(withName: "highscoreNum") as! SKLabelNode
        bank = childNode(withName: "bank") as! SKLabelNode
        loseScoreNum = childNode(withName: "loseScoreNum") as! SKLabelNode
        self.view?.isMultipleTouchEnabled = false
        loseCamera = childNode(withName: "loseCamera") as! SKCameraNode
        self.camera = loseCamera
        rightWall = childNode(withName: "rightWall") as! SKSpriteNode
        leftWall = childNode(withName: "leftWall") as! SKSpriteNode
        loseArea = childNode(withName: "loseArea") as! SKSpriteNode
        leftWall.physicsBody?.restitution = 1
        rightWall.physicsBody?.restitution = 1
        leftWall.physicsBody?.linearDamping = 0.2
        rightWall.physicsBody?.linearDamping = 0.2
        ground = childNode(withName: "ground") as! SKSpriteNode
        firstBall = childNode(withName: "firstBall") as! SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        physicsWorld.contactDelegate = self
        calcHighscore()
        firstBall.isHidden = true
        trail?.physicsBody?.affectedByGravity = false
        trail?.targetNode = scene
        ball.color = ballColor
        ball.addChild(trail?.copy() as! SKEmitterNode)
        ball.position = CGPoint(x: 1.81, y: 136.6)
        ball.physicsBody?.isDynamic = false
        worldNode.addChild(ball)
        highscoreNum.text = String(highscore)
        bank.text = String(bankNum)
        resetButton.alpha = 0
        loseCamera.position = mainMenuPos.position
        
        shopButton.selectedHandler = {
            
            let reveal = SKTransition.flipVertical(withDuration: 0.3)
            if let scene = GKScene(fileNamed: "ShopScreen_1") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! SKScene? {
                    
                    // Copy gameplay related content over to the scene
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    if let view = self.view as! SKView? {
                        self.view?.presentScene(sceneNode, transition: reveal)
                        
                        view.ignoresSiblingOrder = true
                        
                        view.showsFPS = true
                        view.showsNodeCount = true
                    }
                }
            }
        }
        playStart.selectedHandler = {
            
            self.state = .play
            self.cameraTarget = nil
            self.run(self.whoosh)
            self.resetCamera()
            self.coinExist = false
            
            
        }
        
        homeButton.selectedHandler = {
            self.reset()
            self.state = .mainMenu
            self.cameraTarget = self.mainMenuPos
            self.run(self.whoosh)
            self.worldNode.isPaused = false
            self.pauseButton.texture = SKTexture(imageNamed: "pauseButton")
            self.physicsWorld.speed = 1
            
        }
        
        pauseButtonNode.selectedHandler = {
            if self.worldNode.isPaused == false {
                self.worldNode.isPaused = true
                self.pauseButton.texture = SKTexture(imageNamed: "playTexture")
                self.physicsWorld.speed = 0
                self.state = .paused
            }else {
                self.worldNode.isPaused = false
                self.pauseButton.texture = SKTexture(imageNamed: "pauseButton")
                self.physicsWorld.speed = 1
                self.state = .play
            }
            
        }
        resetButton.selectedHandler = {
            print(self.numberOfBalls())
            self.resetCamera()
            self.reset()
            self.worldNode.isPaused = false
            self.pauseButton.texture = SKTexture(imageNamed: "pauseButton")
            self.physicsWorld.speed = 1
            
            //to address any bugs where the score isn't set to zero when the lose screen begins
            self.score = 0
            
        }
        
    }
    
    //MARK: Interactions
    
    //identifies the position of the first touch and stores it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .play {
            if platforms.count == 1 {
                platforms[0].removeFromParent()
                platforms.removeFirst()
            }
            let touch = touches.first!
            let location = touch.location(in: self)
            lineStart = location
        }
        
    }
    
    //constantly cretaes and removes a child node based on the user's touch location
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .play {
            let touch = touches.first!
            previewLine?.removeFromParent()
            let location = touch.location(in: self)
            previewEnd = location
            var lineArray: [CGPoint] = [lineStart!, location]
            previewLine = SKShapeNode(points: &lineArray, count: 2)
            previewLine?.strokeColor = platformColor
            if calcDistance(lineStart!, location) > minLength {
                addChild(previewLine!)
            }
        }
        
    }
    
    //uses where the finger lifted off to initialize a platform and add it to the arrary then add it to the scene
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .play {
            
            //if a new platform is created then turn off all the justContact booleans
            for child in worldNode.children {
                if child.name == "ball" {
                let ball = child as! Ball
                ball.justContact = false
                ball.readyToBounce = false
                }
            }
            previewLine?.removeFromParent()
            let touch = touches.first!
            let location = touch.location(in:self)
            lineEnd = location
            if calcDistance(lineStart!, location) > minLength {
                let drawLine = Platform(lineStart!,lineEnd!,platformColor)
                platforms.append(drawLine)
                worldNode.addChild(drawLine)
                lineStart = nil
                lineEnd = nil
                gameStarted = true
                
                //first ball used as a tutorial function
                ball.physicsBody?.isDynamic = true
            }
        }
    }
    
    
    //MARK: The All important Update Function
    
    //used to maintain the one platform limit, update the platforms, remove them from the array, and increment timers. Also it's used to modify each balls physics masks in order to ensure that the balls pass through platforms on the bottom but make contact at the top
    override func update(_ currentTime: TimeInterval) {
        
        if self.camera?.position.y != 0 {
            self.isUserInteractionEnabled = false
        }else {
            self.isUserInteractionEnabled = true
        }
        
        highscoreNum.text = String(highscore)
        bank.text = String(bankNum)
        moveCamera()
        
        if state == .play {
            
            spawnCoins()
            
            //limits the vertical velocity downwards
            for ball in worldNode.children {
                if ball.name == "ball" {
                    let ballBody = ball as! Ball
                    ballBody.glitchTimer += fixedDelta
                    if (ball.physicsBody?.velocity.dy)! <  -CGFloat(300){
                        ball.physicsBody?.velocity.dy = -300
                    }
                }
                
                //iterates through all of the coins and if the coin has existed for longer than a certain threshold then remove it
                if ball.name == "coin" {
                    let coin = ball as! Coin
                    coin.timer +=  fixedDelta
                    if coin.timer > 10.0 {
                        coin.removeFromParent()
                        coinExist = false
                    }
                }
                
            }
            //only permits that one platform exists at any given point in time
            scoreLabel.text = String(score)
            loseScoreNum.text = String(score)
            while platforms.count > 1{
                platforms[0].removeFromParent()
                platforms.removeFirst()
            }
            for platform in platforms {
                platform.update()
            }
            
            //removes platforms from the array if they don't exist
            var index = 0
            for platform in platforms {
                if platform.exist == false {
                    platforms.remove(at: index)
                }
                index += 1
            }
            
            //assuming that the game has started, update all the timers
            if gameStarted && state == .play{
                //updates all the timers
                ballTimer += fixedDelta
                coinTimer += fixedDelta
            }
            
            //adds a ball every five seconds (probably should try and scale this exponentially)
            if ballTimer > 5 {
                addBall()
                ballTimer = 0
                
            }
            
        }
        
        
        //the secret to one way platforms also sets ready to Bounce to prevent the slingshot effect from the bottom
        for child in worldNode.children{
          
            if(child.name == "ball") {
                 let ballBody = child as! Ball
                
                //if the ball has a negative y velocity or has just made contact with a platform, then allow the ball to make contact again
                if (child.physicsBody?.velocity.dy)! < CGFloat(0.0) || ballBody.justContact == true {
                    child.physicsBody?.collisionBitMask = 14
                    child.physicsBody?.contactTestBitMask = 10
                    let ball = child as! Ball
                    ball.readyToBounce = true
                }else {
                    child.physicsBody?.collisionBitMask = 6
                    child.physicsBody?.contactTestBitMask = 0
                    let ball = child as! Ball
                    ball.readyToBounce = false
                }
            }
        }
        
    }
    
    //introduces new balls into the scene, uses a random number generator to determine which side of the scene
    //the balls spawn on (left or right)
    func addBall() {
        
        let newBall = Ball()
        newBall.color = ballColor
        let decider = arc4random_uniform(2)
        let initialVelocity = Int(arc4random_uniform(200) + 200)
        trail?.physicsBody?.affectedByGravity = false
        trail?.targetNode = scene
        switch decider {
        case 0:
            
            newBall.position.x = 150
            newBall.position.y = -350
            newBall.addChild(trail?.copy() as! SKEmitterNode)
            worldNode.addChild(newBall)
            newBall.physicsBody!.applyImpulse(CGVector(dx: -100, dy: initialVelocity))
            newBall.zPosition = zIncrement
            zIncrement += 1
            
        case 1:
            
            newBall.position.x = -150
            newBall.position.y = -350
            newBall.addChild(trail?.copy() as! SKEmitterNode)
            worldNode.addChild(newBall)
            newBall.physicsBody!.applyImpulse(CGVector(dx: 100, dy: initialVelocity))
            newBall.zPosition = zIncrement
            zIncrement += 1
            
        default:
            worldNode.addChild(newBall)
        }
        
        
    }
    
    //MARK: Physics Interactions
    //does a bunch of stuff
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        
        //used to determine the max amount of force applied by the smalles possible platform
        let maxScalar: CGFloat = 0.2
        
        //used to determine the position/placement of the particle effect
        let position = contact.contactPoint
        
        if nodeA.name == "platform" && nodeB.name == "ball" {
            
            let ball = nodeB as! Ball
            if ball.readyToBounce == true && ball.glitchTimer > 0.05 {
                ball.glitchTimer = 0
                ball.justContact = true
                var force: CGFloat! = 0
                for platform in platforms {
                    if nodeA.position == platform.position {
                        force = platform.forceScalar
                        let emitter2 = emitter?.copy() as! SKEmitterNode
                        platform.addChild(emitter2)
                        emitter2.particleBirthRate = (emitter?.particleBirthRate)! * force
                        emitter2.particleScale = (emitter?.particleScale)! * force * 0.2
                        emitter2.position = position
                        emitter2.run(SKAction.fadeOut(withDuration: 0.1))
                    }
                }
                run(hitSound)
                nodeB.physicsBody?.applyImpulse(scale(CGVector(dx: 0, dy: 450), maxScalar * force))
                
                score += 1
                scoreLabel.text = String(score)
            }
            
           
            
        }
        if nodeB.name == "platform" && nodeA.name == "ball" {
            
            let ball = nodeA as! Ball
            if ball.readyToBounce == true && ball.glitchTimer > 0.05 {
                ball.glitchTimer = 0
                ball.justContact = true
                var force: CGFloat! = 0
                for platform in platforms {
                    if nodeB.position == platform.position {
                        force = platform.forceScalar
                        let emitter2 = emitter?.copy() as! SKEmitterNode
                        platform.addChild(emitter2)
                        emitter2.particleBirthRate = (emitter?.particleBirthRate)! * force
                        emitter2.particleScale = (emitter?.particleScale)! * force * 0.2
                        emitter2.position = position
                        emitter2.run(SKAction.fadeOut(withDuration: 0.1))
                    }
                }
                run(hitSound)
                nodeA.physicsBody?.applyImpulse(scale(CGVector(dx: 0, dy: 450), maxScalar * force))
               
                score += 1
                scoreLabel.text = String(score)
            }
            
            
            
        }
        
        
        //block of code used to make the walls bouncier (might not need it?)
        if nodeA.name == "leftWall" && nodeB.name == "ball" {
            nodeB.physicsBody?.applyImpulse(CGVector(dx:wallBounce, dy:0))
        }
        if nodeA.name == "ball" && nodeB.name == "leftWall" {
            nodeA.physicsBody?.applyImpulse(CGVector(dx: wallBounce, dy:0))
        }
        if nodeA.name == "rightWall" && nodeB.name == "ball" {
            nodeB.physicsBody?.applyImpulse(CGVector(dx:-wallBounce, dy: 0))
        }
        if nodeA.name == "ball" && nodeB.name == "rightWall" {
            nodeA.physicsBody?.applyImpulse(CGVector(dx:-wallBounce,dy: 0))
        }
        
        
        if nodeA.name == "ground" && nodeB.name == "ball" {
            nodeB.physicsBody?.restitution = 0.7
        }
        if nodeA.name == "ball" && nodeB.name == "ground" {
            nodeA.physicsBody?.restitution = 0.7
        }
        if nodeA.name == "loseArea" && nodeB.name == "ball"  {
            calcHighscore()
            nodeB.physicsBody?.categoryBitMask = 2
            removeCoins()
            if !targetFound {
                cameraTarget = nodeB
                targetFound = true
            }
            state = .gameOver
            resetButton.isUserInteractionEnabled = false
            isUserInteractionEnabled = false
            resetButton.run(SKAction.fadeIn(withDuration: 0.5),completion: {
                self.isUserInteractionEnabled = true
                self.resetButton.isUserInteractionEnabled = true
                nodeB.physicsBody?.restitution = 0.7
            })
          
        }
        if nodeA.name == "ball" && nodeB.name == "loseArea" {
            calcHighscore()
            nodeA.physicsBody?.categoryBitMask = 2
            removeCoins()
            if !targetFound {
                cameraTarget = nodeA
                targetFound = true
                
            }
            state = .gameOver
            isUserInteractionEnabled = false
            resetButton.isUserInteractionEnabled = false
            resetButton.run(SKAction.fadeIn(withDuration: 0.5), completion: {
                self.isUserInteractionEnabled = true
                self.resetButton.isUserInteractionEnabled = true
                nodeA.physicsBody?.restitution = 0.7
            })
            
        }
        
        if nodeA.name == "bounds" || nodeB.name == "bounds" {
            print("we lost one")
        }
        
        
        if nodeA.name == "ball" && nodeB.name == "coin" {
            nodeB.run(SKAction.init(named: "coinCollect")!,completion: {
                nodeB.removeFromParent()
            })
            
            bankDefault.set(bankDefault.integer(forKey: "bank") + 1, forKey: "bank")
            bankNum = bankDefault.integer(forKey: "bank")
            coinExist = false
        }
        if nodeB.name == "ball" && nodeA.name == "coin" {
            nodeA.run(SKAction.init(named: "coinCollect")!, completion: {
                nodeA.removeFromParent()
            })
            
            bankDefault.set(bankDefault.integer(forKey: "bank") + 1, forKey: "bank")
            bankNum = bankDefault.integer(forKey: "bank")
            coinExist = false
        }
    }
    
    //calculates highscore for the whole game using User Defaults
    func calcHighscore() {
        
        if score > highscore {
            highscore = score
            scoreDefault.set(highscore, forKey: "highscoreNum")
        }
        if scoreDefault.integer(forKey: "highscoreNum") != 0 {
            highscore = scoreDefault.integer(forKey: "highscoreNum")
            
        }else {
            highscore = 0
        }
    }
    
    //if a camera target exists, follow the target but don't go lower than a certain threshold
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        
        let targetY = cameraTarget.position.y
        let y = clamp(value: targetY, lower: -590, upper: 9220)
        loseCamera.run(SKAction.moveTo(y: y, duration: 0.3))
    }
    
    //reset function that deletes all current platforms, removes every single ball
    func reset() {
        for child in worldNode.children {
            if child.name == "ball" {
                child.removeFromParent()
            }
        }
        if platforms.count == 1 {
            platforms[0].removeFromParent()
            platforms.removeFirst()
        }
        score = 0
        coinExist = false
        coinTimer = 0
        resetButton.run(SKAction.fadeOut(withDuration: 0.3))
        
        state = .play
        
    }
    
    
    //resets the camera to the default
    func resetCamera() {
        let cameraReset = SKAction.move(to: CGPoint(x:0, y:0), duration: 1.0)
        cameraReset.timingMode = .easeInEaseOut
        let cameraDelay = SKAction.wait(forDuration: 0.1)
        let cameraSequence = SKAction.sequence([cameraDelay, cameraReset])
        loseCamera.run(cameraSequence)
        targetFound = false
        cameraTarget = nil
    }
    
    //method that counts the number of balls on the screen
    func numberOfBalls() -> Int {
        var number = 0
        for child in worldNode.children {
            if child.name == "ball" {
                number += 1
            }
        }
        return number
    }
    
    func removeCoins() {
        for child in worldNode.children {
            if child.name == "coin" {
                child.removeFromParent()
            }
        }
    }
    
    func spawnCoins() {
        //spawn coins at a random time interval
        print(coinTimer)
        if coinTimer > randomTime && !coinExist {
            randomTime = CFTimeInterval(arc4random_uniform(15) + 5)
            coinTimer = 0
            coinExist = true
            let xPos = Int(arc4random_uniform(240)) - 120
            let yPos = Int(arc4random_uniform(100)) - 50 
            let coin = Coin()
            coin.position = CGPoint(x: xPos, y: yPos)
            worldNode.addChild(coin)
        }
    }
    
    class func colors(ballColor: UIColor, platColor: UIColor) -> GameScene? {
        guard let scene = GameScene(fileNamed: "GameScene") else {
            return nil
        }
        
        scene.scaleMode = .aspectFit
        scene.ballColor = ballColor
        scene.platformColor = platColor
        
        return scene
    }
}

