//
//  NSView_Extension.swift
//  audioceshi
//
//  Created by sunkai on 16/9/8.
//  Copyright © 2016年 imo. All rights reserved.
//

import Foundation
import Cocoa

extension NSView {
    func screenShotToImageFromRect()->NSImage{
        let data = self.dataWithPDFInsideRect(self.bounds)
        //视图的image
        let viewImage = NSImage(data: data)
        //获取ImageRep
        let imageRep = NSBitmapImageRep(data: (viewImage?.TIFFRepresentation)!)
        //图像压缩比设置
        let imagePros = [NSImageCompressionFactor : NSNumber(float: 1.0)]
        //data数据
        let imageData = imageRep?.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: imagePros)
        
        return viewImage!
        //文件路径
        //写入文件
        //FIXME:-1.暂时不用写入，只需要获取对应的数据
    }
}


//利用NSVisualEffectView来实现毛玻璃的效果,不过这里是纯粹添加了一个view
extension NSView {
    func insertVibrancyViewBlendingMode(mode:NSVisualEffectBlendingMode)->NSVisualEffectView{
        let vibrant = NSVisualEffectView(frame: self.bounds)
        vibrant.autoresizingMask = [NSAutoresizingMaskOptions.ViewHeightSizable,NSAutoresizingMaskOptions.ViewWidthSizable]
        vibrant.blendingMode = mode
        self.addSubview(vibrant, positioned: NSWindowOrderingMode.Below, relativeTo: nil)
        return vibrant
    }
}

extension NSView {
    var center : CGPoint {
        set{
            self.frame.origin.x = newValue.x - self.frame.size.width / 2
            self.frame.origin.y = newValue.y - self.frame.size.height / 2
        }
        get{
            var point = CGPoint()
            point.x = self.frame.origin.x + self.frame.size.width / 2
            point.y = self.frame.origin.y + self.frame.size.height / 2
            return point
        }
    }
}