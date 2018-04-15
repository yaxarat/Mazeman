//
//  GameViewController.swift
//  MazeMan
//
//  Created by Yashar Atajan on 4/11/18.
//  Copyright © 2018 Yaxiaer Atajiang. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            if let screen = GameScene(size: self.view.bounds.size) as? GameScene {
                screen.scaleMode = .aspectFill
                view.presentScene(screen)
                view.preferredFramesPerSecond = 60
            }

            view.ignoresSiblingOrder = false
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}