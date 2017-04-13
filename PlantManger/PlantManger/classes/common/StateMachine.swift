//
//  StateMachine.swift
//  PlantManger
//
//  Created by jiaerdong on 2017/4/10.
//  Copyright © 2017年 hongjia. All rights reserved.
//

import Foundation

class StateMachine: NSObject {
    var stateDataModel: StateDataModel?
    var stateArray:Array<BaseState> = [BaseState]()
    var currentState:BaseState?
    init(action:ActionModel){
        
        let startState:BaseState = BaseState()
        startState.value = action.startValue
        startState.mode = "single"
        stateArray.append(startState)
        
        var stepCount = 0
        if(action.stepModel.count > 0){
            stepCount = (action.stepModel.count)
            for i in 0..<stepCount {
                let state:BaseState = BaseState()
                state.value = (action.stepModel[i].value)
                state.mode = (action.stepModel[i].mode)
                stateArray.append(state)
            }
        }
        
        let endState:BaseState = BaseState()
        endState.value = action.endValue
        endState.mode = "single"
        stateArray.append(endState)

        currentState = stateArray.first
    }

    func nextState(barcodeValue:String) -> Int{
        var i: Int = 0
        for item: BaseState in stateArray {
            i = i+1
            
            if(currentState?.value == item.value && currentState?.mode != "mult" && i < stateArray.count){
                print(stateArray[i].value + "---" + barcodeValue)
                let regular = try! NSRegularExpression(pattern: (stateArray[i].value), options:.caseInsensitive)
                let results = regular.matches(in: barcodeValue, options: .reportProgress , range: NSMakeRange(0, barcodeValue.characters.count))
                
                if(results.count > 0) {
                    currentState = stateArray[i]
                    return i
                }
            } else if(currentState?.value == item.value && (currentState?.mode)! == "mult" && i+1<stateArray.count) {
                print(stateArray[i].value + "---" + barcodeValue)
                let regular = try! NSRegularExpression(pattern: (stateArray[i].value), options:.caseInsensitive)
                let results = regular.matches(in: barcodeValue, options: .reportProgress , range: NSMakeRange(0, barcodeValue.characters.count))
                
                let regularNext = try! NSRegularExpression(pattern: (stateArray[i+1].value), options:.caseInsensitive)
                let resultsNext = regularNext.matches(in: barcodeValue, options: .reportProgress , range: NSMakeRange(0, barcodeValue.characters.count))

                if(resultsNext.count > 0) {
                    currentState = stateArray[i+1]
                    return i+1
                }
            }
        }
        return -1
    }
    
}

