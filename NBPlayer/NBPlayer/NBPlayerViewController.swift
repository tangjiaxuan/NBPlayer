//
//  ViewController.swift
//  NBPlayer
//
//  Created by tjx on 2018/1/11.
//  Copyright © 2018年 tjx. All rights reserved.
//

import UIKit
import AVKit

class NBPlayerViewController: UIViewController {

    //播放器容器 view
    var containView: UIView!
    
    //播放暂停 button
    var ppBtn: UIButton!
    
    //进度条
    var progressView: UIProgressView!
    
    //显示播放时间 label
    var timeLabel: UILabel!
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?
    
    var playerItem: AVPlayerItem?
    
    var progressObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createSubView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        removeAllObserver()
    }
    
    // MARK: action method
    @objc func ppBtnOnClick(_ btn: UIButton) {
        guard let player = player else {
            return
        }
        
        if player.rate == 0 {
            player.play()
            btn.setImage(UIImage(named: "icon_pause"), for: .normal)
        } else {
            player.pause()
            btn.setImage(UIImage(named: "icon_play"), for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .portraitUpsideDown {
            ppBtn.isHidden = !ppBtn.isHidden
            progressView.isHidden = !progressView.isHidden
            timeLabel.isHidden = !timeLabel.isHidden
        }
    }
    
    // MARK: observer method
    @objc func playerItemDidReachEnd(noti: NSNotification) {
        player?.seek(to: kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { [weak self](flag: Bool) in
            self!.progressView.progress = 0
            self!.ppBtn.setImage(UIImage(named: "icon_play"), for: .normal)
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let obj = object as? AVPlayerItem else {
            return
        }
        guard let path = keyPath else {
            return
        }
        
        switch path {
        case "status":
            if obj.status == .readyToPlay {
                player?.play()
                ppBtn.setImage(UIImage(named: "icon_pause"), for: .normal)
            } else {
                print("播放失败")
            }
        case "loadedTimeRanges":
            guard let first = obj.loadedTimeRanges.first else {
                return
            }
            print("缓存时间:\(CMTimeGetSeconds(first.timeRangeValue.start) + CMTimeGetSeconds(first.timeRangeValue.duration))")
        default: break
        }
    }
    
    @objc func screenOrientationDidChange() {
        let ori = UIDevice.current.orientation
        switch ori {
        case .portrait:
            containView.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.width * 9 / 16)
            ppBtn.frame = CGRect(x: containView.frame.minX + 5, y: containView.frame.maxY + 1, width: 16, height: 16)
            progressView.frame = CGRect(x: ppBtn.frame.maxX + 5, y: ppBtn.frame.minY + 4, width: containView.frame.width - ppBtn.frame.maxX - 70, height: 10)
            progressView.center.y = ppBtn.center.y
            timeLabel.frame = CGRect(x: progressView.frame.maxX, y: ppBtn.frame.minY, width: 60, height: 16)
            
            ppBtn.isHidden = false
            progressView.isHidden = false
            timeLabel.isHidden = false
            
            playerLayer?.frame = containView.bounds
        case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
            containView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            ppBtn.frame = CGRect(x: containView.frame.minX + 5, y: containView.frame.maxY - 17, width: 16, height: 16)
            progressView.frame = CGRect(x: ppBtn.frame.maxX + 5, y: ppBtn.frame.minY + 4, width: containView.frame.width - ppBtn.frame.maxX - 70, height: 10)
            progressView.center.y = ppBtn.center.y
            timeLabel.frame = CGRect(x: progressView.frame.maxX, y: ppBtn.frame.minY, width: 60, height: 16)
            playerLayer?.frame = containView.bounds
            break
        default:
            break
        }
    }
    
    // MARK: private method
    func createSubView() {
        containView = UIView(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.width * 9 / 16));
        containView.backgroundColor = UIColor.black
        view.addSubview(containView)
        
        ppBtn = UIButton(type: .custom)
        ppBtn.frame = CGRect(x: containView.frame.minX + 5, y: containView.frame.maxY + 1, width: 16, height: 16)
        ppBtn.setImage(UIImage(named: "icon_play"), for: .normal)
        ppBtn.addTarget(self, action: #selector(NBPlayerViewController.ppBtnOnClick(_:)), for: .touchUpInside)
        view.addSubview(ppBtn)
        
        progressView = UIProgressView(frame: CGRect(x: ppBtn.frame.maxX + 5, y: ppBtn.frame.minY + 4, width: containView.frame.width - ppBtn.frame.maxX - 70, height: 10))
        progressView.center.y = ppBtn.center.y
        progressView.progressTintColor = UIColor.blue
        progressView.trackTintColor = UIColor.gray
        view.addSubview(progressView)
        
        timeLabel = UILabel(frame: CGRect(x: progressView.frame.maxX, y: ppBtn.frame.minY, width: 60, height: 16))
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.blue
        timeLabel.text = "00:00"
        view.addSubview(timeLabel)
        
        addPlayer()
    }
    
    func addPlayer() {
        guard let path = Bundle.main.path(forResource: "video1", ofType: "mp4") else {
            return
        }
        
        let url = NSURL(fileURLWithPath: path)
        playerItem = AVPlayerItem(url: url as URL)
        player = AVPlayer(playerItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = containView.bounds
        playerLayer?.videoGravity = .resizeAspect
        containView.layer.addSublayer(playerLayer!)
        
        addProgressObserver()
        addObserver()
    }
    
    func addProgressObserver() {
        progressObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: Int64(1.0), timescale: Int32(1.0)), queue: DispatchQueue.main, using: { [weak self](time: CMTime) in
            let curTime = CMTimeGetSeconds(time)
            let totTime = CMTimeGetSeconds(self!.playerItem!.duration)
            self!.progressView.setProgress(Float(curTime / totTime), animated: true)
            self!.timeLabel.text = self!.formatTimeString(time: curTime)
        })
    }
    
    func formatTimeString(time: Float64) -> String {
        let hour = Int(time / 3600)
        let min = Int(time / 60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        
        var str: String
        if hour == 0 {
            if min == 0 {
                str = String(format: "00:%02d", sec)
            } else {
                str = String(format: "%02d:%02d", min, sec)
            }
        } else {
            str = String(format: "%02d:%02d:%02d", hour, min, sec)
        }
        
        return str
    }
    
    func addObserver() {
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NBPlayerViewController.playerItemDidReachEnd(noti:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NBPlayerViewController.screenOrientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func removeAllObserver() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        if progressObserver != nil {
            player?.removeTimeObserver(progressObserver!)
        }
    }
}

