//
//  BottomView.swift
//  audioceshi
//
//  Created by sunkai on 16/9/2.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa
import Quartz

protocol disPlayImagesAsyncDelegate : NSObjectProtocol {
    func displayImages(view:BottomView,imageUrl:NSURL)
}

//如果要使用IKImage,需要使用两个框架,数据源和代理都是底部的view
class BottomView: NSVisualEffectView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    //重写属性，更改为透明的
    override var opaque: Bool {
        return false
    }
        
    var images = NSMutableArray() //存放已经拍的照片
    var tempImages = NSMutableArray() //临时存放已经拍的照片
    weak var delegate : disPlayImagesAsyncDelegate? //用于在VC中显示照片
    
    @IBOutlet var myview: NSView!
    @IBOutlet weak var collectionview: NSCollectionView!
    @IBOutlet weak var scrollview: NSScrollView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.SetUI()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.SetUI()
    }
    
    //初始化
    func SetUI(){
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = NSNib(nibNamed: "BottomView", bundle: bundle)
        if nib?.instantiateWithOwner(self, topLevelObjects: nil) == true{
            myview.frame = bounds
            myview.wantsLayer = true
            myview.layer?.backgroundColor = NSColor.clearColor().CGColor
            addSubview(myview)
            //基础属性设置
            settingsOfBasicProperties()
        }
    }
    
    func settingsOfBasicProperties(){
        
        scrollview.wantsLayer = true
        scrollview.layer?.backgroundColor = NSColor.clearColor().CGColor
        collectionview.wantsLayer = true
        collectionview.layer?.backgroundColor = NSColor.clearColor().CGColor
        if self.images.count > 0 {
            self.images.removeAllObjects()
        }
       
    }

    //加载照片，包括进行更新
    func updataDatasource(){
        //把临时数组中的内容转移
        self.images.addObjectsFromArray(self.tempImages.mutableCopy() as! [AnyObject])
        Swift.print("1照片总共的个数是\(self.images.count)")
        //清空临时数组
        self.tempImages.removeAllObjects()
        //加载图片浏览器进行重新显示
    }
    
    //添加单张照片
    func addAnImageWithUrl(url:NSURL){
        var addObject = false
        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(url.path!)
                //检查是不是package
            if NSFileTypeDirectory == fileAttributes[NSFileType] as! String{
                //判断是否是文件
                if  NSWorkspace.sharedWorkspace().isFilePackageAtPath(url.path!) == false {
                    addObject = true
                }
            }else{
                addObject = true
            }
            
            if addObject == true {
                //添加模型或者说是一个url
                let model = ImageModel(url: url)
                self.tempImages.addObject(model)
            }
        }catch let error as NSError{
            Swift.print("参数路径/文件错误，返回属性失败,\(error.domain)")
        }
    }
    
}






//数据模型
class ImageModel {
    
    var url : NSURL?
    var image : NSImage?
    
    init(name:String){
        self.image = NSImage(named: name)
    }
    
    init(url:NSURL){
        self.url = url
        let imageSource = CGImageSourceCreateWithURL(url.absoluteURL, nil)
        if let imageSource = imageSource {
            guard CGImageSourceGetType(imageSource) != nil else { return }
            self.image = getThumbnailImage(imageSource)
        }
    }
    
    private func getThumbnailImage(imageSource: CGImageSource) -> NSImage? {
        let thumbnailOptions = [
            String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
            String(kCGImageSourceThumbnailMaxPixelSize): 160
        ]
        guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions) else { return nil}
        return NSImage(CGImage: thumbnailRef, size: NSSize.zero)
    }
    
}



