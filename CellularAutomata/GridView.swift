//
//  GridView.swift
//  CellularAutomata
//
//  Created by Samuel Legg on 13/12/2021.
//

import Foundation
import SwiftUI

struct vector{
    var x : Float
    var y : Float
    init (x:Float,y:Float){
        self.x = x
        self.y = y
    }
    
    
}

struct cell{
    var active : Bool
    var dir : UInt8
    
    init(active : Bool, dir : UInt8){
        self.active = active
        self.dir = dir
    }
}

struct Grid{
    var GridData : [cell] = []
    var size : Int
    
    init (size : Int){
        self.size = size
        for _ in 0 ..< self.size{
            for _ in 0 ..< self.size{
                self.GridData.append(cell(active: Bool.random(), dir: 0))
            }
        }
    }
    
    mutating func setEmpty(){
        self.GridData = Array(repeating: cell(active: false, dir: 0), count: self.size*self.size)
    }
    
    subscript(x:Int,y:Int) -> cell{
        get{
            return self.GridData[x*self.size+y]
        }
        set{
            self.GridData[x*self.size+y] = newValue
        }
    }
}
