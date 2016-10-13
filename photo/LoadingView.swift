//
//  LoadingView.swift
//  audioceshi
//
//  Created by sunkai on 16/9/2.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa

class LoadingView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    var  BottomLayerWidth = 5
    var  BottomLayerHeight = 5
    
    var  caReplicatorlayer : CAReplicatorLayer?
    var  subLayer : CAShapeLayer?
    var  subBottomLayer : CALayer?
    var  imagegroundcolor : CGColor?{
        willSet{
            if newValue != nil {
                self.subBottomLayer?.backgroundColor = newValue!
            }
        }
    }
    var  margin : CGFloat?{
        willSet{
            if newValue != nil && newValue != 15{
                self.caReplicatorlayer?.instanceTransform = CATransform3DMakeTranslation(newValue!, 0, 0)
            }
        }
    }
    
    //中间的图案间隔
   
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setUp()
    }
    
    func setUp(margin:CGFloat = 15,color:CGColor = NSColor(red: 0, green: 255, blue: 255, alpha: 1).CGColor){
        
        self.wantsLayer = true
        //这个一定要写，并且一般不是在drawRect中写
        self.layer?.anchorPoint = NSPoint(x: 0.5, y: 0.5)
        self.layer?.position = NSPoint(x: self.center.x, y: self.center.y)
        
        self.caReplicatorlayer = CAReplicatorLayer()
        //复制个数
        self.caReplicatorlayer?.instanceCount = 3
        //赋值的延时间隔
        self.caReplicatorlayer?.instanceDelay = 0.3
        //复制的层之间的间隔
        self.caReplicatorlayer?.instanceTransform = CATransform3DMakeTranslation(margin, 0, 0) //这里的margin提供默认值
        
        //创建子的层
        self.subLayer = CAShapeLayer()
        self.subLayer?.frame = NSRect(x: 0, y: 0, width: BottomLayerWidth, height: BottomLayerHeight)
        
        //绘制轨迹
        let path = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, (self.subLayer?.bounds)!)
        self.subLayer?.path = path
        
        self.subBottomLayer = CALayer()
        self.subBottomLayer?.frame = NSRect(x: 0, y: 0, width: BottomLayerWidth, height: BottomLayerHeight)
        self.subBottomLayer?.backgroundColor = color //这里的颜色也是提供默认值
        self.subBottomLayer?.mask = self.subLayer
        self.subBottomLayer?.masksToBounds = true
        
        
        //子层的动画
        let keyanimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyanimation.beginTime = CACurrentMediaTime()
        keyanimation.values = [(0.7),(0.5),(0.2),(0.0)]
        keyanimation.duration = 0.7
        keyanimation.autoreverses = true
        keyanimation.repeatCount = Float(INT_MAX)
        keyanimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.subBottomLayer?.addAnimation(keyanimation, forKey: "scaleanimation")
        
        self.caReplicatorlayer?.addSublayer(subBottomLayer!)
        
        self.layer?.addSublayer(self.caReplicatorlayer!)
        
    }
    
}
