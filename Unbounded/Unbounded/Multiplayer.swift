//
//  Multiplayer.swift
//  Unbounded
//
//  Created by Paxon Yu on 6/26/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import SpriteKit
import GameplayKit



class Multiplayer: SKScene, SKPhysicsContactDelegate {
    
    
    //world node used to add objects to so that pause can be implemented effectively
    let worldNode = SKNode()
    
    
    //var coinExist: Bool = false
    
    //boolean used to determine whether a cameraTarget is assigned
    var targetFound: Bool = false
    var rightWall: SKSpriteNode!
    var leftWall: SKSpriteNode!
    var state: GameState = .ready
    var redLives: SKLabelNode!
    var redLivesNum: Int = 10
    var blueLives: SKLabelNode!
    var blueLivesNum: Int = 10
    
    
    
    var blueLineStart: CGPoint?
    var blueLineEnd: CGPoint?
    var redLineStart: CGPoint?
    var redLineEnd: CGPoint?
    
    var loseAreaBlue: SKSpriteNode!
    var loseAreaRed: SKSpriteNode!
    var bluePreviewLine: SKShapeNode?
    var redPreviewLine: SKShapeNode?
    var bluePreviewEnd: CGPoint?
    var redPreviewEnd: CGPoint?
    var blueTouch: UITouch?
    var redTouch: UITouch?
    var redStart: Bool = false
    var blueStart: Bool = false
    var pauseButton: SKSpriteNode!
    
    let terminalVelocity: CGFloat = 700
    let platformBounce: CGFloat = 200.0
    let restitution: CGFloat = 0.1
    let globalSpeed: CGFloat = 0.85
    
    
    //Buttons!!
    var resetButton: MSButtonNode!
    var homeButton: MSButtonNode!
    var multiplayerStart: MSButtonNode!
    var multiplayerRestart: MSButtonNode!
    
    
    //minimum length of a platform allowed
    let minLength: CGFloat =  15
    
    //array used to store the platforms (note: only stores the information for convenient access)
    var platforms: [Platform] = []
    
    //Timer used to determine how often a ball gets added
    var ballTimer: CFTimeInterval = 0
    var randomTime = CFTimeInterval(arc4random_uniform(10) + 15)
    
    //used to add each ball to a different z Position
    var zIncrement:CGFloat = 1
    
    //determines the intensity of richochet off of the left and right wall
    let wallBounce = 10
    var score = 0
    var highscore = 0
    
    var hitSound = SKAction.playSoundFileNamed("HitSound", waitForCompletion: false)
    let trail = SKEmitterNode(fileNamed: "Trail.sks")
    let emitter = SKEmitterNode(fileNamed: "Impact.sks")
    
    
    //initializes all of the nodes and sets the physical properties of the left and right wall
    override func didMove(to view: SKView) {
        trail?.particleColorSequence = nil
        trail?.particleColorBlendFactor = 1.0
        emitter?.particleColorSequence = nil
        emitter?.particleColorBlendFactor = 1.0
        emitter?.zPosition = -1
        redLives = childNode(withName: "redLives") as! SKLabelNode
        blueLives = childNode(withName: "blueLives") as! SKLabelNode
        loseAreaRed = childNode(withName: "loseAreaRed") as! SKSpriteNode
        loseAreaBlue = childNode(withName: "loseAreaBlue") as! SKSpriteNode
        homeButton = childNode(withName: "homeButton") as! MSButtonNode
        multiplayerStart = childNode(withName: "multiplayerStart") as! MSButtonNode
        multiplayerRestart = childNode(withName: "multiplayerRestart") as! MSButtonNode
        self.physicsWorld.speed = globalSpeed
        self.addChild(worldNode)
        self.view?.isMultipleTouchEnabled = true
        rightWall = childNode(withName: "rightWall") as! SKSpriteNode
        leftWall = childNode(withName: "leftWall") as! SKSpriteNode
        leftWall.physicsBody?.restitution = 1
        rightWall.physicsBody?.restitution = 1
        leftWall.physicsBody?.linearDamping = 0.2
        rightWall.physicsBody?.linearDamping = 0.2
        physicsWorld.contactDelegate = self
        trail?.physicsBody?.affectedByGravity = false
        trail?.targetNode = scene
        multiplayerRestart.isHidden = true
        
        
        multiplayerRestart.selectedHandler = {  [unowned self] in
            self.restart()
            
        }
        
        //start button that hides itself and starts off by spawning two balls
        multiplayerStart.selectedHandler = {  [unowned self] in
            self.multiplayerStart.isHidden = true
            self.state = .play
            self.addBalls()
        }
        
        homeButton.selectedHandler = {  [unowned self] in
            
            
            let reveal = SKTransition.push(with: SKTransitionDirection.left, duration: 0.25)
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                if let scene = GameScene(fileNamed: "GameScene.sks"){
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
    
    
    //touches began method that acts like the other touches began method except it tracks whether the touch occurs in the bottom or top half of the screen and colors the platforms accordingly
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .play {
            for touch in touches {
                let location = touch.location(in: self)
                if location.y < 0 {
                    blueLineStart = location
                    blueTouch = touch
                    blueStart = true
                }else {
                    
                    redLineStart = location
                    redTouch = touch
                    redStart = true
                    
                }
                for plat in platforms {
                    if plat.strokeColor == .red && redStart {
                        plat.removeFromParent()
                    }else if plat.strokeColor == .blue && blueStart{
                        plat.removeFromParent()
                    }
                }
            }
        }
    }
    
    //works the same way assuming that the line has started
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .play {
            
            
            //boolean to determine whether touches began has occurred when a blue line has been drawn
            if blueStart {
                bluePreviewLine?.removeFromParent()
                let blueLocation = blueTouch?.location(in: self)
                bluePreviewEnd = blueLocation
                var blueLineArray: [CGPoint] = [blueLineStart!, blueLocation!]
                bluePreviewLine = SKShapeNode(points: &blueLineArray, count: 2)
                
                //colors the preview line
                bluePreviewLine?.strokeColor = .blue
                bluePreviewLine?.alpha = 0.4  //sets the alpha to a lower value to emphasize the previewness of the line
                bluePreviewLine?.lineCap = .round
                bluePreviewLine?.glowWidth = 1
                //maintains that the line stays on the right half of the scren
                if calcDistance(blueLineStart!, blueLocation!) > minLength && blueLocation!.y < 0 {
                    addChild(bluePreviewLine!)
                }else {
                    //also deletes itself assuming the if statement is not true
                    bluePreviewLine = nil
                }
            }
            if redStart {
                redPreviewLine?.removeFromParent()
                let redLocation = redTouch?.location(in: self)
                redPreviewEnd = redLocation
                var redLineArray: [CGPoint] = [redLineStart!, redLocation!]
                redPreviewLine = SKShapeNode(points: &redLineArray, count: 2)
                redPreviewLine?.strokeColor = .red
                redPreviewLine?.alpha = 0.4
                redPreviewLine?.lineCap = .round
                redPreviewLine?.glowWidth = 1
                if calcDistance(redLineStart!, redLocation!) > minLength && redLocation!.y > 0  {
                    addChild(redPreviewLine!)
                }else {
                    redPreviewLine = nil
                }
            }
            
        }
        
    }
    
    //uses where the finger lifted off to initialize a platform and add it to the arrary then add it to the scene
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //boolean to determine that the touches ended doesn't get called on the incorrect line
        var endFix: Bool = false
        if state == .play {
            
            
            
            //if a new platform is created then turn off all the justContact booleans
            for child in worldNode.children {
                if child.name == "ball" {
                    let ball = child as! Ball
                    ball.justContact = false
                    ball.readyToBounce = false
                }
            }
            
            if blueStart && bluePreviewLine != nil {
                for touch in touches {
                    //if the touch hasn't occurred on the blue side then don't change endfix to true
                    if touch.location(in: self).y < 0.0 {
                        endFix = true
                    }
                }
                if endFix{
                    blueLineEnd = blueTouch?.location(in: self)
                    if calcDistance(blueLineStart!, blueLineEnd!) > minLength {
                        let blueDrawLine = Platform(blueLineStart!,blueLineEnd!,.blue)
                        blueDrawLine.defaultLimit = 1 //changes the lifetime of the platform to one
                        platforms.append(blueDrawLine)
                        worldNode.addChild(blueDrawLine)
                        
                        
                        //nil all of the other variables
                        blueLineStart = nil
                        blueLineEnd = nil
                        blueStart = false
                        blueDrawLine.strokeColor = .blue
                        bluePreviewLine?.removeFromParent()
                        
                        //reset the boolean
                        endFix = false
                    }
                }
            }
            
            if redStart && redPreviewLine != nil {
                for touch in touches {
                    if touch.location(in: self).y > 0.0 {
                        endFix = true
                    }
                }
                if endFix {
                    redLineEnd = redTouch?.location(in: self)
                    if calcDistance(redLineStart!, redLineEnd!) > minLength {
                        let redDrawLine = Platform(redLineStart!,redLineEnd!,.red,64)
                        redDrawLine.defaultLimit = 1
                        platforms.append(redDrawLine)
                        worldNode.addChild(redDrawLine)
                        redLineStart = nil
                        redLineEnd = nil
                        redStart = false
                        redDrawLine.strokeColor = .red
                        redPreviewLine?.removeFromParent()
                        endFix = false
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //updates the lives counter for each side constantly
        blueLives.text = String(blueLivesNum)
        redLives.text = String(redLivesNum)
        
        
        if state == .play {
            //add a ball every 3 seconds
            ballTimer += fixedDelta
            
            if ballTimer > 3 {
                addBalls()
                ballTimer = 0
            }
        }
        
        //if the lives of either side equals zero then run the game over method
        if blueLivesNum == 0 || redLivesNum == 0 {
            gameOver()
        }
        
        //if a ball is sent off screen then decrement the lives counter for the respective side (does this mean I don't need the lose area?) Note: the reason I did this was because of corner collisions and removing the object would cause the game to crash since the physics body didn't exist anymore
        for child in worldNode.children {
            if child.name == "ball" {
                
                if child.position.y > 350 {
                    child.removeFromParent()
                    redLivesNum -= 1
                }else if child.position.y < -350 {
                    child.removeFromParent()
                    blueLivesNum -= 1
                }
                
                //sets the terminal velocity of each ball in the event that the balls exceed the terminal velocity
                if (child.physicsBody?.velocity.dy)! > terminalVelocity {
                    child.physicsBody?.velocity.dy = terminalVelocity
                }
                
                if (child.physicsBody?.velocity.dy)! < -terminalVelocity {
                    child.physicsBody?.velocity.dy = -terminalVelocity
                }
                
                //depending on the color of each ball, change the field mask such that it is affected by different gravitational fields
                let ball = child as! Ball
                if ball.color == .red {
                    ball.physicsBody?.fieldBitMask = 1
                }else {
                    ball.physicsBody?.fieldBitMask = 2
                }
            }
        }
        
        //update the platforms so they despawn
        for platform in platforms {
            platform.update()
        }
        
        //BLAHHHHHHH these lines of code determine whether the balls can pass through each platform depending on the direction so that they make fucking sense
        for child in worldNode.children {
            if(child.name == "ball") {
                let ballBody = child as! Ball
                if (child.physicsBody?.velocity.dy)! < CGFloat(0.0) && ballBody.color == .blue || ballBody.justContact == true { //blue balls
                    child.physicsBody?.collisionBitMask = 14
                    child.physicsBody?.contactTestBitMask = 28
                    let ball = child as! Ball
                    ball.readyToBounce = true
                }else if(child.physicsBody?.velocity.dy)! > CGFloat(0.0) && ballBody.color == .red || ballBody.justContact == true{ //red balls
                    child.physicsBody?.collisionBitMask = 68
                    child.physicsBody?.contactTestBitMask = 84
                    let ball = child as! Ball
                    ball.readyToBounce = true
                }else {
                    child.physicsBody?.collisionBitMask = 4
                    child.physicsBody?.contactTestBitMask = 0
                    let ball = child as! Ball
                    ball.readyToBounce = false
                }
            }
        }
    }
    
    
    //method to add balls equally into the scene, basically the same as the other add Ball method but I doubled it
    func addBalls() {
        
        //initializes two balls of different colors
        let redBall = Ball()
        let blueBall = Ball()
        redBall.color = .red
        blueBall.color = .blue
        
        //decides which side the balls should be on, the balls will always spawn on opposite sides with the mirrored velocity
        let decider = arc4random_uniform(2)
        let initialVelocity = Int(arc4random_uniform(100) + 100)
        trail?.physicsBody?.affectedByGravity = false
        trail?.targetNode = scene
        let redTrail = trail?.copy() as! SKEmitterNode
        redTrail.name = "trail"
        redTrail.particleColor = .red
        let blueTrail = trail?.copy() as! SKEmitterNode
        blueTrail.name = "trail"
        blueTrail.particleColor = .blue
        switch decider {
            
        case 0:
            
            redBall.position.x = 150
            redBall.position.y = -350
            redBall.physicsBody?.restitution = restitution
            redBall.addChild(redTrail)
            worldNode.addChild(redBall)
            redBall.physicsBody!.applyImpulse(CGVector(dx: -100, dy: initialVelocity))
            redBall.zPosition = zIncrement
            zIncrement += 1
            
            blueBall.position.x = -150
            blueBall.position.y = 350
            blueBall.physicsBody?.restitution = restitution
            blueBall.addChild(blueTrail)
            worldNode.addChild(blueBall)
            blueBall.physicsBody!.applyImpulse(CGVector(dx: 100, dy: -initialVelocity))
            blueBall.zPosition = zIncrement
            zIncrement += 1
            
        case 1:
            
            redBall.position.x = -150
            redBall.position.y = -350
            redBall.physicsBody?.restitution = restitution
            redBall.addChild(redTrail)
            worldNode.addChild(redBall)
            redBall.physicsBody!.applyImpulse(CGVector(dx: 100, dy: initialVelocity))
            redBall.zPosition = zIncrement
            zIncrement += 1
            
            blueBall.position.x = 150
            blueBall.position.y = 350
            blueBall.physicsBody?.restitution = restitution
            blueBall.addChild(blueTrail)
            worldNode.addChild(blueBall)
            blueBall.physicsBody!.applyImpulse(CGVector(dx: -100, dy: -initialVelocity))
            blueBall.zPosition = zIncrement
            zIncrement += 1
            
        default:
            worldNode.addChild(redBall)
        }
        
        
        
    }
    
    
    //DID FUCKING BEGINNNNNNNNN
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        let maxScalar: CGFloat = 0.5
        var direction = 1
        
        
        //used to determine the position/placement of the particle effect
        let position = contact.contactPoint
        
        if nodeA.name == "platform" && nodeB.name == "ball" {
            let plat = nodeA as! SKShapeNode
            let ball = nodeB as! Ball
            if plat.strokeColor == ball.color {
                if ball.color == .red {
                    direction = -1
                }
                if ball.readyToBounce == true {
                    ball.glitchTimer = 0
                    var force: CGFloat! = 0
                    for platform in platforms {
                        if nodeA.position == platform.position {
                            force = platform.forceScalar
                            
                            let emitter2 = emitter?.copy() as! SKEmitterNode
                            platform.addChild(emitter2)
                            emitter2.particleBirthRate = (emitter?.particleBirthRate)! * force
                            emitter2.particleScale = (emitter?.particleScale)! * force * 0.2
                            emitter2.position = position
                            emitter2.particleColor = platform.strokeColor
                            emitter2.run(SKAction.fadeOut(withDuration: 0.1))
                        }
                    }
                    run(hitSound)
                    //nodeB.physicsBody?.velocity.dy = 0
                    if force > 0.8 {
                        nodeB.physicsBody?.applyImpulse(scale(CGVector(dx: 0, dy: Int(platformBounce) * direction), maxScalar * force))
                    }
                    
                    //flips the color of the ball so that they switch gravitational fields after each contact (Note: it's really fucking wonky sometimes so the pacing is weird)
                    if ball.color == .red {
                        flipTrailColor(ball)
                        ball.color = .blue
                        
                    }else {
                        flipTrailColor(ball)
                        ball.color = .red
                        
                    }
                    
                }
                
            }
            
        }
        if nodeB.name == "platform" && nodeA.name == "ball" {
            
            let plat = nodeB as! SKShapeNode
            let ball = nodeA as! Ball
            
            if plat.strokeColor == ball.color {
                if ball.color == .red {
                    direction = -1
                }
                if ball.readyToBounce == true  {
                    ball.glitchTimer = 0
                    var force: CGFloat! = 0
                    for platform in platforms {
                        if nodeB.position == platform.position {
                            force = platform.forceScalar
                            let emitter2 = emitter?.copy() as! SKEmitterNode
                            platform.addChild(emitter2)
                            emitter2.particleBirthRate = (emitter?.particleBirthRate)! * force
                            emitter2.particleScale = (emitter?.particleScale)! * force * 0.2
                            emitter2.position = position
                            emitter2.particleColor = platform.strokeColor
                            emitter2.run(SKAction.fadeOut(withDuration: 0.1))
                        }
                    }
                    run(hitSound)
                    if force > 0.8 {
                        nodeA.physicsBody?.applyImpulse(scale(CGVector(dx: 0, dy: Int(platformBounce) * direction), maxScalar * force))
                    }
                    print(platformBounce * maxScalar * force)
                    if ball.color == .red {
                        flipTrailColor(ball)
                        ball.color = .blue
                        
                    }else {
                        flipTrailColor(ball)
                        ball.color = .red
                        
                    }
                    
                    
                }
                
                
                
            }
        }
        
        
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
        
        
        //this following code might end up being completely useless since I delete the ball in the previous code
        
        if nodeA.name == "loseAreaBlue" && nodeB.name == "ball" {
            blueLivesNum -= 1
            nodeB.removeFromParent()
        }
        if nodeA.name == "ball" && nodeB.name == "loseAreaBlue" {
            blueLivesNum -= 1
            nodeA.removeFromParent()
        }
        if nodeA.name == "loseAreaRed" && nodeB.name == "ball" {
            redLivesNum -= 1
            nodeB.removeFromParent()
        }
        if nodeA.name == "ball" && nodeB.name == "loseAreaRed" {
            redLivesNum -= 1
            nodeA.removeFromParent()
        }
        
    }
    
    //flips the current ball and the color of the trail
    
    func flipTrailColor(_ ball: Ball) {
        
        ball.removeAllChildren()
        if ball.color == .red {
            let blueTrail = trail?.copy() as! SKEmitterNode
            blueTrail.particleColor = .blue
            ball.addChild(blueTrail)
            
        }else {
            
            let redTrail = trail?.copy() as! SKEmitterNode
            redTrail.particleColor = .red
            ball.addChild(redTrail)
            
            
        }
    }
    
    
    //fchanges the game state, restart button is unhidden, removes all of the balls, and properly positions the win text depending on who won
    func gameOver() {
        if state != .gameOver {
            state = .gameOver
            
            multiplayerRestart.isHidden = false
            
            
            for child in worldNode.children {
                if child.name == "ball" {
                    child.removeFromParent()
                }
            }
            let winText = SKLabelNode(fontNamed:"Exo2-ExtraLight")
            winText.text = "YOU WIN!"
            winText.name = "winText"
            winText.fontSize = 50
            if blueLivesNum > redLivesNum {
                winText.position = CGPoint(x: 0, y: -160)
                
                
            } else {
                
                winText.position = CGPoint(x:0,y:160)
                winText.xScale = -1
                winText.yScale = -1
            }
            addChild(winText)
        }
    }
    
    //removes the win text, hides and unhides the appropriate buttons and restarts the life counter
    func restart() {
        childNode(withName: "winText")?.removeFromParent()
        multiplayerRestart.isHidden = true
        multiplayerStart.isHidden = false
        ballTimer = 0
        state = .ready
        redLivesNum = 10
        blueLivesNum = 10
        
    }
    
}

