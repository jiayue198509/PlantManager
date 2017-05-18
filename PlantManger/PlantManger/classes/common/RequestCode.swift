//
//  RequestCode.swift
//  PlantManger
//
//  Created by jiaerdong on 2017/5/4.
//  Copyright © 2017年 hongjia. All rights reserved.
//

import Foundation

class RequestCode {
    
    class func getParams(array: Array<TintModel>) -> [String:Any]{
        let uid = UserDefaults.standard.string(forKey: "uid")
        let tkt = UserDefaults.standard.string(forKey: "tkt")

        var paramters = [
            "uid":uid ?? "",
            "tkt":tkt ?? ""
            ] as [String:Any]
        
        for item in array {
            let paramsName = item.responseValue
            var value = ""
            if(item.mode == "mult") {
                value = "["
                for itemData in item.data {
                    value = value + "{\"data\":\"" + itemData + "\"},"
                }
                value = (value as NSString).substring(to: value.characters.count - 1)
                value = value + "]"
            }else {
                value = item.data[0]
            }

//            value.remove(at: value.endIndex)
            paramters[paramsName] = value
            
        }
        
        return paramters
    }
}
