//
//  HorizonLayout.swift
//  photo
//
//  Created by sunkai on 16/9/19.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa

class HorizonLayout: JNWCollectionViewGridLayout {

    override func scrollDirection() -> JNWCollectionViewScrollDirection {
        return JNWCollectionViewScrollDirection.Horizontal
    }
    
}
