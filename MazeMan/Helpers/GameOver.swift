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
    let score = SKLabelNode(fontNamed: "Chalkduster")
    
    init(size: CGSize, starCount: Int!) {
        super.init(size: size)
        
        self.starCount = starCount
        
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = ("GameOver")
        score.text = String(starCount!)
        
        gameOverLabel.fontSize = 60
        score.fontSize = 40
        
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        score.position = CGPoint(x: size.width/2, y: size.height/2 )
        
        self.addChild(gameOverLabel)
        self.addChild(score)
        
        let flipTransition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = .aspectFill
        
        self.view?.presentScene(newScene, transition: flipTransition)
        
        
        
        //    button.removeFromSuperview()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func lookAtScores() -> [Int] {
        let newArray: [Int] = [0, 0, 0]
        if let highScoresDefault = UserDefaults.standard.object(forKey: "HighScores") as? [Int] {
            print(highScoresDefault)
            return (highScoresDefault)
            
        } else {
            UserDefaults.standard.set(newArray, forKey: "HighScores")
            return(newArray)
        }
    }
    
    func updateScore(ourScore: Int) {
        //        resetDefaults()
        for i in 0..<highScores!.count {
            if ourScore >= highScores![i] {
                highScores?.insert(ourScore, at: i)
                highScores?.remove(at: 3)
                break
            }
        }
        //   UserDefaults.standard.set(highScores!, forKey: "HighScores")
        updateDatabase()
    }
    
    
    func resetDefaults() {
        UserDefaults.standard.removeObject(forKey: "HighScores")
        UserDefaults.standard.synchronize()
    }
    
    func updateDatabase(){
        //  let highScoreData = NSKeyedArchiver.archivedData(withRootObject: [Int](highScores!))
        UserDefaults.standard.set([Int](highScores!), forKey: "HighScores")
        UserDefaults.standard.synchronize()
    }
    
    
    
    override func didMove(to view: SKView) {
        button = UIButton(frame: CGRect(x: self.size.width/2 - 142, y: size.height/2 + 50, width: 300, height: 100))
        button.titleLabel?.font = UIFont(name: "chalkDuster", size: 30)
        button.setTitle("Begin New Game", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(goBack(sender:)), for: .touchUpInside)
        
        self.view?.addSubview(button)
        //       resetDefaults()
        highScores = lookAtScores()
        updateScore(ourScore: self.starCount)
        scoreLabelUpdate()
        
        
        
        
    }
    
    func scoreLabelUpdate() {
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
        let flipTransition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = .aspectFill
        
        self.view?.presentScene(newScene, transition: flipTransition)
        button.removeFromSuperview()
    }
    
    
}
