//
//  ContentView.swift
//  CellularAutomata
//
//  Created by Samuel Legg on 13/12/2021.
//

import SwiftUI

struct ContentView: View {
    @State var x : Int = 0
    @State var y : Int = 0
    @State var state : Bool = false
    @State var highlight : Bool = false
    @State var live : Bool = false
    @State var timeStep : Int = 0
    @State var grid = Grid(size: 50)
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack{
        
            Canvas { context, size in
                if (highlight == true){
                    context.fill(
                        Path(CGRect(x: x*10, y: y*10, width: 10, height: 10))
                        ,with: .color(.red))
                        }
                
                
                for x in 0 ..< grid.size{
                    for y in 0 ..< grid.size{
                        if(grid[x,y].active == true){
                            context.fill(
                                Path(CGRect(x: x*10, y: y*10, width: 10, height: 10))
                                ,with: .color(.white))
                                }
                        
                                else{
                                    context.stroke(
                                        Path(CGRect(x: x*10, y: y*10, width: 10, height: 10))
                                        ,with: .color(.white),lineWidth : 0.2)
                                   
                                }
                        
                        
                    }
                }
            }
            VStack{
                Text("Time Step : \(timeStep)")
                
                TextField("x:", value :$x , format: .number).onSubmit {
                    highlight = true
                }
                TextField("y:", value :$y , format: .number).onSubmit {
                    highlight = true
                }
                Button("Submit"){
                    highlight = false
                    setActive()
                }
                HStack{
                    Button("Time Jump"){
                        TimeStep()
                    }
                    Button("Play/Pause"){
                        if(live == true){
                            live = false
                            timeStep = 0
                        }else{
                            live = true
                        }
                    }
                }
                
                Button("Clear grid"){
                    grid.setEmpty()
                }
            }
            
                
            
            
            
        }.onReceive(timer) { time in
            if(live == true){
                timeStep += 1
                TimeStep()
            }
        }
    }
    
    
    
    
    func TimeStep(){
        let device = MTLCreateSystemDefaultDevice()
        let rule = RulesOFLIFE(device: device!)
        var states : [Bool] = []
        for i in grid.GridData{
            states.append(i.active)
        }
        rule.FillBuffers(arrIn: states)
        rule.SendComputeCommand()
        rule.UpdateCells(cells: &grid)
        
    }
    func setActive(){
        self.grid[x,y].active = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
