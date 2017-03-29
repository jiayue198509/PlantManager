import UIKit

@IBDesignable class StepperView: UIView {
    
    var context = UIGraphicsGetCurrentContext()
    
    //// Color Declarations
    @IBInspectable var stepperColor: UIColor = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
    @IBInspectable var stepperFillColor: UIColor = UIColor(red: 0.098, green: 0.655, blue: 0.510, alpha: 1.000)

    @IBInspectable var stepperColorNull: UIColor = UIColor(red: 0.400, green: 0.400, blue: 0.400, alpha: 1.000)
    @IBInspectable var stepperFillColorNull: UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.000)
    
    @IBInspectable var leftTextColor: UIColor = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
    @IBInspectable var rightTextColor: UIColor = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
    
    @IBInspectable var leftTextFont: UIFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    @IBInspectable var rightTextFont: UIFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    
    @IBInspectable var nodeCircumference: Double = 47;
    @IBInspectable var linkLength: Double = 40;
    @IBInspectable var linkThickness: Double = 5;
    @IBInspectable var nodeStrokeWidth: Double = 5;
    
    @IBInspectable var innerNodeOffset: Double = 11;
    
    @IBOutlet weak var stepperDataSource: NSObject?
    
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
        
        for i in 0..<nodeCount {
            
            let xOffset = Double(i) * (nodeCircumference + linkLength)
            
            let node = dataSource.stepperNodeAtIndex(i)
            
            drawNode(node, x: CGFloat(xOffset), y: rect.origin.y, width: rect.width, height: rect.height, isLast: (i == (nodeCount - 1)))
        }
    }
    
    func drawDemoData(_ rect: CGRect) {
        let nodes: [StepperNode] = [
            StepperNode(isSelected: true, leftText: "10:30pm", rightText: "One"),
            StepperNode(isSelected: true, leftText: "10:40pm", rightText: "Two"),
            StepperNode(isSelected: true, leftText: "11:00pm", rightText: "Three"),
            StepperNode(isSelected: false, leftText: "11:30pm", rightText: "Four"),
            StepperNode(isSelected: false, leftText: "12:30pm", rightText: "Five")
        ]
        
        for i in 0..<nodes.count {
            
            let xOffset = Double(i) * (self.nodeCircumference + linkLength)
            
            drawhorizontalNode(nodes[i], x: CGFloat(xOffset), y: rect.origin.y, width: rect.width, height: rect.height, isLast: (i == (nodes.count - 1)))
        }
    }
    
    func drawNode(_ node: StepperNode, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isLast: Bool) {
        
        let center: Double = Double(width) / 2.0;
        
        //// Node Drawing
        
        let nodeX = CGFloat(center - (nodeCircumference / 2))
        let nodeY = y + CGFloat(linkThickness / 2.0)
        
        let nodePath = UIBezierPath(ovalIn: CGRect(x: nodeX, y: nodeY, width: CGFloat(nodeCircumference), height: CGFloat(nodeCircumference)))
        UIColor.white.setFill()
        nodePath.fill()
        if(node.isSelected) {
            stepperColor.setStroke()
        }else{
            stepperColorNull.setStroke()
        }
        nodePath.lineWidth = CGFloat(linkThickness)
        nodePath.stroke()
        
        if(node.isSelected) {
            //// InnerNode Drawing
            let innerNodeX = CGFloat(center - ((nodeCircumference - innerNodeOffset) / 2))
            let innerNodeY = nodeY + CGFloat(innerNodeOffset / 2)
            let innerWidth = CGFloat(nodeCircumference - innerNodeOffset)
            
            let innerNodePath = UIBezierPath(ovalIn: CGRect(x: innerNodeX, y: innerNodeY, width: innerWidth, height: innerWidth))
            stepperFillColor.setFill()
            innerNodePath.fill()
        }
        
        if(node.leftText != "") {
            
            let leftTextWidth = CGFloat(center - nodeCircumference)
            
            let leftLabelRect = CGRect(x: 0, y: nodeY, width: leftTextWidth, height: CGFloat(nodeCircumference))
            let leftLabelTextContent = NSString(string: node.leftText)
            let leftLabelStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            leftLabelStyle.alignment = NSTextAlignment.right
            
            let leftLabelFontAttributes = [NSFontAttributeName: leftTextFont, NSForegroundColorAttributeName: leftTextColor, NSParagraphStyleAttributeName: leftLabelStyle] as [String : Any]
            
            let leftLabelTextHeight: CGFloat = leftLabelTextContent.boundingRect(with: CGSize(width: leftLabelRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: leftLabelFontAttributes, context: nil).size.height
            context?.saveGState()
            context?.clip(to: leftLabelRect);
            leftLabelTextContent.draw(in: CGRect(x: leftLabelRect.minX, y: leftLabelRect.minY + (leftLabelRect.height - leftLabelTextHeight) / 2, width: leftLabelRect.width, height: leftLabelTextHeight), withAttributes: leftLabelFontAttributes)
            context?.restoreGState()
        }
        
        if(node.rightText != "") {
            
            let rightTextX = CGFloat(center + nodeCircumference)
            let rightTextWidth = width - rightTextX
            
            let rightLabelRect = CGRect(x: rightTextX, y: nodeY, width: rightTextWidth, height: CGFloat(nodeCircumference))
            let rightLabelTextContent = NSString(string: node.rightText)
            let rightLabelStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            rightLabelStyle.alignment = NSTextAlignment.left
            
            let rightLabelFontAttributes = [NSFontAttributeName: rightTextFont, NSForegroundColorAttributeName: rightTextColor, NSParagraphStyleAttributeName: rightLabelStyle] as [String : Any]
            
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
        let linkX = CGFloat(center - (linkThickness / 2))
        let linkY = nodeY + CGFloat(nodeCircumference)
        
        let linkPath = UIBezierPath(rect: CGRect(x: linkX, y: linkY, width: CGFloat(linkThickness), height: CGFloat(linkLength)))
        stepperColor.setFill()
        linkPath.fill()
        
    }
    
    func drawhorizontalNode(_ node: StepperNode, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isLast: Bool) {
        let center: Double = Double(height) / 2.0;
        
        //// Node Drawing
        
        let nodeY = CGFloat(center - (nodeCircumference / 2))
        let nodeX = x + CGFloat(linkThickness / 2.0)
        
        let nodePath = UIBezierPath(ovalIn: CGRect(x: nodeX, y: nodeY, width: CGFloat(nodeCircumference), height: CGFloat(nodeCircumference)))
        UIColor.white.setFill()
        nodePath.fill()
        if(node.isSelected) {
            stepperColor.setStroke()
        }else{
            stepperColorNull.setStroke()
        }
        nodePath.lineWidth = CGFloat(linkThickness)
        nodePath.stroke()
        
        let innerNodeX = CGFloat(center - ((nodeCircumference - innerNodeOffset) / 2))
        let innerNodeY = nodeY + CGFloat(innerNodeOffset / 2)
        let innerWidth = CGFloat(nodeCircumference - innerNodeOffset)
        
        let innerNodePath = UIBezierPath(ovalIn: CGRect(x: innerNodeX, y: innerNodeY, width: innerWidth, height: innerWidth))
        if(node.isSelected) {
            stepperFillColor.setFill()
            
        }else{
            stepperFillColorNull.setFill()
        }
        innerNodePath.fill()
        
//        if(node.leftText != "") {
//            
//            let leftTextWidth = CGFloat(center - nodeCircumference)
//            
//            let leftLabelRect = CGRect(x: 0, y: nodeY, width: leftTextWidth, height: CGFloat(nodeCircumference))
//            let leftLabelTextContent = NSString(string: node.leftText)
//            let leftLabelStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//            leftLabelStyle.alignment = NSTextAlignment.right
//            
//            let leftLabelFontAttributes = [NSFontAttributeName: leftTextFont, NSForegroundColorAttributeName: leftTextColor, NSParagraphStyleAttributeName: leftLabelStyle] as [String : Any]
//            
//            let leftLabelTextHeight: CGFloat = leftLabelTextContent.boundingRect(with: CGSize(width: leftLabelRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: leftLabelFontAttributes, context: nil).size.height
//            context?.saveGState()
//            context?.clip(to: leftLabelRect);
//            leftLabelTextContent.draw(in: CGRect(x: leftLabelRect.minX, y: leftLabelRect.minY + (leftLabelRect.height - leftLabelTextHeight) / 2, width: leftLabelRect.width, height: leftLabelTextHeight), withAttributes: leftLabelFontAttributes)
//            context?.restoreGState()
//        }
        
        if(node.rightText != "") {
            
            let rightTextY = CGFloat(center + nodeCircumference)
            let rightTextWidth = 60.0
            
            let rightLabelRect = CGRect(x: nodeX, y: rightTextY, width: CGFloat(rightTextWidth), height: CGFloat(nodeCircumference))
            let rightLabelTextContent = NSString(string: node.rightText)
            let rightLabelStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            rightLabelStyle.alignment = NSTextAlignment.left
            
            let rightLabelFontAttributes = [NSFontAttributeName: rightTextFont, NSForegroundColorAttributeName: rightTextColor, NSParagraphStyleAttributeName: rightLabelStyle] as [String : Any]
            
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
        stepperColor.setFill()
        linkPath.fill()
    }
    
}

