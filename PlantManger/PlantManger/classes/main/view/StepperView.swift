import UIKit

@IBDesignable class StepperView: UIView {
    
    var context = UIGraphicsGetCurrentContext()
    
    //// Color Declarations
    @IBInspectable var stepperColor: UIColor = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
    @IBInspectable var stepperFillColor: UIColor = UIColor(red: 0.098, green: 0.655, blue: 0.510, alpha: 1.000)

    @IBInspectable var stepperColorNull: UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.000)
    @IBInspectable var stepperFillColorNull: UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.000)
    
    @IBInspectable var descTextColor: UIColor = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
    @IBInspectable var stepTextColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.000)
    
    @IBInspectable var descTextFont: UIFont = UIFont.systemFont(ofSize: 13)
    @IBInspectable var stepTextFont: UIFont = UIFont.systemFont(ofSize: 17)
    
    @IBInspectable var nodeCircumference: Double = 80;
    @IBInspectable var linkLength: Double = 40;
    @IBInspectable var linkThickness: Double = 5;
    @IBInspectable var nodeStrokeWidth: Double = 1;
    @IBInspectable var descLabelHeight: Double = 20;
    
    @IBInspectable var innerNodeOffset: Double = 11;
    
    @IBOutlet weak var stepperDataSource: NSObject?
    
    var rectOri:CGRect = CGRect.zero
    
    override func draw(_ rect: CGRect) {
        
        #if TARGET_INTERFACE_BUILDER
            self.drawDemoData(rect)
            return
        #endif
        
        if(stepperDataSource == nil) {
            return
        }
        
        let dataSource = stepperDataSource as! StepperDataSource
        
        let nodeCount = dataSource.stepperNodeCount()
        
        let width = (Double(nodeCount) * nodeCircumference) + Double(nodeCount - 1) * linkLength
        let inset = (rect.width - CGFloat(width))/2

        for i in 0..<nodeCount {
            
            let xOffset = Double(inset) + Double(i) * (nodeCircumference + linkLength)
            
            let node = dataSource.stepperNodeAtIndex(i)
            
            drawHorizontalNode(node, x: CGFloat(xOffset), y: rect.origin.y, width: rect.width, height: rect.height, isLast: (i == (nodeCount - 1)))
        }
    }
    
    func drawDemoData(_ rect: CGRect) {
        let nodes: [StepperNode] = [
            StepperNode(isSelected: true, stepText: "1", descText: "开始"),
            StepperNode(isSelected: true, stepText: "2", descText: "打开阀门"),
            StepperNode(isSelected: true, stepText: "3", descText: "浇水"),
            StepperNode(isSelected: false, stepText: "4", descText: "关闭阀门"),
            StepperNode(isSelected: false, stepText: "5", descText: "结束")
        ]
        
        let width = (Double(nodes.count) * nodeCircumference) + Double(nodes.count - 1) * linkLength
        let inset = (rect.width - CGFloat(width))/2
        
        
        for i in 0..<nodes.count {
            
            let xOffset = Double(inset) + Double(i) * (self.nodeCircumference + linkLength)
            
            drawHorizontalNode(nodes[i], x: CGFloat(xOffset), y: rect.origin.y, width: rect.width, height: rect.height, isLast: (i == (nodes.count - 1)))
        }
    }
    
    func drawHorizontalNode(_ node: StepperNode, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isLast: Bool) {
        let center: Double = Double(height) / 2.0;
        
        let nodeY = CGFloat(center - (nodeCircumference / 2))
        let nodeX = x + CGFloat(nodeStrokeWidth / 2.0)
        
        let nodePath = UIBezierPath(ovalIn: CGRect(x: nodeX, y: nodeY, width: CGFloat(nodeCircumference), height: CGFloat(nodeCircumference)))
        
        if(node.isSelected) {
            UIColor.init(red: 36/255, green: 199/255, blue: 136/255, alpha: 1).setFill()
            nodePath.fill()
            stepperColor.setStroke()
        }else{
            UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.000).setFill()
            nodePath.fill()
            stepperColorNull.setStroke()
        }
        nodePath.lineWidth = CGFloat(nodeStrokeWidth)
        nodePath.stroke()
        
        if(node.stepText != "") {
            
            let stepLabelRect = CGRect(x: nodeX, y: nodeY, width: CGFloat(nodeCircumference), height: CGFloat(nodeCircumference))
            let stepLabelTextContent = NSString(string: node.stepText)
            let stepLabelStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            stepLabelStyle.alignment = NSTextAlignment.center
            
            let rightLabelFontAttributes = [NSFontAttributeName: stepTextFont, NSForegroundColorAttributeName: stepTextColor, NSParagraphStyleAttributeName: stepLabelStyle] as [String : Any]
            
            let rightLabelTextHeight: CGFloat = stepLabelTextContent.boundingRect(with: CGSize(width: stepLabelRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: rightLabelFontAttributes, context: nil).size.height
            context?.saveGState()
            context?.clip(to: stepLabelRect);
            
            stepLabelTextContent.draw(in: CGRect(x: stepLabelRect.minX, y: stepLabelRect.minY + (stepLabelRect.height - rightLabelTextHeight) / 2, width: stepLabelRect.width, height: rightLabelTextHeight), withAttributes: rightLabelFontAttributes)
            context?.restoreGState()
        }
        
        if(node.descText != "") {
            let descTextY = CGFloat(center + nodeCircumference/2)
            let descTextWidth = 70.0
            
            let rightLabelRect = CGRect(x: nodeX + CGFloat(nodeCircumference/2) - CGFloat(descTextWidth/2), y: descTextY, width: CGFloat(descTextWidth), height: CGFloat(descLabelHeight))
            let rightLabelTextContent = NSString(string: node.descText)
            let rightLabelStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            rightLabelStyle.alignment = NSTextAlignment.center
            
            let rightLabelFontAttributes = [NSFontAttributeName: descTextFont, NSForegroundColorAttributeName: descTextColor, NSParagraphStyleAttributeName: rightLabelStyle] as [String : Any]
            
            let rightLabelTextHeight: CGFloat = rightLabelTextContent.boundingRect(with: CGSize(width: rightLabelRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: rightLabelFontAttributes, context: nil).size.height
            context?.saveGState()
            context?.clip(to: rightLabelRect);
            
            rightLabelTextContent.draw(in: CGRect(x: rightLabelRect.minX, y: rightLabelRect.minY + (rightLabelRect.height - rightLabelTextHeight) / 2, width: rightLabelRect.width, height: rightLabelTextHeight), withAttributes: rightLabelFontAttributes)
            context?.restoreGState()
        }
        
        
        if(isLast) {
            return
        }
        
        //// Link Drawing
        let linkY = CGFloat(center - (linkThickness / 2))
        let linkX = nodeX + CGFloat(nodeCircumference)
        
        let linkPath = UIBezierPath(rect: CGRect(x: linkX, y: linkY, width: CGFloat(linkLength), height: CGFloat(linkThickness)))
        if(node.isSelected) {
            stepperColor.setFill()
            linkPath.fill()
        }else{
            stepperColorNull.setFill()
            linkPath.fill()
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        let views = self.subviews
        for view in views {
            view.removeFromSuperview()
        }
    }
    
}

