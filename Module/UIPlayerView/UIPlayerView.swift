//
//  UIPlayerView.swift
//  jasmine
//
//  Created by Minh Nguyen on 12/14/15.
//  Copyright © 2015 Minh Nguyen. All rights reserved.
//

import UIKit
import AVFoundation

class UIPlayerView : UIView
{
    weak var delegate : UIPlayerViewDelegate?
    var poster : UIImageView
    var isLoaded : Bool
    private var _playerLayer : AVPlayerLayer
    private var _sessionQueue : DispatchQueue
    
    override init(frame: CGRect)
    {
        self._playerLayer = AVPlayerLayer(player: nil)
        self.poster = UIImageView()
        self.isLoaded = false
        self._sessionQueue = DispatchQueue(label: "session")
        
        super.init(frame: frame)
        
        self.layer.addSublayer(self._playerLayer)
        self.addSubview(self.poster)
        self.poster.backgroundColor = UIColor.lightGray
        self.poster.clipsToBounds = true
        self.poster.isUserInteractionEnabled = true
        self._playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    convenience init()
    {
        self.init(frame: CGRect.zero)
    }
    
    var player : AVPlayer?
    {
        get
        {
            return self._playerLayer.player
        }
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        self._playerLayer.frame.size = self.frame.size
        self.poster.frame.size = self.frame.size
    }
    
    func loadPlayerFromBundle(forFileName fileName: String, withExtension: String)
    {
        self._sessionQueue.async
        {
            let asset = AVURLAsset(url: Bundle.main.url(forResource: fileName, withExtension: withExtension)!)
            asset.loadValuesAsynchronously(forKeys: ["playable"])
            {
                if (asset.isPlayable)
                {
                    let playerItem = AVPlayerItem(asset: asset)
                    playerItem.addObserver(self,
                                           forKeyPath: "status",
                                           options: NSKeyValueObservingOptions.new,
                                           context: nil)
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(UIPlayerView.didPlayToEndTime),
                                                           name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                           object: playerItem)
                    self._playerLayer.player = AVPlayer(playerItem: playerItem)
                    self.isLoaded = true
                    
                    DispatchQueue.main.async
                    {
                        self.delegate?.playerViewDidLoad?(self)
                    }
                }
            }
        }
    }
    
    func loadPlayer(contentsOfFile path: String)
    {
        if (self.isLoaded)
        {
            self.unloadPlayer()
        }
        
        self._sessionQueue.async
        {
            let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
            playerItem.addObserver(self,
                                   forKeyPath: "status",
                                   options: NSKeyValueObservingOptions.new,
                                   context: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(UIPlayerView.didPlayToEndTime),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            self._playerLayer.player = AVPlayer(playerItem: playerItem)
            self.isLoaded = true
                        
            DispatchQueue.main.async
            {
                self.delegate?.playerViewDidLoad?(self)
            }
        }
    }
    
    func loadPlayer(asset: AVAsset)
    {
        if (self.isLoaded)
        {
            self.unloadPlayer()
        }
        
        self._sessionQueue.async
        {
            asset.loadValuesAsynchronously(forKeys: ["playable"])
            {
                if (asset.isPlayable)
                {
                    let playerItem = AVPlayerItem(asset: asset)
                    playerItem.addObserver(self,
                                           forKeyPath: "status",
                                           options: NSKeyValueObservingOptions.new,
                                           context: nil)
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(UIPlayerView.didPlayToEndTime),
                                                           name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                           object: playerItem)
                    self._playerLayer.player = AVPlayer(playerItem: playerItem)
                    self.isLoaded = true
                    
                    DispatchQueue.main.async
                    {
                        self.delegate?.playerViewDidLoad?(self)
                    }
                }
            }
        }
    }
    
    func loadPlayer(_ player: AVPlayer)
    {
        if (self.isLoaded)
        {
            self.unloadPlayer()
        }
        
        self._sessionQueue.async
        {
            player.currentItem!.addObserver(self,
                                            forKeyPath: "status",
                                            options: NSKeyValueObservingOptions.new,
                                            context: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(UIPlayerView.didPlayToEndTime),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem!)
            self._playerLayer.player = player
            self.isLoaded = true
            
            DispatchQueue.main.async
            {
                self.delegate?.playerViewDidLoad?(self)
                
                if (self.player!.currentItem!.status == AVPlayerItemStatus.readyToPlay)
                {
                    self.delegate?.playerViewDidReady?(self)
                }
                else if (self.player!.currentItem!.status == AVPlayerItemStatus.failed)
                {
                    self.delegate?.playerViewDidFailed?(self)
                }
            }
        }
    }
    
    func unloadPlayer()
    {
        self._sessionQueue.async
        {
            if (self.isLoaded)
            {
                self.isLoaded = false
                self.player?.pause()
                self.player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
                self._playerLayer.player = nil
                
                DispatchQueue.main.async
                {
                    self.delegate?.playerViewDidUnload?(self)
                }
            }
        }
    }
    
    @objc func didPlayToEndTime()
    {
        DispatchQueue.main.async
        {
            self.delegate?.playerViewDidPlayToEndTime?(self)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        let keyValueChange = NSKeyValueChange(rawValue: change![NSKeyValueChangeKey.kindKey] as! UInt)!
        
        if (keyValueChange == NSKeyValueChange.setting)
        {
            if (keyPath == "status")
            {
                DispatchQueue.main.async
                {
                    if (self.player!.currentItem!.status == AVPlayerItemStatus.readyToPlay)
                    {
                        self.delegate?.playerViewDidReady?(self)
                    }
                    else if (self.player!.currentItem!.status == AVPlayerItemStatus.failed)
                    {
                        self.delegate?.playerViewDidFailed?(self)
                    }
                }
            }
        }
    }
}
