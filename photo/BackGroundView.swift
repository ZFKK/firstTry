//
//  BackGroundView.swift
//  audioceshi
//
//  Created by sunkai on 16/9/2.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa

class BackGroundView: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    @IBOutlet var myview: NSView!
    @IBOutlet weak var infoText: NSTextField!
    @IBOutlet weak var animationView: LoadingView!
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initFormXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initFormXib()
        
    }
    
    func initFormXib(){
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = NSNib(nibNamed: "BackGroundView", bundle: bundle)
        if nib?.instantiateWithOwner(self, topLevelObjects: nil) == true{
            myview.frame = bounds
            addSubview(myview)
        }
    }

}
