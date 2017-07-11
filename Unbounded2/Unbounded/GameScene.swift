//
//  GameScene.swift
//  Unbounded
//
//  Created by Paxon Yu on 6/26/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import SpriteKit
import GameplayKit

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
    
    let worldNode = SKNode()
    
    var gameStarted: Bool = false
    var targetFound: Bool = false
    var rightWall: SKSpriteNode!
    var leftWall: SKSpriteNode!
    var ground: SKSpriteNode!
    var state: GameState = .play
    var scoreLabel: SKLabelNode!
    var lineStart: CGPoint?
    var lineEnd: CGPoint?
    var loseArea: SKSpriteNode!
    var highscoreNum: SKLabelNode!
    var loseCamera: SKCameraNode!
    var cameraTarget: SKSpriteNode?
    var previewLine: SKShapeNode?
    var previewEnd: CGPoint?
    var resetButton: MSButtonNode!
    var pauseButton: SKSpriteNode!
    var pauseButtonNode: MSButtonNode!
    let scoreDefault = UserDefaults.standard
    var bounds: SKSpriteNode!
    let ball = Ball()
    
    //minimum length of a platform allowed
    let minLength: CGFloat =  20
    
    //array used to store the platforms (note: only stores the information for convenient access)
    var platforms: [Platform] = []
    
    //Timer used to determine how often a ball gets added
    var ballTimer: CFTimeInterval = 0
    
    //used to add each ball to a different z Position
    var zIncrement:CGFloat = 1
    
    //first ball (note: use this for tutorial purposes)
    var firstBall: SKSpriteNode!
    
    //determines the intensity of richochet off of the left and right wall
    let wallBounce = 10
    var score = 0
    var highscore = 0
    
    var hitSound = SKAction.playSoundFileNamed("HitSound.wav", waitForCompletion: false)
    let trail = SKEmitterNode(fileNamed: "Trail.sks")
    
    
    //initializes all of the nodes and sets the physical properties of the left and right wall
    override func didMove(to view: SKView) {
        
        self.addChild(worldNode)
        pauseButton = childNode(withName: "pauseButton") as! SKSpriteNode
        pauseButtonNode = childNode(withName: "pauseButtonNode") as! MSButtonNode
        bounds = childNode(withName: "bounds") as! SKSpriteNode
        resetButton = childNode(withName: "resetButton") as! MSButtonNode
        highscoreNum = childNode(withName: "highscoreNum") as! SKLabelNode
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
        ball.addChild(trail?.copy() as! SKEmitterNode)
        ball.position = CGPoint(x: 1.81, y: 136.6)
        ball.physicsBody?.isDynamic = false
        worldNode.addChild(ball)
        highscoreNum.text = String(highscore)
        resetButton.alpha = 0
        
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
            
            //to address any bugs where the score isn't set to zero when the lose screen begins
            self.score = 0
            
        }
        
    }
    
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
                let ball = child as! Ball
                ball.justContact = false
                ball.readyToBounce = false
            }
            previewLine?.removeFromParent()
            let touch = touches.first!
            let location = touch.location(in:self)
            lineEnd = location
            if calcDistance(lineStart!, location) > minLength {
                let drawLine = Platform(lineStart!,lineEnd!)
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
    
    //used to maintain the one platform limit, update the platforms, remove them from the array, and increment timers. Also it's used to modify each balls physics masks in order to ensure that the balls pass through platforms on the bottom but make contact at the top
    override func update(_ currentTime: TimeInterval) {
        
        highscoreNum.text = String(highscore)
        moveCamera()
        
        if state == .play {
            
            //limits the vertical velocity downwards
            for ball in worldNode.children {
                if ball.name == "ball" {
                    let ballBody = ball as! Ball
                    ballBody.glitchTimer += fixedDelta
                    if (ball.physicsBody?.velocity.dy)! <  -CGFloat(300){
                        ball.physicsBody?.velocity.dy = -300
                    }
                }
            }
            //only permits that one platform exists at any given point in time
            scoreLabel.text = String(score)
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
        let decider = arc4random_uniform(2)
        
        trail?.physicsBody?.affectedByGravity = false
        trail?.targetNode = scene
        switch decider {
        case 0:
            
            newBall.position.x = 150
            newBall.position.y = -350
            newBall.addChild(trail?.copy() as! SKEmitterNode)
            worldNode.addChild(newBall)
            newBall.physicsBody!.applyImpulse(CGVector(dx: -100, dy: 300))
            newBall.zPosition = zIncrement
            zIncrement += 1
            
        case 1:
            
            newBall.position.x = -150
            newBall.position.y = -350
            newBall.addChild(trail?.copy() as! SKEmitterNode)
            worldNode.addChild(newBall)
            newBall.physicsBody!.applyImpulse(CGVector(dx: 100, dy: 300))
            newBall.zPosition = zIncrement
            zIncrement += 1
            
        default:
            worldNode.addChild(newBall)
        }
        
        
    }
    
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
                        let emitter = SKEmitterNode(fileNamed: "Impact.sks")
                        platform.addChild(emitter!)
                        emitter?.particleBirthRate = (emitter?.particleBirthRate)! * force
                        emitter?.particleScale = (emitter?.particleScale)! * force * 0.2
                        emitter?.position = position
                        emitter?.run(SKAction.fadeOut(withDuration: 0.1))
                    }
                }
                run(hitSound)
                nodeB.physicsBody?.applyImpulse(scale(CGVector(dx: 0, dy: 500), maxScalar * force))
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
                        let emitter = SKEmitterNode(fileNamed: "Impact.sks")
                        platform.addChild(emitter!)
                        emitter?.particleBirthRate = (emitter?.particleBirthRate)! * force
                        emitter?.particleScale = (emitter?.particleScale)! * force * 0.2
                        emitter?.position = position
                        emitter?.run(SKAction.fadeOut(withDuration: 0.1))
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
            score = 0
            
            if !targetFound {
                cameraTarget = nodeB as? SKSpriteNode
                targetFound = true
            }
            state = .gameOver
            resetButton.isUserInteractionEnabled = false
            resetButton.run(SKAction.fadeIn(withDuration: 1.5))
            resetButton.isUserInteractionEnabled = true
            nodeB.physicsBody?.restitution = 0.7
        }
        if nodeA.name == "ball" && nodeB.name == "loseArea" {
            calcHighscore()
            nodeA.physicsBody?.categoryBitMask = 2
            score = 0
            if !targetFound {
                cameraTarget = nodeA as? SKSpriteNode
                targetFound = true
                
            }
            state = .gameOver
            resetButton.isUserInteractionEnabled = false
            resetButton.run(SKAction.fadeIn(withDuration: 1.0))
            resetButton.isUserInteractionEnabled = true
            nodeA.physicsBody?.restitution = 0.7
        }
        
        if nodeA.name == "bounds" || nodeB.name == "bounds" {
            print("we lost one")
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
    
    
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        
        let targetY = cameraTarget.position.y
        let y = clamp(value: targetY, lower: -590, upper: 7)
        loseCamera.run(SKAction.moveTo(y: y, duration: 0.3))
    }
    
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
        resetButton.run(SKAction.fadeOut(withDuration: 0.3))
        state = .play
        
    }
    
    
    func resetCamera() {
        let cameraReset = SKAction.move(to: CGPoint(x:0, y:0), duration: 1.0)
        let cameraDelay = SKAction.wait(forDuration: 0.5)
        let cameraSequence = SKAction.sequence([cameraDelay, cameraReset])
        loseCamera.run(cameraSequence)
        targetFound = false
        cameraTarget = nil
    }
    
    func numberOfBalls() -> Int {
        var number = 0
        for child in worldNode.children {
            if child.name == "ball" {
                number += 1
            }
        }
        return number
    }
}

