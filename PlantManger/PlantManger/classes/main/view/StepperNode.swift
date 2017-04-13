//
//  StepperNode.swift
//  PlantManger
//
//  Created by jiaerdong on 2017/3/29.
//  Copyright © 2017年 hongjia. All rights reserved.
//

import Foundation

class StepperNode: NSObject {
    
    var isSelected: Bool = false
    var stepText: String = ""
    var descText: String = ""
    
    init(isSelected: Bool, stepText: String, descText: String) {
        self.isSelected = isSelected
        self.stepText = stepText
        self.descText = descText
    }
    
}
