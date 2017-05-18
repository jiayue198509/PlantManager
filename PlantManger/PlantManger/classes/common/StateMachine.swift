//
//  StateMachine.swift
//  PlantManger
//
//  Created by jiaerdong on 2017/4/10.
//  Copyright © 2017年 hongjia. All rights reserved.
//

import Foundation

class StateMachine: NSObject {
    var stateDataModel: StateDataModel = StateDataModel() {
        didSet {
            UserDefaults.standard.set(stateDataModel, forKey: "data")
        }
    }
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
                state.responseName = (action.stepModel[i].responseValue)
                stateArray.append(state)
            }
        }
        
        let endState:BaseState = BaseState()
        endState.value = action.endValue
        endState.mode = "single"
        stateArray.append(endState)

        currentState = stateArray.first
    }

    func addDataToModel(i: Int, barcode: String, mode:String){
        if i == stateArray.count-1 {
            stateDataModel.finishCmd = barcode
        }else {
            var index = 0
            for item in stateDataModel.dataArray {
                if(item.index == i) {
                    stateDataModel.dataArray[i-1].data.append(barcode)
                    return
                }
                index = index + 1
            }
            let tint = TintModel()
            tint.mode = mode
            tint.index = i
            tint.data.append(barcode)
            tint.responseValue = (currentState?.responseName)!
            stateDataModel.dataArray.append(tint)
        }
    }
    
    func nextState(barcodeValue:String) -> (Int,String){
        var i: Int = 0
        for item: BaseState in stateArray {
            i = i+1
            print(currentState?.value)
            if(currentState?.value == item.value && currentState?.mode != "mult" && i < stateArray.count){
                print(stateArray[i].value + "---" + barcodeValue)
                let regular = try! NSRegularExpression(pattern: (stateArray[i].value), options:.caseInsensitive)
                let results = regular.matches(in: barcodeValue, options: .reportProgress , range: NSMakeRange(0, barcodeValue.characters.count))
                
                if(results.count > 0) {
                    currentState = stateArray[i]
                    var mode = ""
                    if(currentState?.mode == "mult"){
                        mode = "mult"
                    }else {
                        mode = "single"
                    }
                    addDataToModel(i: i, barcode: barcodeValue, mode: mode)
                    return (i - 1, "normal")
                }
            } else if(currentState?.value == item.value && (currentState?.mode)! == "mult" && i<stateArray.count) {
                print(stateArray[i].value + "---" + barcodeValue)
                let regular = try! NSRegularExpression(pattern: (stateArray[i - 1].value), options:.caseInsensitive)
                let results = regular.matches(in: barcodeValue, options: .reportProgress , range: NSMakeRange(0, barcodeValue.characters.count))
                if(results.count > 0) {
                    addDataToModel(i: i-1, barcode: barcodeValue, mode: "mult")
                    return (i - 1, "mult")
                }
                
                let regularNext = try! NSRegularExpression(pattern: (stateArray[i].value), options:.caseInsensitive)
                let resultsNext = regularNext.matches(in: barcodeValue, options: .reportProgress , range: NSMakeRange(0, barcodeValue.characters.count))

                if(resultsNext.count > 0) {
                    currentState = stateArray[i]
                    var mode = ""
                    if(currentState?.mode == "mult"){
                        mode = "mult"
                    }else {
                        mode = "single"
                    }
                    addDataToModel(i: i, barcode: barcodeValue, mode: mode)
                    
                    return (i, "normal")
                }
            }
        }
        return (-1, "error")
    }
    
}

