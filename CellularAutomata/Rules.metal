//
//  Rules.metal
//  CellularAutomata
//
//  Created by Samuel Legg on 14/12/2021.
//

#include <metal_stdlib>


using namespace metal;


kernel void gameoflife(device const uint8_t* inA,
                       device uint8_t* result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    
    int width = 50;
    int neighbours = inA[index-1] + inA[index+1] + inA[index + width] + inA[index + width + 1] + inA[index + width - 1] + inA[index - width] + inA[index - width + 1] + inA[index - width - 1];
    
    if(inA[index] == 0){
        if(neighbours == 3){
            result[index] = 1;
        }
    }else{
        if(neighbours < 2){
            result[index] = 0;
        }else if (neighbours > 3){
            result[index] = 0;
        }else{
            result[index] = 1;
        }

    }
    
}


kernel void lgca(device const uint8_t* active,
                 device const uint8_t* velocity,
                 device uint8_t* result,
                 uint index [[thread_position_in_grid]]
                 )
{
    int width = 50;
    if (active[index] == 1){
        if (velocity[index] == 0){
            result[index + width] = 1;
        }
        else if (velocity[index] == 1){
            result[index - width] = 1;
        }
        else if (velocity[index] == 2){
            result[index] = 1;
        }
        else if (velocity[index] == 3){
            result[index] = 1;
        }
    }
}
