//
//  FlashWindow.swift
//  audioceshi
//
//  Created by sunkai on 16/9/7.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa

class FlashWindow: NSWindow {

    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        //基本参数的设置
        self.styleMask = NSBorderlessWindowMask //无边界
        self.opaque = false //透明
        self.backgroundColor = NSColor.whiteColor() //背景颜色
        self.hasShadow = false //没有阴影
        self.movable = false  //点击背景和标题可以拖动
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeKeyWindow: Bool{
        return true
    }
    
    override var canBecomeMainWindow: Bool{
        return true
    }
    
}
