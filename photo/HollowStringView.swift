//
//  HollowStringView.swift
//  audioceshi
//
//  Created by sunkai on 16/9/2.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa

protocol AnimationCompletionDelegate : NSObjectProtocol {
    func animationCompletion()
}

let BackGroundColor = NSColor(red: 255 / 255.0, green: 109 / 255.0, blue: 86 / 255.0, alpha: 0.9).CGColor
let OriginalForGroundColor = NSColor(red: 229 / 255.0, green: 229 / 255.0, blue: 229 / 255.0, alpha: 0.2)
let OriginalStrokeColor = NSColor(red: 204 / 255.0, green: 204 / 255.0, blue: 204 / 255.0, alpha: 0.2)
let NewForgroundColor = NSColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.0)
let NewStrokeColor = NSColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.0)

class HollowStringView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        //首先绘制背景颜色
        self.wantsLayer = true
        self.layer?.backgroundColor = BackGroundColor
        //绘制字符串
        let style = NSMutableParagraphStyle()
        style.alignment = .Center
        style.lineBreakMode = .ByCharWrapping //以字符换行
        let font = NSFont(name: "Helvetica", size:dirtyRect.size.height - 5)
        let attributeString  = NSMutableAttributedString(string: self.contentString!)
        let attributeDicOriginal = [NSFontAttributeName : font!,//字体
                            NSParagraphStyleAttributeName : style,//绘制样式
                            NSForegroundColorAttributeName : OriginalForGroundColor ,//填充色
                            NSStrokeColorAttributeName: OriginalStrokeColor,//描边色
                            NSStrokeWidthAttributeName : -3, //描边线宽,这里必须设置为负数，否则文字颜色就会没有效果
                            NSKernAttributeName : 10, //文字间距
                            ]
        let attributeDicAnimation = [NSFontAttributeName : font!,
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : NewForgroundColor,
            NSStrokeColorAttributeName:NewStrokeColor,
            NSStrokeWidthAttributeName : -3,
            NSKernAttributeName : 10,
        ]
        let lenth  = attributeString.length
        attributeString.addAttributes(attributeDicOriginal, range: NSRange(location: 0, length: lenth))
        if self.isAnimation {
            //执行动画时的属性设置
            attributeString.addAttributes(attributeDicAnimation, range: NSRange(location: self.location!, length: 1))
            PlaySoundManager.shareManager.playSound()
        }
        attributeString.drawInRect(self.bounds)
    }
    
    weak var delegete : AnimationCompletionDelegate? 
    var isAnimation : Bool = false
    var resources = NSMutableArray() //用于存放声音资源
    let flashwindow = FlashWindow(contentRect: (NSScreen.screens()?.first?.frame)!, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.Buffered, defer: true) //模拟闪光灯的闪屏
    
    var contentString : String? {
        willSet{
            //一旦输入文字，并且不是空字符串，就需要重新绘制
            if newValue != nil && newValue != "" {
                self.setNeedsDisplayInRect(self.bounds)
            }
        }
    }
  
    
    var location : NSInteger? = 0 {
        willSet{
            //默认值是0，表示应用从0开始
            if newValue != nil{
                 if newValue != 0{
                    self.runAnimation()
                 }else{
                    if self.delegete != nil {
                        //添加一个闪烁的背景视图
                        self.addBackgroundWindowAnimation()
                    }
                }
            }
        }
    }
    
    //重写属性，更改为不透明的
    override var opaque: Bool {
        return false
    }
   
    //添加闪烁的背景视图，同时还要播放另外一个音频
    func addBackgroundWindowAnimation(){
        flashwindow.orderFrontRegardless()
        self.performSelector(#selector(self.removeGroundWindow(_:)), withObject: flashwindow, afterDelay: 0.2)
    }
    
    func removeGroundWindow(window:NSWindow){
        window.orderOut(self)
        //这个方法是只是进行了隐藏而不是释放，如果说使用close的话，就是释放，但是这里如果采用close就crash
        //移除掉窗口之后，才会进行拍照操作
        self.delegete?.animationCompletion()
    }
    func runAnimation(){
        //这里再次设置一下播放器的初始值
        PlaySoundManager.shareManager.createPlayer(self.resources[0] as! SoundModel)
        //这里需要设置一个标志位
        self.isAnimation = true
        self.setNeedsDisplayInRect(self.bounds)
        self.performSelector(#selector(self.redrawView), withObject: nil, afterDelay: 0.5 + PlaySoundManager.shareManager.playTime!)
      
    }
    
    func redrawView(){
        //在重绘完成之后，重新赋值
        if self.location! < 2 {
            self.location = self.location! + 1
        }else{
            self.location = 0
            self.isAnimation = false
            self.setNeedsDisplayInRect(self.bounds)
        }
    }
    
    init(content:String,frame:NSRect){
        super.init(frame: frame)
        self.contentString = content
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clearColor().CGColor
        //初始化声音播放，会获取当前要播放的音频长度，然后在创建播放器的时候就可以获得数值
        self.resources = PlaySoundManager.shareManager.getResource(["CESHI04.caf","CESHI08.caf"])!
        PlaySoundManager.shareManager.createPlayer(self.resources[0] as! SoundModel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillMoveToSuperview(newSuperview: NSView?) {
        super.viewWillMoveToSuperview(newSuperview)
        self.location = 0
    }
    
}
