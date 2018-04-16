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

    // Assets
    var maze = PlaceBlock()
    var allTimers = [Timer]()
    var itemArray: [[SKSpriteNode]]!
    var randXCoordinate = Int(arc4random_uniform(20))
    var randYCoordinate = Int(arc4random_uniform(10))
    var addBlockTimer = 0, addRockTimer = 0, respawnTimer = 0
    var rockCount, starCount, heartCount, energyCount: Int!

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        initAll()



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
        hud()
        initMessage()
        addAssets()
        gestures()
    }

    func initTimeAndCount() {
        allTimers = [Timer]()
        addBlockTimer = 0
        addRockTimer = 0
        respawnTimer = 0
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
        starLabel.fontSize = 30
        rockLabel.fontSize = 30
        heartLabel.fontSize = 30
        energyLabel.fontSize = 30
        statusBarLabel.fontSize = 30

        starLabel.fontColor = SKColor.black
        rockLabel.fontColor = SKColor.black
        heartLabel.fontColor = SKColor.black
        energyLabel.fontColor = SKColor.black
        statusBarLabel.fontColor = SKColor.white

        starLabel.text = String(starCount)
        rockLabel.text = String(rockCount)
        heartLabel.text = String(heartCount)
        energyLabel.text = String(energyCount)
        statusBarLabel.text = "Survive the MazeMan"
    }

    func startTimers() {
        // For block
        let blockCreationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addBlocks(sender:)), userInfo: nil, repeats: true)
        allTimers.append(blockCreationTimer)
        // For rock
        let getRocksTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addRocks(sender:)), userInfo: nil, repeats: true)
        allTimers.append(getRocksTimer)
        // For energy
        let drainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(drainEnergy(sender:)), userInfo: nil, repeats: true)
        allTimers.append(drainTimer)
        // For dino
        let timer1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(moveDino1(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer1)
        // For dino
        let timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(moveDino2(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer2)
        // For dino
        let timer3 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(moveDino3(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer3)
        // For dino
        let timer4 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dino4Moves(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer4)
        // For dino4 attack
        let timerfire = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(throwFire(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timerfire)
        // For dino respawn
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(respawn(sender:)), userInfo: nil, repeats: true)
        allTimers.append(timer)
    }

    func initBg() {
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = self.size
        addChild(background)
    }

    func initBoundsAndPonds() {
        boundTop.position = CGPoint(x: self.frame.width/2, y: 896)
        boundTop.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height:1))
        addChild(boundTop)
        boundTop.physicsBody?.isDynamic = false

        boundLeft.position = CGPoint(x: 0, y:self.frame.height/2)
        boundLeft.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height:self.frame.height))
        addChild(boundLeft)
        boundLeft.physicsBody?.isDynamic = false

        boundRight.position = CGPoint(x: 1344, y:self.frame.height/2)
        boundRight.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height:self.frame.height))
        addChild(boundRight)
        boundRight.physicsBody?.isDynamic = false

        boundBottom.position = CGPoint(x: 256, y: 63)
        boundBottom1.position = CGPoint(x: 712, y: 63)
        boundBottom2.position = CGPoint(x: 1140, y: 63)
        boundBottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 512, height:1))
        addChild(boundBottom)
        boundBottom.physicsBody?.isDynamic = false
        boundBottom1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 256, height:1))
        addChild(boundBottom1)
        boundBottom1.physicsBody?.isDynamic = false
        boundBottom2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 470, height:1))
        addChild(boundBottom2)
        boundBottom2.physicsBody?.isDynamic = false

        doesCollide(item: "border" , node: boundTop)
        doesCollide(item: "border" , node: boundBottom)
        doesCollide(item: "border" , node: boundLeft)
        doesCollide(item: "border" , node: boundRight)

        makeBoundary(yCoordinate: CGFloat(64 / 2))
        makeBoundary(yCoordinate: CGFloat(1024 - 64 / 2))
        makeBoundary(yCoordinate: CGFloat((1024 - 64 / 2)) - 64)

        addNewItem(item: "water", x: 6, y: -1)
        addNewItem(item: "water", x: 16, y: -1)
    }

    func makeBoundary(yCoordinate: CGFloat) {
        for i in 0...21 {
            let aBlock = SKSpriteNode(imageNamed: "block")
            aBlock.size = CGSize(width: 64, height: 64)
            aBlock.position = CGPoint(x: aBlock.frame.size.width/2 + CGFloat(64*i), y: yCoordinate)
            self.addChild(aBlock)
        }
    }

    func hud() {
        var image = ""
        var label: SKLabelNode!
        for i in 0...3 {
            switch i {
            case 0:
                image = "star"
                label = starLabel
            case 1:
                image = "rock"
                label = rockLabel
            case 2:
                image = "heart"
                label = heartLabel
            case 3:
                image = "battery"
                label = energyLabel
            default:
                break
            }
            let object = SKSpriteNode(imageNamed: "\(image)")
            if image == "battery" {
                object.size = CGSize(width: 100, height: 100)
            } else {
                object.size = CGSize(width: 55, height: 55)
            }
            object.position = CGPoint(x:object.frame.size.width/2 + CGFloat(64*i), y: 32)
            label.position.x = object.position.x
            label.position.y = 20
            self.addChild(object)
            self.addChild(label)
        }
    }

    func initMessage() {
        let message = SKSpriteNode(imageNamed:"game-status-panel")
        message.position = CGPoint(x:self.frame.size.width/2, y: 950)
        message.size = CGSize(width: 800, height: 100)
        addChild(message)

        statusBarLabel.position.x = message.position.x
        statusBarLabel.position.y = message.position.y - 10
        addChild(statusBarLabel)
    }

    func updateLabels() {
        starLabel.text = String(starCount)
        rockLabel.text = String(rockCount)
        heartLabel.text = String(heartCount)
        energyLabel.text = String(energyCount)
    }

    func addAssets() {
        Character()
        addDino1()
        addDino2()
        addDino3()
        addDino4()
        addFood()
        addStar()
    }

    func Character(){
        character.size = CGSize(width: 64, height: 64)
        character.position = CGPoint(x:character.frame.size.width/2, y: character.frame.size.height/2 + (64))
        character.physicsBody = SKPhysicsBody(rectangleOf: character.size, center: character.anchorPoint)
        addChild(character)
        character.physicsBody?.isDynamic = true
        character.physicsBody?.affectedByGravity = false
        character.physicsBody?.allowsRotation = false

        doesCollide(item: "character", node: character)

        maze.blockArray[0][0].occupied = true
    }

    //TODO: FIX THESE
    func addDino1(){
        let waterSpawn = Int(arc4random_uniform(2))
        var xPos: CGFloat = 0
        dino1.size = CGSize(width: 64, height: 64)
        if waterSpawn == 0 {
            xPos = dino1.frame.size.width/2 + (64*6)
        } else {
            xPos = dino1.frame.size.width/2 + (64*16)
        }
        dino1.position = CGPoint(x: xPos, y: dino1.frame.size.height/2 + 64)
        dino1.physicsBody = SKPhysicsBody(rectangleOf: dino1.size, center: dino1.anchorPoint)
        dino1.name = "dino1"
        addChild(dino1)
        dino1.physicsBody?.affectedByGravity = false
        dino1.physicsBody?.allowsRotation = false
        doesCollide(item: "dino1", node: dino1)

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
        doesCollide(item: "dino2", node: dino2)

    }

    func addDino3(){

        dino3.size = CGSize(width: 64, height: 64)


        dino3.position = CGPoint(x: dino3.frame.size.width/2+10, y: dino3.frame.size.height/2 + (64*13-10))
        dino3.physicsBody = SKPhysicsBody(rectangleOf: dino3.size, center: dino3.anchorPoint)
        dino3.name = "dino3"
        addChild(dino3)
        dino3.physicsBody?.affectedByGravity = false
        dino3.physicsBody?.allowsRotation = false
        doesCollide(item: "dino3", node: dino3)

    }

    func addDino4(){

        dino4.size = CGSize(width: 64, height: 64)
        dino4.position = CGPoint(x: dino4.frame.size.width/2+10, y: dino4.frame.size.height/2 + (64*13 + 40))
        dino4.name = "dino4"
        addChild(dino4)


    }

    func addFood() {
        addItem(itemName: "food")
    }

    func addStar() {
        addItem(itemName: "star")
    }

    @objc func respawn(sender: Timer) {
        respawnTimer += 1
        if respawnTimer == 5 {
            respawnTimer = 0
            checkDinoStat()
        }
    }

    func checkDinoStat() {
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

    @objc func addBlocks(sender: Timer) {
        addBlockTimer += 1
        addItem(itemName: "block")

        // Keep adding until 15 blocks
        if addBlockTimer == 15 {
            sender.invalidate()
        }
    }

    @objc func addRocks(sender: Timer) {
        addRockTimer += 1

        if addRockTimer % 30 == 0 {
            if rockCount <= 10 {
                rockCount! += 10
                updateLabels()
            } else {
                rockCount = 20
                updateLabels()
            }
        }
    }

    func addItem(itemName: String) {
        if maze.blockArray[randXCoordinate][randYCoordinate].occupied {
            while maze.blockArray[randXCoordinate][randYCoordinate].occupied {
                randXCoordinate = Int(arc4random_uniform(20))
                randYCoordinate = Int(arc4random_uniform(10))
            }
        }
        addNewItem(item: itemName, x: randXCoordinate, y: randYCoordinate)
        maze.blockArray[randXCoordinate][randYCoordinate].occupied = true
    }

    func addNewItem(item: String, x: Int, y: Int) {
        let element = SKSpriteNode(imageNamed: item)

        if item == "water" {
            // Different height is to prevent instant kill from initial rightward movement
            element.size = CGSize(width:64, height:62)
        } else {
            element.size = CGSize(width:64, height:64)
        }

        element.position = CGPoint(x: element.frame.size.width/2 + CGFloat(64*x), y: element.frame.size.width/2 + CGFloat(64*(y+1)))
        element.physicsBody = SKPhysicsBody(rectangleOf: element.size, center: element.anchorPoint)
        self.addChild(element)
        element.physicsBody?.isDynamic = false

        if ((x >= 0 && x <= maze.blockArray.count) && (y >= 0 && y <= maze.blockArray.count)){
            maze.blockArray[x][y].id = item
            itemArray[x][y] = element
        }
        doesCollide(item: item, node: element)
    }

    func gestures() {
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]

        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(gestureResponce(sender:)))
            swipe.direction = direction
            self.view?.addGestureRecognizer(swipe)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(throwRock(sender:)))
        self.view?.addGestureRecognizer(tap)
    }

    @objc func gestureResponce(sender: UISwipeGestureRecognizer) {
        let currentX = character.anchorPoint.x
        let currentY = character.anchorPoint.y

        switch sender.direction {
        case UISwipeGestureRecognizerDirection.left:
            if character.position.x > 64 {
                move(xCoordinate: -1400, yCoordinate: currentY)
            }
        case UISwipeGestureRecognizerDirection.right:
            if character.position.x < 1290 {
                move(xCoordinate: 1400, yCoordinate: currentY)
            }
        case UISwipeGestureRecognizerDirection.up:
            if character.position.y < 800 {
                move(xCoordinate: currentX, yCoordinate: 900)
            }
        case UISwipeGestureRecognizerDirection.down:
            if character.position.y > 64 {
                move(xCoordinate: currentX, yCoordinate: -900)
            }
        default:
        break
        }
    }

    @objc func throwRock(sender: UITapGestureRecognizer) {
        if rockCount >= 1 {
            var location = sender.location(in: sender.view)
            location = self.convertPoint(fromView: location)
            let rock = SKSpriteNode(imageNamed:"rock")

            rock.position = character.position
            rock.size = CGSize(width: 30, height: 30)
            rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
            self.addChild(rock)
            rock.physicsBody?.affectedByGravity = false
            doesCollide(item: "rock", node: rock)

            var dx = CGFloat(location.x - character.position.x)
            var dy = CGFloat(location.y - character.position.y)
            let magnitude = sqrt(dx * dx + dy * dy)
            dx /= magnitude
            dy /= magnitude
            let vector = CGVector(dx: 35 * dx, dy: 35 * dy)

            rock.physicsBody?.applyImpulse(vector)
            rockCount! -= 1
            run(throwSound)
            updateLabels()
        }
    }

    @objc func throwFire(sender: Timer) {

        let fire = SKSpriteNode(imageNamed: "fire")
        fire.position = dino4.position
        fire.size = CGSize(width: 30, height: 30)
        fire.physicsBody = SKPhysicsBody(rectangleOf: fire.size)
        self.addChild(fire)
        fire.physicsBody?.affectedByGravity = false
        doesCollide(item: "fire", node: fire)

        let shoot: SKAction = SKAction.moveBy(x: dino1.anchorPoint.x, y: -1000, duration: 10)
        fire.run(shoot)
    }

    func move(xCoordinate: CGFloat, yCoordinate: CGFloat) {
        character.removeAction(forKey: "move")
        let move = SKAction.moveBy(x: xCoordinate, y: yCoordinate, duration: 10)
        character.run(move, withKey: "move")
    }

    @objc func moveDino1(sender: Timer){
        if dino1.action(forKey: "move1") == nil{
            var allActions = [SKAction]()
            let wait = SKAction.wait(forDuration: (Double(arc4random_uniform(3))+1))
            let moveUp = SKAction.moveBy(x: 0, y:700, duration: 3)
            let moveDown = SKAction.moveBy(x: 0, y: -700, duration: 3)
            allActions.append(wait)
            allActions.append(moveUp)
            allActions.append(moveDown)
            dino1.run(SKAction.sequence(allActions), withKey: "move1")
        }
    }

    @objc func moveDino2(sender: Timer){
        if dino2.action(forKey: "move2") == nil{
            var allActions = [SKAction]()
            let wait = SKAction.wait(forDuration: Double(arc4random_uniform(3))+1)
            let moveLeft = SKAction.moveBy(x: -1300, y: 0, duration: 5)
            let moveRight = SKAction.moveBy(x: 1300, y: 0, duration: 5)
            let turnRight = SKAction.scale(to: CGSize(width: -64, height: 64), duration: 0 )
            let turnLeft = SKAction.scale(to: CGSize(width: 64, height: 64), duration: 0 )
            allActions.append(moveLeft)
            allActions.append(turnRight)
            allActions.append(moveRight)
            allActions.append(turnLeft)
            allActions.append(wait)
            dino2.run(SKAction.sequence(allActions), withKey: "move2")
        }
    }

    @objc func moveDino3(sender: Timer){
        if dino3.action(forKey: "move3") == nil{
            var allActions = [SKAction]()
            allActions = choiceDino3()
            dino3.run(SKAction.sequence(allActions), withKey: "move3")
        }
    }

    func choiceDino3() -> [SKAction] {
        var move = [SKAction]()
        var moved: Bool = false

        while !moved {
            let direction = Int(arc4random_uniform(2))

            if direction == 0 {
                let lR = Int(arc4random_uniform(2))
                if lR == 0 {
                    if dino3.position.x > 100 {
                        dino3.size.width = -64
                        move.append(SKAction.rotate(toAngle: 0, duration: 0))
                        move.append(SKAction.scale(to: CGSize(width: -64, height: 64), duration: 0))
                        move.append(SKAction.moveBy(x: -1340, y: 0, duration: 5))
                        moved = true
                    } else if dino3.position.x < 1200{
                        move.append(SKAction.rotate(toAngle: 0, duration: 0))
                        move.append(SKAction.scale(to: CGSize(width: 64, height: 64), duration: 0))
                        move.append(SKAction.moveBy(x: 1340, y: 0, duration: 5))
                        moved = true
                        dino3.size.width = 64
                    }
                }
            } else {
                let uD = Int(arc4random_uniform(2))

                if uD == 0 {
                    if dino3.position.y < 800 {
                        var rotation = SKAction()
                        if dino3.size.width == -64 {
                            rotation = SKAction.rotate(toAngle: -1.57, duration: 0)
                        } else {
                            rotation = SKAction.rotate(toAngle: 1.57, duration: 0)
                        }
                        move.append(rotation)
                        move.append(SKAction.moveBy(x:0, y:1000, duration: 5))
                    }
                } else if dino3.position.y > 100 {
                    var rotation = SKAction()

                    if dino3.size.width == -64 {
                        rotation = SKAction.rotate(toAngle: 1.57, duration: 0)
                    } else {
                        rotation = SKAction.rotate(toAngle: -1.57, duration: 0)
                    }
                    move.append(rotation)
                    move.append(SKAction.moveBy(x:0, y:-1000, duration: 7))
                }
                moved = true
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

    func doesCollide(item: String, node: SKSpriteNode){
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
        updateLabels()
    }

    func addEnergy() {
        if energyCount <= 50 {
            energyCount! += 50
        } else {
            energyCount = 100
        }
        updateLabels()
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
        updateLabels()
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
                    maze.blockArray[i][j].occupied = false
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