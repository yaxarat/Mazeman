//
//  GameOver.swift
//  MazeMan
//
//  Created by Yashar Atajan on 4/11/18.
//  Copyright © 2018 Yaxiaer Atajiang. All rights reserved.
//

import UIKit
import SpriteKit

class GameOver: SKScene {
    var button: UIButton!
    var starCount: Int!
    var highScores: [Int]?
    let highScoreArray: [Int] = [0, 0, 0]
    let score = SKLabelNode(fontNamed: "Avenir")
    let currentScoreLb = SKLabelNode(fontNamed: "Avenir")
    let flipTransition = SKTransition.doorsCloseHorizontal(withDuration: 2)
    
    init(size: CGSize, starCount: Int!) {
        super.init(size: size)
        self.starCount = starCount
        self.addChild(currentScoreLb)
        self.addChild(score)
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = .aspectFill
        self.view?.presentScene(newScene, transition: flipTransition)

        currentScoreLb.fontSize = 80
        currentScoreLb.text = ("Your score was: \(starCount!)")
        currentScoreLb.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        score.text = String(starCount!)
        score.fontSize = 55
        score.position = CGPoint(x: size.width/2, y: size.height/2)
    }

    override func didMove(to view: SKView) {
        background2.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background2.size = self.size
        background2.alpha = 0.3
        addChild(background2)

        button = UIButton(frame: CGRect(x: self.size.width/2 - 142, y: size.height/2 + 200, width: 300, height: 100))
        button.titleLabel?.font = UIFont(name: "Avenir", size: 45)
        button.setTitle("Try again", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(goBack(sender:)), for: .touchUpInside)

        self.view?.addSubview(button)

        highScores = scoreArray()
        updateScore(currentScore: self.starCount)
        updateScoreLb()
    }

    func scoreArray() -> [Int] {
        if let highScoresDefault = UserDefaults.standard.object(forKey: "HighScores") as? [Int] {
            return (highScoresDefault)
        } else {
            UserDefaults.standard.set(highScoreArray, forKey: "HighScores")
            return(highScoreArray)
        }
    }
    
    func updateScore(currentScore: Int) {
        for i in 0..<highScores!.count {
            if currentScore >= highScores![i] {
                highScores?.insert(currentScore, at: i)
                highScores?.remove(at: 3)
                break
            }
        }
        updateArray()
    }
    
    func updateArray(){
        //  let highScoreData = NSKeyedArchiver.archivedData(withRootObject: [Int](highScores!))
        UserDefaults.standard.set([Int](highScores!), forKey: "HighScores")
        UserDefaults.standard.synchronize()
    }

    func updateScoreLb() {
        var scoreString: String = "HighScores "
        for i in 0..<highScores!.count  {
            if i < highScores!.count - 1 {
                scoreString = scoreString + String(highScores![i])
                scoreString = scoreString + String(", ")
            } else {
                scoreString = scoreString + String(highScores![i])
            }
        }
        score.text = scoreString
    }
    
    @objc func goBack(sender: UIButton) {
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 1.3)
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = .aspectFill
        self.view?.presentScene(newScene, transition: transition)
        button.removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}