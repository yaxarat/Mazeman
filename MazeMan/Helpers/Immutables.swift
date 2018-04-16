//
// Created by Yashar Atajan on 4/11/18.
// Copyright (c) 2018 Yaxiaer Atajiang. All rights reserved.
//

import Foundation
import SpriteKit

// Labels
let starLabel = SKLabelNode(fontNamed: "Avenir")
let rockLabel = SKLabelNode(fontNamed: "Avenir")
let heartLabel = SKLabelNode(fontNamed: "Avenir")
let energyLabel = SKLabelNode(fontNamed: "Avenir")
let statusBarLabel = SKLabelNode(fontNamed: "Avenir")

// Elements
let character = SKSpriteNode(imageNamed: "app-icon")
let dino1 = SKSpriteNode(imageNamed: "dino1")
let dino2 = SKSpriteNode(imageNamed: "dino2")
let dino3 = SKSpriteNode(imageNamed: "dino3")
let dino4 = SKSpriteNode(imageNamed: "dino4")
let background = SKSpriteNode(imageNamed: "bg")

// Sounds
let throwSound = SKAction.playSoundFileNamed("throw.wav", waitForCompletion:false)
let eatSound = SKAction.playSoundFileNamed("eat.wav", waitForCompletion:false)
let deathSound = SKAction.playSoundFileNamed("death.wav", waitForCompletion:false)
let starSound = SKAction.playSoundFileNamed("star.wav", waitForCompletion:false)
let hurtSound = SKAction.playSoundFileNamed("bite.wav", waitForCompletion:false)
let fireHurtSound = SKAction.playSoundFileNamed("fire.wav", waitForCompletion:false)
let enemyDeathSound = SKAction.playSoundFileNamed("dino.wav", waitForCompletion:false)

// Bounds
let boundTop = SKSpriteNode()
let boundLeft = SKSpriteNode()
let boundRight = SKSpriteNode()
let boundBottom = SKSpriteNode()
let boundBottom1 = SKSpriteNode()
let boundBottom2 = SKSpriteNode()

