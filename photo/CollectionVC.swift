//
//  CollectionVC.swift
//  photo
//
//  Created by sunkai on 16/9/19.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa

//标识符
let identifier = "CELL"


class CollectionVC: NSViewController {

    var images : NSArray = ["19.jpg","20.jpg","21.jpg","22.jpg","23.jpg","24.jpg","25.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBOutlet var collectionview: JNWCollectionView!
    
    override func awakeFromNib() {
         //新建子类的滚动布局，重写布局方向，设置为水平方向的
        let gridLayout = HorizonLayout()
        gridLayout.delegate = self
        gridLayout.verticalSpacing = 10
        
        self.collectionview.drawsBackground = true
        self.collectionview.backgroundColor = NSColor.clearColor()
        //设置背景色为无色
        
        self.collectionview.horizontalScrollElasticity = .Allowed
        self.collectionview.verticalScrollElasticity = .Allowed
        //设置滚动弹性
        
        self.collectionview.collectionViewLayout = gridLayout
        self.collectionview.dataSource = self
        self.collectionview.animatesSelection = true
        //设置基本属性
        
        self.collectionview.registerClass(GridCell.classForCoder(), forCellWithReuseIdentifier: identifier)
        self.collectionview.reloadData()
        //注册单元类型
        
        
    }
}

//代理方法
extension CollectionVC : JNWCollectionViewDataSource,JNWCollectionViewGridLayoutDelegate {

    func collectionView(collectionView: JNWCollectionView!, numberOfItemsInSection section: Int) -> UInt {
        return 7
    }
    
    func numberOfSectionsInCollectionView(collectionView: JNWCollectionView!) -> Int {
        return 1
    }
    
    func collectionView(collectionView: JNWCollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> JNWCollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithIdentifier(identifier) as! GridCell
        cell.image = NSImage(named:self.images[indexPath.jnw_item] as! String )
        return cell
    }
    
    func sizeForItemInCollectionView(collectionView: JNWCollectionView!) -> CGSize {
        return CGSize(width: 100, height: 60)
    }
}