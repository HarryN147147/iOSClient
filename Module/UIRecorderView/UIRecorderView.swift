//
//  UIRecorderView.swift
//  jasmine
//
//  Created by Minh Nguyen on 3/4/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import AVFoundation
import UIKit

class UIRecorderView : UIView, AVRecorderDelegate, DynamicCompassDelegate
{
    private var _previewLayer : AVCaptureVideoPreviewLayer
    private var _recorder : AVRecorder?
    private var _compass : DynamicCompass
    private var _sessionQueue : DispatchQueue
    weak var delegate : UIRecorderViewDelegate?
    var isLoaded : Bool
    
    override init(frame: CGRect)
    {
        self._previewLayer = AVCaptureVideoPreviewLayer()
        self._compass = DynamicCompass()
        self._sessionQueue = DispatchQueue(label: "session")
        self.isLoaded = false
        
        super.init(frame: frame)
        
        self.layer.addSublayer(self._previewLayer)
        self._previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self._compass.delegate = self
    }
    
    convenience init()
    {
        self.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var recorder : AVRecorder?
    {
        get
        {
            return self._recorder
        }
    }
    
    override func layoutSubviews()
    {
        self._previewLayer.frame.size = self.frame.size
    }
    
    func compass(_ compass: DynamicCompass, didChangeTo interfaceOrientation: UIInterfaceOrientation)
    {
        if (self._previewLayer.connection != nil)
        {
            self.delegate?.recorderView?(self, didChangeTo: interfaceOrientation)
        }
    }
    
    func rotate()
    {
        if (self._previewLayer.connection != nil)
        {
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            
            if (interfaceOrientation == UIInterfaceOrientation.portrait)
            {
                self._previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            }
            else if (interfaceOrientation == UIInterfaceOrientation.landscapeLeft)
            {
                self._previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            }
            else if (interfaceOrientation == UIInterfaceOrientation.landscapeRight)
            {
                self._previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            }
            else if (interfaceOrientation == UIInterfaceOrientation.portraitUpsideDown)
            {
                self._previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
            }
            
            self.delegate?.recorderView?(self, didChangeTo: interfaceOrientation)
        }

    }
    
    func loadRecorder(withScheme scheme: AVRecorderItemScheme)
    {
        if (self.isLoaded)
        {
            self.unloadRecorder()
        }
        
        self._sessionQueue.async
        {
            self.isLoaded = true
            
            self._recorder = AVRecorder(recorderItem: AVRecorderItem(withScheme: scheme), compass: self._compass)
            self._recorder?.delegate = self
            self._recorder?.currentItem.sessionQueue = self._sessionQueue
            
            NotificationCenter.default.addObserver(self, selector: #selector(UIRecorderView.handleSessionDidStartRunning), name: NSNotification.Name.AVCaptureSessionDidStartRunning, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(UIRecorderView.handleSessionDidStopRunning), name: NSNotification.Name.AVCaptureSessionDidStopRunning, object: nil)
            
            DispatchQueue.main.async
            {
                self.delegate?.recorderViewWillLoad?(self)
                
                self._sessionQueue.async
                {
                    self._recorder!.currentItem.session.startRunning()
                }
            }
        }
    }
    
    func unloadRecorder()
    {
        self._sessionQueue.async
        {
            if (self.isLoaded)
            {
                self.isLoaded = false
                
                DispatchQueue.main.async
                {
                    self.delegate?.recorderViewWillUnload?(self)
                    
                    self._sessionQueue.async
                    {
                        self._recorder!.currentItem.disableAll()
                        self._recorder!.currentItem.session.stopRunning()
                        self._recorder = nil
                        self._previewLayer.session = nil
                        
                        NotificationCenter.default.removeObserver(self)
                    }
                }
            }
        }
    }
    
    func recorder(_ recorder: AVRecorder, enableDevice isEnabled: Bool, type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position)
    {
        self.delegate?.recorderView?(self, enableDevice: isEnabled, type: type, position: position)
    }

    func recorderDidStopBeforeRecording(_ recorder: AVRecorder)
    {
        self.delegate?.recorderViewDidStopBeforeRecording?(self)
    }
    
    func recorder(_ recorder: AVRecorder, didCapturePhotoWithData data: Data, orientation: String?, error: Error?)
    {
        self.delegate?.recorderView?(self, didCapturePhotoWithData: data, orientation: orientation, error: error)
    }
    
    func recorder(_ recorder: AVRecorder, didStartOnDemandRecordingWithSegment segment: AVSegment)
    {
        self.delegate?.recorderView?(self, didStartOnDemandRecordingWithSegment: segment)
    }
    
    func recorder(_ recorder: AVRecorder, didFinishOnDemandRecordingWithSegment segment: AVSegment)
    {
        self.delegate?.recorderView?(self, didFinishOnDemandRecordingWithSegment: segment)
    }
    
    func recorder(_ recorder: AVRecorder, didStartLiveRecordingWithSegment segment: AVSegment)
    {
        self.delegate?.recorderView?(self, didStartLiveRecordingWithSegment: segment)
    }
    
    func recorderLiveSegmentDuration() -> Int
    {
        let duration = self.delegate?.liveSegmentDuration?(self)
        
        if (duration == nil)
        {
            return self._recorder!.liveSegmentDuration
        }
        else
        {
            return duration!
        }
    }
    
    func recorder(_ recorder: AVRecorder, pathForLiveSegmentIndex index: Int) -> String
    {
        let path = self.delegate?.recorderView?(self, pathForLiveSegmentIndex: index)
        
        if (path == nil)
        {
            return self._recorder!.generateUniquePath()
        }
        else
        {
            return path!
        }
    }
    
    func recorder(_ recorder: AVRecorder, didOutputLiveSegment segment: AVSegment)
    {
        self.delegate?.recorderView?(self, didOutputLiveSegment: segment)
    }
    
    func recorder(_ recorder: AVRecorder, didFinishLiveRecordingWithSegment segment: AVSegment)
    {
        self.delegate?.recorderView?(self, didFinishLiveRecordingWithSegment: segment)
    }
    
    @objc func handleSessionDidStartRunning()
    {
        DispatchQueue.main.async
        {
            self._previewLayer.session = self._recorder!.currentItem.session
            self.delegate?.recorderViewDidLoad?(self)
        }
    }
    
    @objc func handleSessionDidStopRunning()
    {
        DispatchQueue.main.async
        {
            self.delegate?.recorderViewDidUnload?(self)
        }
    }
}
