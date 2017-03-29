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
    var leftText: String = ""
    var rightText: String = ""
    
    init(isSelected: Bool, leftText: String, rightText: String) {
        self.isSelected = isSelected
        self.leftText = leftText
        self.rightText = rightText
    }
    
}
