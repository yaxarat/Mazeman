//
//  GameScene.swift
//  MazeMan
//
//  Created by Yashar Atajan on 4/11/18.
//  Copyright © 2018 Yaxiaer Atajiang. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var maze = PlaceBlock()
    var allTimers = [Timer]()
    var itemArray: [[SKSpriteNode]]!
    var blockCreationTimer = 0, addRockTimer = 0, reviveTimer = 0
    var rockCount, starCount, heartCount, energyCount: Int!

    // Labels
    let starCountLabel  = SKLabelNode(fontNamed: "Avenir")
    let rockCountLabel = SKLabelNode(fontNamed: "Avenir")
    let heartCountLabel = SKLabelNode(fontNamed: "Avenir")
    let energyCountLabel = SKLabelNode(fontNamed: "Avenir")
    let statusBarLabel = SKLabelNode(fontNamed: "Avenir")
    // Elements
    let character = SKSpriteNode(imageNamed: "app-icon")
    let dino1 = SKSpriteNode(imageNamed: "dino1")
    let dino2 = SKSpriteNode(imageNamed: "dino2")
    let dino3 = SKSpriteNode(imageNamed: "dino3")
    let dino4 = SKSpriteNode(imageNamed: "dino4")
    // Sounds
    let throwSound = SKAction.playSoundFileNamed("throw.wav", waitForCompletion:false)
    let eatSound = SKAction.playSoundFileNamed("eat.wav", waitForCompletion:false)
    let deathSound = SKAction.playSoundFileNamed("death.wav", waitForCompletion:false)
    let starSound = SKAction.playSoundFileNamed("star.wav", waitForCompletion:false)
    let hurtSound = SKAction.playSoundFileNamed("bite.wav", waitForCompletion:false)
    let fireHurtSound = SKAction.playSoundFileNamed("fire.wav", waitForCompletion:false)
    let enemyDeathSound = SKAction.playSoundFileNamed("dino.wav", waitForCompletion:false)

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        initAll()

        setInitialCharacterLoc()
        addFood()
        addStar()
        addDino1()
        addDino2()
        addDino3()
        addDino4()
        bottomCornerStats()
        addGestures()
        makeStatusBar()
    }

    override func update(_ currentTime: TimeInterval) {}

    func initAll() {
        maze = PlaceBlock()
        initTimeAndCount()
        initItemArray()
        startTimers()
        initLabel()
        initBg()
        initBoundsAndPonds()
    }

    func initTimeAndCount() {
        allTimers = [Timer]()
        blockCreationTimer = 0
        addRockTimer = 0
        reviveTimer = 0
        starCount = 0
        rockCount = 10
        heartCount = 3
        energyCount = 100
    }

    func initItemArray() {
        itemArray = [[SKSpriteNode]]()
        for i in 0..<maze.blockArray.count {
            let newRow = [SKSpriteNode](repeatElement(SKSpriteNode(), count: maze.blockArray[i].count))
            itemArray.append(newRow)
        }
    }

    func initLabel() {
        starCountLabel.fontSize = 30
        rockCountLabel.fontSize = 30
        heartCountLabel.fontSize = 30
        energyCountLabel.fontSize = 30
        statusBarLabel.fontSize = 30

        starCountLabel.fontColor = SKColor.black
        rockCountLabel.fontColor = SKColor.black
        heartCountLabel.fontColor = SKColor.black
        energyCountLabel.fontColor = SKColor.black
        statusBarLabel.fontColor = SKColor.white

        starCountLabel.text = String(starCount)
        rockCountLabel.text = String(rockCount)
        heartCountLabel.text = String(heartCount)
        energyCountLabel.text = String(energyCount)
        statusBarLabel.text = "Survive the MazeMan"
    }

    func startTimers() {
        // For block
        let blockCreationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addRandomBlock(sender:)), userInfo: nil, repeats: true)
        allTimers.append(blockCreationTimer)
        // TODO: COMMENT THESE
        let getRocksTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addRocks(sender:)), userInfo: nil, repeats: true)
        allTimers.append(getRocksTimer)
        //
        let drainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(drainEnergy(sender:)), userInfo: nil, repeats: true)
        allTimers.append(drainTimer)
        //
        let timer1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dino1Moves(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer1)
        //
        let timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dino2Moves(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer2)
        //
        let timer3 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dino3Moves(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer3)
        //
        let timer4 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dino4Moves(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer4)
        //
        let timerfire = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(throwFire(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timerfire)
        //
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(respawn(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer)
    }

    func initBg() {
        let background = SKSpriteNode(imageNamed: "bg")
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = self.size
        addChild(background)
    }

    func initBoundsAndPonds() {
        let boundTop = SKSpriteNode()
        let boundBottom = SKSpriteNode()
        let boundLeft = SKSpriteNode()
        let boundRight = SKSpriteNode()

        boundTop.position = CGPoint(x: self.frame.width/2, y: 896)
        boundTop.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height:1))
        addChild(boundTop)
        boundTop.physicsBody?.isDynamic = false

        boundBottom.position = CGPoint(x: self.frame.width/2, y: 63)
        boundBottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 512, height:1))
        addChild(boundBottom)
        boundBottom.physicsBody?.isDynamic = false

        boundLeft.position = CGPoint(x: 0, y:self.frame.height/2)
        boundLeft.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height:self.frame.height))
        addChild(boundLeft)
        boundLeft.physicsBody?.isDynamic = false

        boundRight.position = CGPoint(x: 1344, y:self.frame.height/2)
        boundRight.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height:self.frame.height))
        addChild(boundRight)
        boundRight.physicsBody?.isDynamic = false

        createCollisionBitmasks(item: "border" , node: boundTop)
        createCollisionBitmasks(item: "border" , node: boundBottom)
        createCollisionBitmasks(item: "border" , node: boundLeft)
        createCollisionBitmasks(item: "border" , node: boundRight)

        makeBoundary(yCoordinate: CGFloat(64 / 2))
        makeBoundary(yCoordinate: CGFloat(1024 - 64 / 2))
        makeBoundary(yCoordinate: CGFloat((1024 - 64 / 2)) - 64)

        addNewItem(item: "water", x: 6, y: -1)
        addNewItem(item: "water", x: 16, y: -1)
    }

    func makeBoundary(yCoordinate: CGFloat) {
        for i in 0...21 {
            let singleBlock = SKSpriteNode(imageNamed: "block")
            singleBlock.size = CGSize(width: 64, height: 64)
            singleBlock.position = CGPoint(x:singleBlock.frame.size.width/2 + CGFloat(64*i), y: yCoordinate)
            self.addChild(singleBlock)

        }
    }

    func makeStatusBar() {
        let status = SKSpriteNode(imageNamed:"game-status-panel")
        status.position = CGPoint(x:self.frame.size.width/2, y: 980)
        status.size = CGSize(width: 500, height: 100)
        addChild(status)

        statusBarLabel.position.x = status.position.x
        statusBarLabel.position.y = status.position.y - 13
        addChild(statusBarLabel)
    }

    func bottomCornerStats() {
        var image = ""
        var label: SKLabelNode!
        for i in 0...3 {
            switch i {
            case 0:
                image = "star"
                label = starCountLabel
            case 1:
                image = "rock"
                label = rockCountLabel
            case 2:
                image = "heart"
                label = heartCountLabel
            case 3:
                image = "battery"
                label = energyCountLabel
            default:
                break
            }
            let object = SKSpriteNode(imageNamed: "\(image)")
            if image == "battery" {
                object.size = CGSize(width: 100, height: 100)
            } else {
                object.size = CGSize(width: 64, height: 64)
            }
            object.position = CGPoint(x:object.frame.size.width/2 + CGFloat(64*i), y: 32)
            label.position.x = object.position.x
            label.position.y = 20
            self.addChild(object)
            self.addChild(label)
        }
    }

    func updateLabelCounts() {
        starCountLabel.text = String(starCount)
        rockCountLabel.text = String(rockCount)
        heartCountLabel.text = String(heartCount)
        energyCountLabel.text = String(energyCount)
    }

    func setInitialCharacterLoc(){
        character.size = CGSize(width: 64, height: 64)
        character.position = CGPoint(x:character.frame.size.width/2, y: character.frame.size.height/2 + (64))
        character.physicsBody = SKPhysicsBody(rectangleOf: character.size, center: character.anchorPoint)
        addChild(character)
        character.physicsBody?.isDynamic = true
        character.physicsBody?.affectedByGravity = false
        character.physicsBody?.allowsRotation = false

        createCollisionBitmasks(item: "character", node: character)

        maze.blockArray[0][0].hasBeenTaken = true
    }

    func addDino1(){
        let waterSpawn = Int(arc4random_uniform(2))
        var xPos: CGFloat = 0
        dino1.size = CGSize(width: 64, height: 64)
        if waterSpawn == 0 {
            xPos = dino1.frame.size.width/2 + (64*8)
        } else {
            xPos = dino1.frame.size.width/2 + (64*13)
        }
        dino1.position = CGPoint(x: xPos, y: dino1.frame.size.height/2 + 64)
        dino1.physicsBody = SKPhysicsBody(rectangleOf: dino1.size, center: dino1.anchorPoint)
        dino1.name = "dino1"
        addChild(dino1)
        dino1.physicsBody?.affectedByGravity = false
        dino1.physicsBody?.allowsRotation = false
        createCollisionBitmasks(item: "dino1", node: dino1)

    }

    func addDino2(){

        let spawn = CGFloat(arc4random_uniform(13))
        dino2.size = CGSize(width: 64, height: 64)
        print (spawn)

        dino2.position = CGPoint(x: dino2.frame.size.width/2 + (64*20), y: dino2.frame.size.height/2 + (64 + 64*spawn))
        dino2.physicsBody = SKPhysicsBody(rectangleOf: dino2.size, center: dino2.anchorPoint)
        dino2.name = "dino2"
        addChild(dino2)
        dino2.physicsBody?.affectedByGravity = false
        dino2.physicsBody?.allowsRotation = false
        createCollisionBitmasks(item: "dino2", node: dino2)

    }

    func addDino3(){

        dino3.size = CGSize(width: 64, height: 64)


        dino3.position = CGPoint(x: dino3.frame.size.width/2+10, y: dino3.frame.size.height/2 + (64*13-10))
        dino3.physicsBody = SKPhysicsBody(rectangleOf: dino3.size, center: dino3.anchorPoint)
        dino3.name = "dino3"
        addChild(dino3)
        dino3.physicsBody?.affectedByGravity = false
        dino3.physicsBody?.allowsRotation = false
        createCollisionBitmasks(item: "dino3", node: dino3)

    }

    func addDino4(){

        dino4.size = CGSize(width: 64, height: 64)
        dino4.position = CGPoint(x: dino4.frame.size.width/2+10, y: dino4.frame.size.height/2 + (64*13 + 40))
        dino4.name = "dino4"
        addChild(dino4)


    }

    @objc func respawn(sender: Timer) {
        reviveTimer += 1
        if reviveTimer == 5 {
            reviveTimer = 0
            checkForDinos()
        }
    }

    func checkForDinos() {
        if (self.childNode(withName: "dino1") == nil) {
            addDino1()
        }
        if (self.childNode(withName: "dino2") == nil) {
            addDino2()
        }
        if (self.childNode(withName: "dino3") == nil) {
            addDino3()
        }
    }

    @objc func addRandomBlock(sender: Timer) {
        blockCreationTimer += 1

        addItem(itemToBe: "block")

        if blockCreationTimer == 15 {
            sender.invalidate()
        }

    }

    @objc func addRocks(sender: Timer) {
        addRockTimer += 1

        if addRockTimer % 30 == 0 {
            if rockCount <= 10 {
                rockCount! += 10
                updateLabelCounts()
            } else {
                rockCount = 20
                updateLabelCounts()
            }
        }
    }


    func addFood() {
        addItem(itemToBe: "food")
    }

    func addStar() {
        addItem(itemToBe: "star")
    }


    func addItem(itemToBe: String) {
        var randX = Int(arc4random_uniform(20))
        var randY = Int(arc4random_uniform(10))

        if maze.blockArray[randX][randY].hasBeenTaken {
            while maze.blockArray[randX][randY].hasBeenTaken {
                randX = Int(arc4random_uniform(20))
                randY = Int(arc4random_uniform(10))
            }
        }
        addNewItem(item: itemToBe , x: randX, y: randY)

        maze.blockArray[randX][randY].hasBeenTaken = true
    }


    func addNewItem(item: String, x: Int, y: Int) {

        let object = SKSpriteNode(imageNamed: item)

        if item == "water" {
            object.size = CGSize(width:64, height:60)
        } else {
            object.size = CGSize(width:64, height:64)
        }
        object.position = CGPoint(x:object.frame.size.width/2 + CGFloat(64*x), y: object.frame.size.width/2 + CGFloat(64*(y+1)))
        object.physicsBody = SKPhysicsBody(rectangleOf: object.size, center: object.anchorPoint)
        self.addChild(object)
        object.physicsBody?.isDynamic = false

        if ((x >= 0 && x <= maze.blockArray.count) && (y >= 0 && y <= maze.blockArray.count)){
            maze.blockArray[x][y].id = item
            itemArray[x][y] = object
        }

        createCollisionBitmasks(item: item, node: object)
    }

    func addGestures() {
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe(sender:)))
            swipe.direction = direction
            self.view?.addGestureRecognizer(swipe)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(throwRock(sender:)))
        self.view?.addGestureRecognizer(tap)
    }

    @objc func throwRock(sender: UITapGestureRecognizer) {
        if rockCount > 0 {
            var location = sender.location(in: sender.view)
            location = self.convertPoint(fromView: location)
            print (location)

            let rock = SKSpriteNode(imageNamed:"rock")

            rock.position = character.position

            rock.size = CGSize(width: 40, height: 40)
            rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
            self.addChild(rock)

            rock.physicsBody?.affectedByGravity = false

            createCollisionBitmasks(item: "rock", node: rock)

            var dx = CGFloat(location.x - character.position.x)
            var dy = CGFloat(location.y - character.position.y)

            let magnitude = sqrt(dx * dx + dy * dy)

            dx /= magnitude
            dy /= magnitude

            let vector = CGVector(dx: 50 * dx, dy: 50 * dy)

            rock.physicsBody?.applyImpulse(vector)
            rockCount! -= 1
            updateLabelCounts()
            run(throwSound)
        }



    }

    @objc func throwFire(sender: Timer) {

        let fire = SKSpriteNode(imageNamed: "fire")
        fire.position = dino4.position

        fire.size = CGSize(width: 40, height: 40)
        fire.physicsBody = SKPhysicsBody(rectangleOf: fire.size)
        self.addChild(fire)

        fire.physicsBody?.affectedByGravity = false

        createCollisionBitmasks(item: "fire", node: fire)


        let shoot: SKAction = SKAction.moveBy(x: dino1.anchorPoint.x, y: -1000, duration: 10)
        fire.run(shoot)
    }

    @objc func respondToSwipe(sender: UISwipeGestureRecognizer) {
        let currentX = character.anchorPoint.x
        let currentY = character.anchorPoint.y

        switch sender.direction {
        case UISwipeGestureRecognizerDirection.left:
            if character.position.x > 64 {
                moveCharacter(xCoordinate: -1302, yCoordinate: currentY)
            }
        case UISwipeGestureRecognizerDirection.right:
            if character.position.x < 1290 {
                moveCharacter(xCoordinate: 1302, yCoordinate: currentY)
            }
        case UISwipeGestureRecognizerDirection.up:
            if character.position.y < 800 {
                moveCharacter(xCoordinate: currentX, yCoordinate: 864)
            }
        case UISwipeGestureRecognizerDirection.down:
            if character.position.y > 64 {
                moveCharacter(xCoordinate: currentX, yCoordinate: -864)
            }
        default:
            break
        }


    }

    func moveCharacter(xCoordinate: CGFloat, yCoordinate: CGFloat) {
        character.removeAction(forKey: "move")
        let move = SKAction.moveBy(x: xCoordinate, y: yCoordinate, duration: 10)
        character.run(move, withKey: "move")
    }

    @objc func dino1Moves(sender: Timer){

        if dino1.action(forKey: "move1") == nil{
            var allActions = [SKAction]()
            let waitTime = Double(arc4random_uniform(3))+1
            let wait = SKAction.wait(forDuration: waitTime)
            let moveUp = SKAction.moveBy(x: 0, y:700, duration: 5)
            let moveDown = SKAction.moveBy(x: 0, y: -700, duration: 5)
            allActions.append(wait)
            allActions.append(moveUp)
            allActions.append(moveDown)
            dino1.run(SKAction.sequence(allActions), withKey: "move1")
        }

    }

    @objc func dino2Moves(sender: Timer){

        if dino2.action(forKey: "move2") == nil{
            var allActions = [SKAction]()

            let waitTime = Double(arc4random_uniform(3))+1
            let wait = SKAction.wait(forDuration: waitTime)

            let moveLeft = SKAction.moveBy(x: -1300, y: 0, duration: 7)
            let flipRight = SKAction.scale(to: CGSize(width: -64, height: 64), duration: 0 )
            let moveRight = SKAction.moveBy(x: 1300, y: 0, duration: 7)
            let flipLeft = SKAction.scale(to: CGSize(width: 64, height: 64), duration: 0 )
            allActions.append(moveLeft)
            allActions.append(flipRight)
            allActions.append(moveRight)
            allActions.append(flipLeft)
            allActions.append(wait)
            dino2.run(SKAction.sequence(allActions), withKey: "move2")
        }

    }

    @objc func dino3Moves(sender: Timer){
        if dino3.action(forKey: "move3") == nil{
            let allActions = dino3MovementLogic()

            dino3.run(SKAction.sequence(allActions), withKey: "move3")
        }

    }


    func dino3MovementLogic() -> [SKAction] {
        var move = [SKAction]()
        var validMove: Bool = false
        while !validMove {
            let sideToSideOrUpDown = Int(arc4random_uniform(2))
            if sideToSideOrUpDown == 0 {
                let leftOrRight = Int(arc4random_uniform(2))
                if leftOrRight == 0 {
                    if dino3.position.x > 100 {
                        let rotateNormal = SKAction.rotate(toAngle: 0, duration: 0)
                        let flipLeft = SKAction.scale(to: CGSize(width: -64, height: 64), duration: 0 )
                        dino3.size.width = -64
                        print(dino3.size.width)
                        let moveLeft = SKAction.moveBy(x: -1340, y: 0, duration: 7)
                        move.append(rotateNormal)
                        move.append(flipLeft)
                        move.append(moveLeft)
                        validMove = true
                    } else if dino3.position.x < 1200{
                        let rotateNormal = SKAction.rotate(toAngle: 0, duration: 0)
                        let flipRight = SKAction.scale(to: CGSize(width: 64, height: 64), duration: 0 )
                        let moveRight = SKAction.moveBy(x: 1340, y: 0, duration: 7)
                        move.append(rotateNormal)
                        move.append(flipRight)
                        move.append(moveRight)
                        validMove = true
                        dino3.size.width = 64
                    }
                }
            } else {
                let upOrDown = Int(arc4random_uniform(2))
                if upOrDown == 0 {
                    if dino3.position.y < 800 {
                        var rotateUp = SKAction()
                        if dino3.size.width == -64 {
                            rotateUp = SKAction.rotate(toAngle: -1.57, duration: 0)
                        } else {
                            rotateUp = SKAction.rotate(toAngle: 1.57, duration: 0)
                        }
                        let moveUp = SKAction.moveBy(x:0, y:1000, duration: 7)
                        move.append(rotateUp)
                        move.append(moveUp)
                        validMove = true
                    }
                } else if dino3.position.y > 100 {
                    var rotateDown = SKAction()
                    if dino3.size.width == -64 {
                        rotateDown = SKAction.rotate(toAngle: 1.57, duration: 0)
                    } else {
                        rotateDown = SKAction.rotate(toAngle: -1.57, duration: 0)
                    }
                    let moveDown = SKAction.moveBy(x:0, y:-1000, duration: 7)
                    move.append(rotateDown)
                    move.append(moveDown)
                    validMove = true
                }
            }
        }
        return move
    }

    @objc func dino4Moves(sender: Timer){

        if dino4.action(forKey: "move4") == nil{
            var allActions = [SKAction]()
            let moveLeft = SKAction.moveBy(x: -1300, y: 0, duration: 10)
            let moveRight = SKAction.moveBy(x: 1300, y: 0, duration: 10)
            allActions.append(moveRight)
            allActions.append(moveLeft)
            dino4.run(SKAction.sequence(allActions), withKey: "move4")
        }

    }

    func createCollisionBitmasks(item: String, node: SKSpriteNode){
        switch item {
        case "block":
            node.physicsBody?.categoryBitMask = ElementNames.Block
            node.physicsBody?.contactTestBitMask = ElementNames.Beast2

        case "food":
            node.physicsBody?.categoryBitMask = ElementNames.Food

        case "star":
            node.physicsBody?.categoryBitMask = ElementNames.Star

        case "rock":
            node.physicsBody?.categoryBitMask = ElementNames.Rock
            node.physicsBody?.collisionBitMask = ElementNames.Rock

        case "character":
            node.physicsBody?.categoryBitMask = ElementNames.Character
            node.physicsBody?.contactTestBitMask = ElementNames.Wall | ElementNames.Block | ElementNames.Food | ElementNames.Star | ElementNames.Beast0
            node.physicsBody?.collisionBitMask = ElementNames.Wall | ElementNames.Block

        case "border":
            node.physicsBody?.categoryBitMask = ElementNames.Wall
            node.physicsBody?.contactTestBitMask = ElementNames.Character | ElementNames.Beast2
            node.physicsBody?.collisionBitMask = ElementNames.Rock | ElementNames.Character | ElementNames.Beast2

        case "water":
            node.physicsBody?.categoryBitMask = ElementNames.Water
            node.physicsBody?.contactTestBitMask = ElementNames.Character

        case "dino1":
            node.physicsBody?.categoryBitMask = ElementNames.Beast0
            node.physicsBody?.contactTestBitMask = ElementNames.Character | ElementNames.Rock | ElementNames.Food
            node.physicsBody?.collisionBitMask = ElementNames.Water | ElementNames.Wall

        case "dino2":
            node.physicsBody?.categoryBitMask = ElementNames.Beast1
            node.physicsBody?.contactTestBitMask = ElementNames.Character | ElementNames.Rock | ElementNames.Food
            node.physicsBody?.collisionBitMask = ElementNames.Wall

        case "dino3":
            node.physicsBody?.categoryBitMask = ElementNames.Beast2
            node.physicsBody?.contactTestBitMask = ElementNames.Character | ElementNames.Rock | ElementNames.Block | ElementNames.Water | ElementNames.Food
            node.physicsBody?.collisionBitMask = ElementNames.Wall | ElementNames.Block | ElementNames.Water

        case "fire":
            node.physicsBody?.categoryBitMask = ElementNames.Fire
            node.physicsBody?.contactTestBitMask = ElementNames.Character
            node.physicsBody?.collisionBitMask =  ElementNames.Fire

        default:
            break
        }
    }

    func addStarScore() {
        starCount! += 1
        updateLabelCounts()
    }

    func addEnergy() {
        if energyCount <= 50 {
            energyCount! += 50
        } else {
            energyCount = 100
        }
        updateLabelCounts()
    }

    func hurtByDino(whichOne: String) {
        switch whichOne{
        case "dino1":
            checkEnergyWhenHurt(damage: 60)
        case "dino2":
            checkEnergyWhenHurt(damage: 80)
        case "dino3":
            checkEnergyWhenHurt(damage: 100)
        case "fire":
            checkEnergyWhenHurt(damage: 100)
        default:
            break
        }
    }

    func checkEnergyWhenHurt(damage: Int) {
        if (damage >= energyCount && heartCount > 0) {
            heartCount! -= 1
            energyCount! += 100
            energyCount! -= damage
        } else if (damage < energyCount) {
            energyCount! -= damage
        } else {
            run(deathSound)
            energyCount = 0
            gameOver()
            print("Game Over")
            invalidateAllTimers()
        }
    }

    @objc func drainEnergy(sender: Timer) {
        energyCount! -= 1
        if energyCount == 0 {
            if heartCount > 0 {
                heartCount! -= 1
                energyCount=100
            } else {
                print("Game Over")
                run(deathSound)
                gameOver()
                sender.invalidate()
                invalidateAllTimers()
            }
        }
        updateLabelCounts()
    }






    func didBegin(_ contact: SKPhysicsContact) {

        //*************character*****************
        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Wall) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Wall){
            print ("Char hit")
            character.removeAction(forKey: "move")

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Block) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Block){
            character.removeAction(forKey: "move")

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Food) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Food){
            run(eatSound)
            addEnergy()
            statusBarLabel.text = "Gained 50 Energy"
            searchAndDestroyItem(item: "food")

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Star) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Star){
            run(starSound)
            searchAndDestroyItem(item: "star")
            addStarScore()
        }

        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Fire) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Fire){
            run(fireHurtSound)
            hurtByDino(whichOne: "fire")
        }

        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Water) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Water){
            invalidateAllTimers()
            run(deathSound)
            gameOver()
        }

        //*******************dino1****************
        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Beast0) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Beast0){
            hurtByDino(whichOne: "dino1")
            run(hurtSound)

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Rock && contact.bodyB.categoryBitMask == ElementNames.Beast0) || (contact.bodyB.categoryBitMask == ElementNames.Rock && contact.bodyA.categoryBitMask == ElementNames.Beast0){
            run(enemyDeathSound)
            dino1.removeFromParent()
            statusBarLabel.text = "dino 1 killed"

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Beast0 && contact.bodyB.categoryBitMask == ElementNames.Food) || (contact.bodyB.categoryBitMask == ElementNames.Beast0 && contact.bodyA.categoryBitMask == ElementNames.Food){
            run(eatSound)
            searchAndDestroyItem(item: "food")

        }

        //***********dino2************

        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Beast1) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Beast1){
            hurtByDino(whichOne: "dino2")
            run(hurtSound)
        }

        if (contact.bodyA.categoryBitMask == ElementNames.Rock && contact.bodyB.categoryBitMask == ElementNames.Beast1) || (contact.bodyB.categoryBitMask == ElementNames.Rock && contact.bodyA.categoryBitMask == ElementNames.Beast1){
            run(enemyDeathSound)
            dino2.removeFromParent()
            statusBarLabel.text = "dino2 killed"

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Beast1 && contact.bodyB.categoryBitMask == ElementNames.Food) || (contact.bodyB.categoryBitMask == ElementNames.Beast1 && contact.bodyA.categoryBitMask == ElementNames.Food){
            run(eatSound)
            searchAndDestroyItem(item: "food")

        }

        //*************dino3************

        if (contact.bodyA.categoryBitMask == ElementNames.Character && contact.bodyB.categoryBitMask == ElementNames.Beast2) || (contact.bodyB.categoryBitMask == ElementNames.Character && contact.bodyA.categoryBitMask == ElementNames.Beast2){
            hurtByDino(whichOne: "dino3")
            run(hurtSound)


        }

        if (contact.bodyA.categoryBitMask == ElementNames.Block && contact.bodyB.categoryBitMask == ElementNames.Beast2) || (contact.bodyB.categoryBitMask == ElementNames.Block && contact.bodyA.categoryBitMask == ElementNames.Beast2){
            dino3.removeAction(forKey: "move3")

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Wall && contact.bodyB.categoryBitMask == ElementNames.Beast2) || (contact.bodyB.categoryBitMask == ElementNames.Wall && contact.bodyA.categoryBitMask == ElementNames.Beast2){
            print ("dino3 hit border")
            dino3.removeAction(forKey: "move3")

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Water && contact.bodyB.categoryBitMask == ElementNames.Beast2) || (contact.bodyB.categoryBitMask == ElementNames.Water && contact.bodyA.categoryBitMask == ElementNames.Beast2){
            dino3.removeAction(forKey: "move3")

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Rock && contact.bodyB.categoryBitMask == ElementNames.Beast2) || (contact.bodyB.categoryBitMask == ElementNames.Rock && contact.bodyA.categoryBitMask == ElementNames.Beast2){
            run(enemyDeathSound)
            dino3.removeFromParent()
            statusBarLabel.text = "dino3 killed"

        }

        if (contact.bodyA.categoryBitMask == ElementNames.Beast2 && contact.bodyB.categoryBitMask == ElementNames.Food) || (contact.bodyB.categoryBitMask == ElementNames.Beast2 && contact.bodyA.categoryBitMask == ElementNames.Food){
            run(eatSound)
            searchAndDestroyItem(item: "food")

        }





    }



    func invalidateAllTimers() {
        for timer in allTimers {
            timer.invalidate()
        }
    }

    func searchAndDestroyItem(item: String){
        for i in 0..<maze.blockArray.count{
            for j in 0..<maze.blockArray[i].count{
                if maze.blockArray[i][j].id == item {
                    itemArray[i][j].removeFromParent()
                    maze.blockArray[i][j].hasBeenTaken = false
                    maze.blockArray[i][j].id = ""
                    switch item {
                    case "food":
                        addFood()
                    case "star":
                        addStar()
                    default:
                        break
                    }
                }
            }
        }
    }


    func gameOver(){
        let flipTransition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        let gameOverScene = GameOver(size: self.size, starCount: starCount)
        gameOverScene.scaleMode = .aspectFill
        self.view?.presentScene(gameOverScene, transition: flipTransition)
    }
}
