//
//  PlaySoundManager.swift
//  audioceshi
//
//  Created by sunkai on 16/9/3.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa

//全局变量的单例方法
private let shareManage  = PlaySoundManager()

class PlaySoundManager : NSObject{

    //类属性
    class var shareManager : PlaySoundManager {
        return shareManage
    }
    
    var audioPlayer : AVAudioPlayer?//播放器
    var resourcesModels : NSMutableArray? //存放资源模型
    var playTime : NSTimeInterval? //音频播放长度
    var isFinished : Bool = false //播放完毕
    var musicIndex : NSInteger? = 0 //播放音乐的索引,这里暂时没有用到，仅仅留作备用
    
    

    //修改当前的音乐资源，根据序列来进行播放
    func changeSoundResourceIndex(index:NSInteger){
        let models = self.resourcesModels
        if index > 0 && index <= (self.resourcesModels?.count)! - 1 {
            if self.audioPlayer != nil {
                self.audioPlayer = nil
            }
            self.createPlayer((models?.objectAtIndex(index))! as! SoundModel)
        }
    }
    
    //获取外部资源
    func getResource(resources:[String])->NSMutableArray?{
        //先要清空原先的数据，假如存在的话
        if self.resourcesModels != nil {
            self.resourcesModels?.removeAllObjects()
        }
        let soundmodels = NSMutableArray()
        for soundResource in resources {
            let model = SoundModel(filename: soundResource)
            soundmodels.addObject(model)
        }
        self.resourcesModels = soundmodels
        return soundmodels
    }
    
    //播放
    func playSound(){
        if self.audioPlayer?.playing == false {
            self.audioPlayer?.play()
            self.isFinished = false
        }
    }
    
    //暂停
    func pauseSound(){
        if self.audioPlayer?.playing == false {
            self.audioPlayer?.pause()
        }
    }
    
    //停止
    func stopSound(){
        self.audioPlayer?.stop()
        self.isFinished = true
    }
    //重新写的初始化播放器
    func createPlayer(sound:SoundModel){
         //这里不再判断是否为空，只要调用，就会创建一个新的播放器
            if sound.fileName != nil {
                let soundResourceStr = NSBundle.mainBundle().pathForResource(sound.fileName, ofType: nil)
                let soundResourceUrl = NSURL(fileURLWithPath: soundResourceStr!)
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOfURL: soundResourceUrl)
                    self.playTime = self.audioPlayer?.duration
                    //一些参数设置
                    self.audioPlayer?.volume = 1.0
                    self.audioPlayer?.numberOfLoops = 0
                    //不循环,只是播放一次
                    self.isFinished = false
                }catch let error as NSError{
                    Swift.print("初始化失败,具体原因是\(error.domain)")
                }
            }
            self.audioPlayer?.delegate = self
            self.audioPlayer?.prepareToPlay()
            //加载文件到缓存
    }
}

extension PlaySoundManager :  AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        //音乐播放完毕,然后触发另一个view的动画么???
        self.isFinished = true
    }
}

//声音模型
class SoundModel : NSObject{
    var fileName : String?
    init(filename:String){
        self.fileName = filename
    }
}
