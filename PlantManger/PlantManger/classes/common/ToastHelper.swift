//
//  ToastHelper.swift
//  PlantManger
//
//  Created by jiaerdong on 2017/4/13.
//  Copyright © 2017年 hongjia. All rights reserved.
//

import Foundation
import MBProgressHUD

class ToastHelper {
    
    static var HUD:MBProgressHUD?
    //文本提示框
    class func showTextDialog(view: UIView){
        //初始化对话框，置于当前的View当中
        HUD = MBProgressHUD(view: view)
        view.addSubview(HUD!)
        //如果设置此属性，则当前view置于后台
        HUD?.dimBackground = true
        //设置对话框文字
        HUD?.labelText = "请稍等"
        HUD?.show(animated: true, whileExecuting: {
            sleep(3)
        }, completionBlock: {
            self.HUD?.removeFromSuperview()
            self.HUD = nil
        })
    }
    //框型进度提示
    class func showProgressDialog1(view: UIView){
        //初始化对话框，置于当前的View当中
        HUD = MBProgressHUD(view: view)
        view.addSubview(HUD!)
        //如果设置此属性，则当前view置于后台
        HUD?.dimBackground = true
        //设置对话框文字
        HUD?.labelText = "正在加载"
        //设置模式为进度框形的
        HUD?.mode = MBProgressHUDMode.determinate
        HUD?.show(animated: true, whileExecuting: {
            var progress : Float = 0.0
            while(progress < 1.0){
                progress += 0.01
                self.HUD?.progress = progress
                usleep(50000)
            }
        }, completionBlock: {
            self.HUD?.removeFromSuperview()
            self.HUD = nil
        })
    }
    //进度条提示
    class func showProgressDialog2(view: UIView){
        //初始化对话框，置于当前的View当中
        HUD = MBProgressHUD(view: view)
        view.addSubview(HUD!)
        //如果设置此属性，则当前view置于后台
        HUD?.dimBackground = true
        //设置对话框文字
        HUD?.labelText = "正在加载"
        //设置模式为进度条
        HUD?.mode = MBProgressHUDMode.determinateHorizontalBar
        HUD?.show(animated: true, whileExecuting: {
            var progress : Float = 0.0
            while(progress < 1.0){
                progress += 0.01
                self.HUD?.progress = progress
                usleep(50000)
            }
        }, completionBlock: {
            self.HUD?.removeFromSuperview()
            self.HUD = nil
        })
    }
    //自定义提示
    class func showCustomDialog(view: UIView){
        //初始化对话框，置于当前的View当中
        HUD = MBProgressHUD(view: view)
        view.addSubview(HUD!)
        //如果设置此属性，则当前view置于后台
        HUD?.dimBackground = true
        //设置对话框文字
        HUD?.labelText = "操作成功"
        //设置模式为自定义
        HUD?.mode = MBProgressHUDMode.customView
        HUD?.customView = UIImageView(image: UIImage(named: "37x-Checkmark-1"))
        HUD?.show(animated: true, whileExecuting: {
            sleep(2)
        }, completionBlock: {
            self.HUD?.removeFromSuperview()
            self.HUD = nil
        })
        
    }
    //纯文本提示
    class func showAllTextDialog(view: UIView, message:String){
        //初始化对话框，置于当前的View当中
        HUD = MBProgressHUD(view: view)
        view.addSubview(HUD!)
        //如果设置此属性，则当前view置于后台
        HUD?.dimBackground = true
        //设置模式为纯文本提示
        HUD?.mode = MBProgressHUDMode.text
        //设置对话框文字
        HUD?.labelText = message
        //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
        //        HUD?.yOffset = 150.0
        //        HUD?.xOffset = 150.0
        HUD?.show(animated: true, whileExecuting: {
            sleep(2)
        }, completionBlock: {
            self.HUD?.removeFromSuperview()
            self.HUD = nil
        })
    }
}
