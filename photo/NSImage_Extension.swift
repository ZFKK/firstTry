//
//  NSImage_Extension.swift
//  audioceshi
//
//  Created by sunkai on 16/9/3.
//  Copyright © 2016年 imo. All rights reserved.
//

import Foundation
import Cocoa

//添加图片内容扩展,用于存储，返回的是保存所在的路径的url
extension NSImage {
    func saveToCache(data:NSData,tag:NSInteger)->(NSURL,Bool){
        var isSuccess : Bool = false
        var filePath : String?
        //首先创建一个路径，建立文件夹
        let cachePath = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.CachesDirectory,
            NSSearchPathDomainMask.UserDomainMask, true).first!
        let directoryPath = (cachePath as NSString).stringByAppendingPathComponent("自拍头像缓存/Photos-Cache")
        let fileManager = NSFileManager.defaultManager()
        do {
           try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
            // 保存图片到临时存储
            filePath = (directoryPath as NSString).stringByAppendingPathComponent("/" + "ScreenShot\(tag)" + ".jpeg")
            //FIXME:-3.这里的名字最好加上日期和一个固定的，以及编号，需要参考一下NSDate的一些写法，已经存在的
           isSuccess =  fileManager.createFileAtPath(filePath!, contents: data, attributes: [:]);
        }catch let error as NSError{
            Swift.print("创建照片文件夹失败\(error.domain)")
        }
        return (NSURL(fileURLWithPath: filePath!),isSuccess)
    }
}

extension NSImage {
    //转换为CIImage
    static func transformToCiimage(image:NSImage)->CIImage{
        let tiffData = image.TIFFRepresentation
        let bitmapRep = NSBitmapImageRep(data: tiffData!)
        let ciimage = CIImage(bitmapImageRep: bitmapRep!)
        return ciimage!
    }
    
    //转化成CGImage
    static func transformToCgimage(image:NSImage)->CGImage{
        let tiffData = image.TIFFRepresentation
        var cgimageRef : CGImageRef?
        if tiffData != nil {
            let imageSource = CGImageSourceCreateWithData(tiffData!, nil)
            cgimageRef = CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)
        }
        return cgimageRef!
    }
    
    //添加类方法，这里是个混合的模糊滤镜
    static func blurryImage(image:NSImage,withMaskImage maskImage:NSImage,blurLevel:CGFloat,rect:NSRect)->NSImage?{
        //创建属性
        let ciimage = NSImage.transformToCiimage(image)
        let filter = CIFilter(name: "CIMaskedVariableBlur")
        //指定过滤照片
        filter?.setValue(ciimage, forKey: kCIInputImageKey)
        let cgimage = NSImage.transformToCgimage(maskImage)
        let mask = CIImage(CGImage: cgimage)
        //指定Mask image
        filter?.setValue(mask, forKey: "inputMask")
        //指定模糊值,默认为10，范围从0到100
        filter?.setValue(blurLevel, forKey: "inputRadius")
        
        //生成图片
        let context = CIContext()
        //创建输出
        let result = filter?.valueForKey(kCIOutputImageKey) as? CIImage
        var newCgimage : CGImage?
        var newNsimage : NSImage?
        
        //FIXME:-2.比较耗时操作，所以在子线程进行获取
        newCgimage = context.createCGImage(result!, fromRect: (result?.extent)!)
        newNsimage = NSImage(CGImage: newCgimage!, size: rect.size)
        return newNsimage
    }
    
    //纯粹的高斯模糊效果
    static func blurGassurWithImage(image:NSImage,blurLevel:CGFloat,rect:NSRect)->NSImage{
        var newCgimage : CGImage?
        var newNsimage : NSImage?
        let ciimage = NSImage.transformToCiimage(image)
        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": blurLevel])
        filter?.setValue(ciimage, forKey: "inputImage")
        let outImage = filter?.outputImage
        let context = CIContext()
        newCgimage = context.createCGImage(outImage!, fromRect: outImage!.extent)
        newNsimage = NSImage(CGImage: newCgimage!, size: rect.size)
        return newNsimage!
    }
    
    //图片进行裁剪和保存
    func resize(newsize:NSSize)->NSImage{
        let newWidth  = newsize.width / 2
        let newHeigt = newsize.height / 2
        let resizeImage = NSImage(size: NSSize(width: newWidth, height: newHeigt))
        let originalSize = self.size
        resizeImage.lockFocus()
        self.drawInRect(NSRect(x: 0, y: 0, width: newWidth, height: newHeigt), fromRect:NSRect(x: 0, y: 0, width: originalSize.width, height: originalSize.height), operation: .CompositeSourceOver, fraction: 1.0)
        resizeImage.unlockFocus()
        return resizeImage
    }
    
    //保存在某条路径
    func saveAtPath(path:String){
        var imageData = self.TIFFRepresentation
        let imageRep = NSBitmapImageRep(data: imageData!)
        let imageProps = [NSImageCompressionFactor : NSNumber(float: 1.0)]
        imageData = imageRep?.representationUsingType(.NSPNGFileType, properties: imageProps)
        imageData?.writeToFile(path, atomically: false)
    }
}

