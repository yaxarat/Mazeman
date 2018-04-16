//
//  PlaceBlock.swift
//  MazeMan
//
//  Created by Yashar Atajan on 4/11/18.
//  Copyright © 2018 Yaxiaer Atajiang. All rights reserved.
//

import Foundation
import SpriteKit

class PlaceBlock {
    var blockArray: [[Block]] = [[Block]]()

    init() {
        for i in 0...20 {
            var newArray = [Block]()
            for j in 0...10 {
                var temp = Block()
                temp.yCoordinate = i
                temp.xCoordinate = j
                temp.occupied = false
                newArray.append(temp)
            }
            blockArray.append(newArray)
        }
    }

    func addNewBlock(x: Int, y: Int) {
        blockArray[x][y].occupied = false
    }
}