//
//  CreateMaze.swift
//  MazeMan
//
//  Created by Yashar Atajan on 4/11/18.
//  Copyright © 2018 Yaxiaer Atajiang. All rights reserved.
//

import Foundation
import SpriteKit

class CreateMaze {
    var blockArray: [[Block]] = [[Block]]()

    init() {
        setupGrid()
    }


    func setupGrid(){

        for i in 0...20 {
            var newArray = [Block]()
            for j in 0...10 {
                var val = Block()
                val.locationY = i
                val.locationX = j
                val.hasBeenTaken = false
                newArray.append(val)
            }
            blockArray.append(newArray)
        }
    }

    func addNewBlock(x: Int, y: Int) {
        blockArray[x][y].hasBeenTaken = false
    }
}