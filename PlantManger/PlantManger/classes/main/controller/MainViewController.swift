//
//  CCBarcodeScanViewController
//  XRQRCoder-master
//
//  Created by jiaerdong on 16/2/18.
//  Copyright © 2016年 X.R. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MBProgressHUD
import SwiftyJSON

let distanceToCenter: CGFloat = 30.0    // 扫描区域中心向上提升的距离
let navigationBarHeight: CGFloat = 64.0 // 导航条高度
let windowSize: CGSize = UIScreen.main.bounds.size // 屏幕的尺寸
let scanSize: CGSize = CGSize(width: windowSize.width * 3 / 4.0, height: windowSize.width * 3 / 4.0)
let bottomViewHeight: CGFloat = 100.0
let bottomBtnSize: CGFloat = 60.0
let bottomBtnTag: Int = 4000
let navigationBarColor: UIColor = UIColor.black.withAlphaComponent(0.6)

let kStepViewH: CGFloat = 100.0

let kNavTitleTag:Int = 1000
let kNavLeftBtnTag:Int = 2000
let kNavRightBtnTag:Int = 3000


class MainViewController: UIViewController, UIAlertViewDelegate, UINavigationControllerDelegate {
    
    var scanRectView: UIView?
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var session: AVCaptureSession?
    var preView: AVCaptureVideoPreviewLayer?
    var animateLine: UIView?
    var messageLabel: UILabel?
    var navigationBar: UIView?
    
    fileprivate var stateMachine: StateMachine?
    
    fileprivate var actions:[ActionModel] = [ActionModel]()
    
    var nodes: [StepperNode] = [StepperNode]()
    
    var stepperView: StepperView?
    
    var isScaning:Bool = false
    
    func setupNavigationBar() {
        // 自定义导航条
        self.navigationBar = UIView()
        self.navigationBar?.frame = CGRect(x: 0, y: 0, width: windowSize.width, height: navigationBarHeight)
        self.navigationBar?.backgroundColor = navigationBarColor
        self.view.addSubview(self.navigationBar!)
        
        let titleLabel = UILabel()
        titleLabel.tag = kNavTitleTag
        titleLabel.frame = CGRect(x: (windowSize.width - 130.0) * 0.5, y: 20.0, width: 130, height: 44.0)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor.white
        titleLabel.text = "已登录"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.navigationBar?.addSubview(titleLabel)
        
        // 返回item
        let backItemBtn = UIButton(type: .custom)
        backItemBtn.tag = kNavLeftBtnTag
        backItemBtn.frame = CGRect(x:5.0, y: 25.0, width: 30, height: 30.0)
        backItemBtn.setImage(UIImage.init(named: "login"), for: UIControlState.normal)
        backItemBtn.setImage(UIImage.init(named: "login_highlight"), for: UIControlState.selected)
        backItemBtn.addTarget(self, action: #selector(MainViewController.backAction), for: .touchUpInside)
        self.navigationBar?.addSubview(backItemBtn)
        
        // 返回item
        let exitItemBtn = UIButton(type: .custom)
        exitItemBtn.tag = kNavRightBtnTag
        exitItemBtn.frame = CGRect(x:windowSize.width - 40, y: 25.0, width: 30.0, height: 30.0)
        exitItemBtn.setImage(UIImage.init(named: "exit"), for: UIControlState.normal)
        exitItemBtn.addTarget(self, action: #selector(MainViewController.exitAction), for: .touchUpInside)
        self.navigationBar?.addSubview(exitItemBtn)
        
    }
    
    
    func setupQRCode() {
        setupNavigationBar()
        do {
            self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            self.input = try AVCaptureDeviceInput(device: self.device)
            
            self.output = AVCaptureMetadataOutput()
            output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            self.session = AVCaptureSession()
            if UIScreen.main.bounds.size.height < 500.0 {
                // iPhone 4 or 4S
                self.session?.sessionPreset = AVCaptureSessionPreset640x480
            }else {
                self.session?.sessionPreset = AVCaptureSessionPresetHigh // 高精度
            }
            
            self.session?.addInput(self.input)
            self.session?.addOutput(self.output)
            // 二维码
            self.output?.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code]
            
            // 扫描区域 （也是扫描框的frame）
            let scanRect: CGRect = CGRect(x: (windowSize.width - scanSize.width) * 0.5, y: (windowSize.height - scanSize.height) * 0.5 - distanceToCenter, width: scanSize.width, height: scanSize.height)
            
            // rectOfInterset设置： CGRectMake(扫描区域y的起点/屏幕的高度, 扫描区域的x/屏幕的宽度, 扫描区域的高/屏幕的高, 扫描区域的宽度/屏幕的宽度)
            let rectOfInterset: CGRect = CGRect(x: scanRect.origin.y/windowSize.height,
                                                y: scanRect.origin.x/windowSize.width,
                                                width: scanRect.size.height/windowSize.height,
                                                height: scanRect.size.width/windowSize.width);
            
            // 设置可探测区域
            self.output?.rectOfInterest = rectOfInterset
            
            self.preView = AVCaptureVideoPreviewLayer(session: self.session)
            self.preView?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.preView?.frame = UIScreen.main.bounds
            self.view.layer.insertSublayer(self.preView!, at: 0)
            
            // 添加探测区域绿色的框
            self.scanRectView = UIView()
            self.view.addSubview(self.scanRectView!)
            self.scanRectView?.frame = scanRect
            self.scanRectView?.layer.borderColor = UIColor.green.cgColor
            self.scanRectView?.layer.borderWidth = 1.5
            
            // 添加提示信息
            self.messageLabel = UILabel()
            self.messageLabel?.frame = CGRect(x: 0, y: self.scanRectView!.frame.origin.y - 50.0 - 20.0, width: windowSize.width, height: 50.0)
            self.messageLabel?.textColor = UIColor.white
            self.messageLabel?.textAlignment = NSTextAlignment.center
            self.messageLabel?.numberOfLines = 0
            self.messageLabel?.backgroundColor = UIColor.clear
            self.messageLabel?.font = UIFont.systemFont(ofSize: 15.0)
            self.messageLabel?.text = "将取景框对准二维码\n即可自动扫描"
            self.view.addSubview(self.messageLabel!)
            
            self.startLineAnimated()
            
            // 开始扫描时才是摄像界面
            self.session?.startRunning()
            
            // 放大
            do {
                try self.device!.lockForConfiguration()
                
            }catch _ as NSError {
                print("Error: lockForConfiguration")
            }
            
            self.device?.videoZoomFactor = 1.5 // 放大1.5
            self.device?.unlockForConfiguration()
            
        }catch _ as NSError {
//            let alert = UIAlertView(title: "提醒", message: "请在iPhone的\"设置-隐私-相机\"选项中，允许本程序访问您的相机", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
//            alert.show()
            
            let alertController = UIAlertController(
                title: "提醒",
                message: "请在iPhone的\"设置-隐私-相机\"选项中，允许本程序访问您的相机",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "打开设置", style: .default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    // 返回
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func exitAction() {
        clearUserInfo()
        clearStepData()
    }
    
    func clearUserInfo(){
        UserDefaults.standard.set(false, forKey: "isLogin")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "uid")
        UserDefaults.standard.removeObject(forKey: "tkt")
        (self.navigationBar?.viewWithTag(kNavTitleTag) as! UILabel).text = "请先扫码登录"
        (self.navigationBar?.viewWithTag(kNavLeftBtnTag) as! UIButton).isSelected = false
    }
    
    func clearStepData() {
        nodes.removeAll()
        stateMachine = nil
        stepperView?.setNeedsDisplay()
        stepperView?.removeFromSuperview()
    }
    
    func startLineAnimated() {
        // 扫描条
        self.animateLine = UIView()
        self.animateLine?.backgroundColor = UIColor.red
        let startX: CGFloat = 0
        let lineWidth = scanSize.width
        
        self.animateLine?.frame = CGRect(x: startX, y: 0.0, width: lineWidth, height: 1.5)
        self.scanRectView?.addSubview(self.animateLine!)
        self.scanLineAnimation()
    }
    
    func stopLineAnimated() {
        self.animateLine?.removeFromSuperview()
    }
    
    // 动画扫描
    func scanLineAnimation() {
        
        if let _ = self.animateLine {
            let windowSize: CGSize = UIScreen.main.bounds.size
            let scanSize: CGSize = CGSize(width: windowSize.width * 3 / 4.0, height: windowSize.width * 3 / 4.0)
            let startY:CGFloat = 0
            let endY = scanSize.height - 1.5
            
            UIView.animate(withDuration: 3.5, delay: 0.0, options: [UIViewAnimationOptions.repeat, UIViewAnimationOptions.curveEaseInOut], animations: { () -> Void in
                var lineFrame: CGRect = (self.animateLine?.frame)!
                lineFrame.origin.y = endY
                self.animateLine?.frame = lineFrame
                }, completion: { (finished) -> Void in
                    var lineFrame: CGRect = (self.animateLine?.frame)!
                    lineFrame.origin.y = startY
                    self.animateLine?.frame = lineFrame
            })
        }
    }
    
    // 开始扫描
    func startScan() {
        self.session?.startRunning()
        self.startLineAnimated()
    }
    
    // 结束扫描
    func stopScan() {
        self.session?.stopRunning()
        self.stopLineAnimated()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.startScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.stopScan()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paraseXML()
        self.view.backgroundColor = UIColor.white
        self.setupQRCode()
        
        checkUser()
        
        if(UserDefaults.standard.bool(forKey: "isLogin")) {
           (self.navigationBar?.viewWithTag(kNavTitleTag) as! UILabel).text = UserDefaults.standard.string(forKey: "name")
            (self.navigationBar?.viewWithTag(kNavLeftBtnTag) as! UIButton).isSelected = true
        }else{
            (self.navigationBar?.viewWithTag(kNavTitleTag) as! UILabel).text = "请先扫码登录"
        }
        
        (UIApplication.shared.delegate as! AppDelegate).foreClosure = { () -> Void in
            print("App 已经激活")
            self.startScan()
        }
        
        (UIApplication.shared.delegate as! AppDelegate).backClosure = {() -> Void in
            print("App 进入后台")
            self.stopScan()
        }
    }
}

extension MainViewController{
    func paraseXML(){
        //获取xml文件路径
        let file = Bundle.main.path(forResource: "action", ofType: "xml")
        let url = URL(fileURLWithPath: file!)
        //获取xml文件内容
        let xmlData = try! Data(contentsOf: url)
        //可以转换为字符串输出查看
        //print(String(data:xmlData, encoding:String.Encoding.utf8))
        
        let doc:GDataXMLDocument = try! GDataXMLDocument(data:xmlData, options : 0)
        let actions = try! doc.nodes(forXPath: "//action", namespaces:nil) as! [GDataXMLElement]
        for action in actions {
            let ac = ActionModel()
            ac.name = action.attribute(forName: "name").stringValue()
            
            let startNode = action.elements(forName: "start")[0] as! GDataXMLElement
            ac.startName = startNode.attribute(forName: "name").stringValue()
            ac.url = startNode.attribute(forName: "url").stringValue()
            ac.startValue = startNode.stringValue()
            
            if(action.childCount() > 2){
                let stepElements = action.elements(forName: "step") as! [GDataXMLElement]
                for step in stepElements {
                    let stepNode = StepModel()
                    stepNode.value = step.stringValue()
                    guard let name = step.attribute(forName: "name").stringValue() else { return }
                    stepNode.name = name
                    
                    let mode = step.attribute(forName: "mode")
                    if(mode == nil) {
                        stepNode.mode = "single"
                    }else {
                        stepNode.mode = mode!.stringValue()
                    }
                    let responeName = step.attribute(forName: "response")
                    if(responeName == nil) {
                        stepNode.responseValue = ""
                    }else {
                        stepNode.responseValue = responeName!.stringValue()
                    }
                    ac.stepModel.append(stepNode)
                    
                }
            }
            
            let endNode = action.elements(forName: "end")[0] as! GDataXMLElement
            ac.endName = endNode.attribute(forName: "name").stringValue()
            ac.endValue = endNode.stringValue()
            self.actions.append(ac)
        }
        
    }
}

//登录处理
extension MainViewController {
    func login(userInfo: String) {
        let parameters: Parameters = [
            "qcode": userInfo,
            "type": "mobile"
        ]
        

        NetworkTools.requestData(.post, URLString: ServerUrl + LoginRequest, parameters: parameters) { (result) in
            self.isScaning = false
            // 1.将result转成字典类型
            guard let resultDict = result as? [String : NSObject] else { return }
            
            // 2.根据data该key,获取数组
            guard let rtncode = resultDict["rtn_code"] as? NSString else { return }
            if rtncode == "0" {
                let date = NSDate()
                let timeInterval = date.timeIntervalSince1970 * 1000
                guard let userName = resultDict["name"] as? String else { return }
                UserDefaults.standard.set(userName, forKey:"name")
                guard let uid = resultDict["uid"] as? String else { return }
                UserDefaults.standard.set(uid, forKey:"uid")
                guard let tkt = resultDict["tkt"] as? String else { return }
                UserDefaults.standard.set(tkt, forKey:"tkt")
                UserDefaults.standard.set(true, forKey:"isLogin")

                
                UserDefaults.standard.set(timeInterval, forKey:"timeStamp")
                
                DispatchQueue.main.async(execute: { 
                       (self.navigationBar?.viewWithTag(kNavTitleTag) as! UILabel).text = userName
                    (self.navigationBar?.viewWithTag(kNavLeftBtnTag) as! UIButton).isSelected = true
                })
            }
        }

    }
}

extension MainViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var message: String?
        
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            message = metadataObject.stringValue
            if !checkQcode(qcode: message!) {return}
            if(isScaning) {return}
            isScaning = true
            if(!UserDefaults.standard.bool(forKey: "isLogin")) {
                if(message?.hasPrefix("YG"))! {
                    login(userInfo: message!)
                }else {
                    ToastHelper.showAllTextDialog(view: self.view, message: "请先扫描员工码登录")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                        self.isScaning = false
                    })
                }
                return
            }
            
            if let messageStr = message {
                if(stateMachine == nil) {
                    startStateMachine(messageStr: messageStr)
                } else {
                    let flag = checkData(barcode: messageStr)
                    if(!flag) {
                        isScaning = false
                        return
                    }
                    
                    if(messageStr == TaskCancelCmd) {
                        isScaning = false
                        clearStepData()
                        stepperView?.setNeedsDisplay()
                        return
                    }
                    
                    var (nextNum, code) = (stateMachine?.nextState(barcodeValue: messageStr))!
                    if(nextNum != -1){
                        if(nextNum >= self.nodes.count - 1) {
                            nextNum = nextNum - 1
                        }

                        if(code != "mult"){
                            self.nodes[nextNum+1].isSelected = true
                        }
                        
                        var i = 1
                        for item in (self.stateMachine?.stateDataModel.dataArray)! {
                            self.nodes[i].multDescText = "\(item.data.count)"
                            i = i + 1
                        }
                        
                        stepperView?.setNeedsDisplay()
                    }
                    
                    if(stateMachine?.currentState?.value == stateMachine?.stateArray.last?.value) {
                        postData()
                        stateMachine = nil
                        self.nodes.removeAll()
                        stepperView?.setNeedsDisplay()
                        self.stepperView?.removeFromSuperview()
                        
                    }
                }
            }
            isScaning = false
        }
    }
}

//状态机处理
extension MainViewController {
    fileprivate func startStateMachine(messageStr:String) {
        for action in actions {
            if (messageStr == action.startValue) {
                let date = NSDate()
                let timeInterval = date.timeIntervalSince1970 * 1000
                stateMachine = StateMachine(action: action)
                stateMachine?.stateDataModel.url = action.url
                stateMachine?.stateDataModel.startCmd = messageStr
                stateMachine?.stateDataModel.startTime = "\(timeInterval)"
                setupStepperView(action: action)
                return
            }
        }
    }
    
    func checkData(barcode:String) -> Bool{
        if(stateMachine != nil){
            if(barcode == stateMachine?.stateDataModel.startCmd) {
                return false
            }else if (barcode == stateMachine?.stateDataModel.finishCmd) {
                return false
            }
            
            for item in (stateMachine?.stateDataModel.dataArray)! {
                for data in item.data {
                    if(data == barcode){
                        return false
                    }
                }

            }
        }
        return true
    }
    
    func releaseStateMachine() {
        stateMachine = nil
    }
}


//设置底部view数据
extension MainViewController {
    
    func initStepView() -> StepperView{
        let frame = CGRect(x: 0, y: kScreenH - kStepViewH, width: kScreenW, height: kStepViewH)
        let stepView = StepperView(frame: frame)
        stepView.nodeCircumference = 35
        stepView.stepperColor = UIColor(red: 36/255, green: 199/255, blue: 136/255, alpha: 1)
        stepView.stepperFillColor = UIColor(red: 36/255, green: 199/255, blue: 136/255, alpha: 1)
        stepView.descTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        stepView.stepTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        stepView.stepperDataSource = self
        stepView.clearsContextBeforeDrawing = true
        stepView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.5)
        return stepView
    }
    
    func setupStepperView(action:ActionModel) {
        nodes.removeAll()
        var stepCount = 1
        let startNode = StepperNode(isSelected: true, stepText: "\(stepCount)", descText: action.startName, mode:"single")
        nodes.append(startNode)
        
        if(action.stepModel.count > 0){
            let count = (action.stepModel.count)
            for i in 0..<count {
                stepCount = stepCount + 1
                let node = StepperNode(isSelected: false, stepText: "\(stepCount)", descText: (action.stepModel[i].name), mode:action.stepModel[i].mode)
                nodes.append(node)
            }
        }
        stepCount = stepCount + 1
        let endNode = StepperNode(isSelected: false, stepText: "\(stepCount)", descText: action.endName, mode:"single")
        nodes.append(endNode)
        stepperView = initStepView()
        self.view.addSubview(stepperView!)
        
        
    }
}

extension MainViewController: StepperDataSource {
    func stepperNodeAtIndex(_ index: Int) -> StepperNode {
        return nodes[index]
    }
    
    func stepperNodeCount() -> Int {
        return nodes.count
    }
}



//提交数据
extension MainViewController {
    
    fileprivate func checkQcode(qcode:String) -> Bool{
        
        let pattern = "(\\S{2}|\\d{2})-(\\S{2}|\\d{2})-(\\S{1,9}|\\d{1,9})-(\\Sd{1,6}|\\d{1,6})"
        let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
        let results = regular.matches(in: qcode, options: .reportProgress , range: NSMakeRange(0, qcode.characters.count))
        
        if(results.count > 0) {
            return true
        }
        return false
    }
    
    func checkUser(){
        let date = NSDate()
        let timeInterval = date.timeIntervalSince1970 * 1000
        
        let timeLogin = UserDefaults.standard.double(forKey: "timeStamp")
        if(timeLogin > 0) {
            let dif = timeInterval - timeLogin
            let hour = dif / (60 * 60 * 1000)
            if(hour > kLoginInvalidTime) {
                clearUserInfo()
            }
        }
    }
    
    fileprivate func postData() {
        let url = stateMachine?.stateDataModel.url
        var params = RequestCode.getParams(array: (stateMachine?.stateDataModel.dataArray)!)
        params["startTime"] = stateMachine?.stateDataModel.startTime
        
        print(params)
        
        NetworkTools.requestData(.post, URLString:ServerUrl + url!, parameters: params ) {
            (result) in
            UserDefaults.standard.removeObject(forKey: "data")
            let json = JSON(result)
            
            let rtnMsg = json["rtn_msg"].string
            let rtnCode = json["rtn_code"].string
            
            if(rtnMsg == "OK") {
                ToastHelper.showAllTextDialog(view: self.view, message: "操作成功")
            }else {
                ToastHelper.showAllTextDialog(view: self.view, message: rtnMsg! + "---(\(rtnCode!))")
            }
        }
        
       
        
    }
}
