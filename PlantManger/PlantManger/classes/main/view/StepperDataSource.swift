//
//  StepperDataSource.swift
//  PlantManger
//
//  Created by jiaerdong on 2017/3/29.
//  Copyright © 2017年 hongjia. All rights reserved.
//

import Foundation

@objc protocol StepperDataSource {
    
    func stepperNodeAtIndex(_ index: Int) -> StepperNode
    func stepperNodeCount() -> Int
    
}
