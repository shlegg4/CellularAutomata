//
//  ApplyRule.swift
//  Cellular Automata
//
//  Created by Samuel Legg on 14/12/2021.
//

import Foundation

import Metal



class RulesOFLIFE{
    var error : NSError?
    var device : MTLDevice!
    var applyRulefuncPSO : MTLComputePipelineState!
    var commandQueue : MTLCommandQueue!
    
//    vector input buffers
    var bufferin : MTLBuffer!
    var bufferout : MTLBuffer!
    
    var arrayLength : Int = 0
    
    
    
    init (device : MTLDevice){
        self.device = device
        let defaultLibrary : MTLLibrary! = self.device.makeDefaultLibrary()
        let applyruleFunc : MTLFunction! = defaultLibrary.makeFunction(name: "gameoflife")
        self.applyRulefuncPSO = try! self.device.makeComputePipelineState(function: applyruleFunc)
        self.commandQueue = self.device.makeCommandQueue()
        
    }
    func FillBuffers(arrIn : [Bool]){
        self.arrayLength = arrIn.count
        let BufferSize = arrIn.count * MemoryLayout<CFBit>.size
        self.bufferin = self.device.makeBuffer(length: BufferSize, options: MTLResourceOptions.storageModeShared)
        self.bufferout = self.device.makeBuffer(length: BufferSize, options: MTLResourceOptions.storageModeShared)

        loadData(buffer: self.bufferin, arr: arrIn)
        
    }
    
    func loadData(buffer : MTLBuffer,arr : [Bool]){
        let dataPtr = buffer.contents().bindMemory(to: uint8.self, capacity: arr.count)
        for i in 0 ..< arr.count {
            if arr[i] == true{
                dataPtr[i] = 1
            }else{
                dataPtr[i] = 0
            }
        }
    }
    
    func encodeCommands(computeEncoder : MTLComputeCommandEncoder,bufferIn : MTLBuffer, bufferOut : MTLBuffer){
        computeEncoder.setComputePipelineState(self.applyRulefuncPSO)
        computeEncoder.setBuffer(bufferIn, offset: 0, index: 0)
        computeEncoder.setBuffer(bufferOut, offset: 0, index: 1)
        
        let gridSize : MTLSize = MTLSizeMake(arrayLength, 1, 1)
       
        var threadGroupSizeInt : Int = self.applyRulefuncPSO.maxTotalThreadsPerThreadgroup
       
               if(threadGroupSizeInt > arrayLength){
                   threadGroupSizeInt = arrayLength
               }
       
               let threadGroupSize : MTLSize = MTLSizeMake(threadGroupSizeInt, 1, 1)
       
               computeEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
        
        
    }
    
    
    func SendComputeCommand(){
        
        let commandBuffer: MTLCommandBuffer? = commandQueue.makeCommandBuffer()
        assert(commandBuffer != nil, "Command buffer = nil")
        
        let computeEncoder : MTLComputeCommandEncoder? = commandBuffer?.makeComputeCommandEncoder()
        assert(computeEncoder != nil, " Compute encoder = nil")
        
        self.encodeCommands(computeEncoder: computeEncoder!, bufferIn: self.bufferin, bufferOut: self.bufferout)
        computeEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        
        
    }
    
    func UpdateCells(cells : inout Grid){
        let newValues = self.bufferout.contents().bindMemory(to: uint8.self, capacity: self.bufferout.allocatedSize/MemoryLayout<UInt8>.size)
        
        var vals : [uint8] = []
        for i  in 0 ..< cells.GridData.count{
            vals.append(newValues[i])
        }
        
        for i  in 0 ..< cells.GridData.count{
            if(newValues[i] == 1){
                cells.GridData[i].active = true
            }else{
                cells.GridData[i].active = false
            }
        }
    }
    
    
}







