//
//  AVRecorderItem.swift
//  jasmine
//
//  Created by Minh Nguyen on 3/6/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import AVFoundation

class AVRecorderItem : NSObject
{
    weak var delegate : AVRecorderItemDelegate?
    var sessionQueue : DispatchQueue!
    var session : AVCaptureSession
    private var _scheme : AVRecorderItemScheme
    private var _videoOutputQueue : DispatchQueue
    private var _audioOutputQueue : DispatchQueue
    private var _frontCameraInput : AVCaptureDeviceInput?
    private var _backCameraInput : AVCaptureDeviceInput?
    private var _microphoneInput : AVCaptureDeviceInput?
    var photoOutput : AVCapturePhotoOutput?
    var videoOutput : AVCaptureVideoDataOutput?
    var audioOutput : AVCaptureAudioDataOutput?
    var liveWriter : AVDynamicWriter!
    var onDemandWriter : AVDynamicWriter!
    
    init(withScheme scheme: AVRecorderItemScheme)
    {
        self._videoOutputQueue = DispatchQueue(label: "videoOutput")
        self._audioOutputQueue = DispatchQueue(label: "audioOutput")
        self.session = AVCaptureSession()
        self._scheme = scheme
        
        super.init()
    }
    
    var scheme : AVRecorderItemScheme
    {
        get
        {
            return self._scheme
        }
    }
    
    var isFrontCameraEnabled : Bool
    {
        get
        {
            var isFrontCameraEnabled = false
            
            if (self._frontCameraInput != nil)
            {
                isFrontCameraEnabled = true
            }
            
            return isFrontCameraEnabled
        }
    }
    
    var isBackCameraEnabled : Bool
    {
        get
        {
            var isBackCameraEnabled = false
            
            if (self._backCameraInput != nil)
            {
                isBackCameraEnabled = true
            }
            
            return isBackCameraEnabled
        }
    }
    
    var isMicrophoneEnabled : Bool
    {
        get
        {
            var isMicrophoneEnabled = false
            
            if (self._microphoneInput != nil)
            {
                isMicrophoneEnabled = true
            }
            
            return isMicrophoneEnabled
        }
    }
    
    func disableAll()
    {
        self.sessionQueue.async
        {
            self.session.beginConfiguration()
            self.removeFrontCameraInputIfNeeded()
            self.removeBackCameraInputIfNeeded()
            self.removeMicrophoneInputIfNeeded()
            self.removePhotoOutputIfNeeded()
            self.removeVideoOutputIfNeeded()
            self.removeAudioOutputIfNeeded()
            self.session.commitConfiguration()
            self.delegate?.recorderItem?(self,
                                         enableDevice: false,
                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                         position: AVCaptureDevice.Position.front)
            self.delegate?.recorderItem?(self,
                                         enableDevice: false,
                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                         position: AVCaptureDevice.Position.back)
            self.delegate?.recorderItem?(self,
                                         enableDevice: false,
                                         type: AVCaptureDevice.DeviceType.builtInMicrophone,
                                         position: AVCaptureDevice.Position.unspecified)
        }
    }
    
    func enableFrontCamera(_ isEnabled: Bool)
    {
        if (isEnabled)
        {
            if (!self.isFrontCameraEnabled)
            {
                if (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized)
                {
                    self.attachFrontCamera()
                }
                else
                {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video)
                    { (isGranted) -> Void in
                        
                        if (isGranted)
                        {
                            self.attachFrontCamera()
                        }
                        else
                        {
                            self.delegate?.recorderItem?(self,
                                                         enableDevice: false,
                                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                                         position: AVCaptureDevice.Position.front)
                        }
                    }
                }
            }
        }
        else
        {
            if (self.isFrontCameraEnabled)
            {
                self.detachFrontCamera()
            }
        }
    }
    
    private func attachFrontCamera()
    {
        self.sessionQueue.async
        {
            self.session.beginConfiguration()
            
            self.removeBackCameraInputIfNeeded()
            
            var isEnabled = true
            
            if (isEnabled)
            {
                isEnabled = self.addFrontCameraInputIfNeeded()
            }
            
            if (isEnabled)
            {
                isEnabled = self.addPhotoOutputIfNeeded()
            }
            
            if (isEnabled)
            {
                isEnabled = self.addVideoOutputIfNeeded()
            }
            
            if (!isEnabled)
            {
                self.removeFrontCameraInputIfNeeded()
                self.removePhotoOutputIfNeeded()
                self.removeVideoOutputIfNeeded()
            }
            
            self.session.commitConfiguration()
            
            self.delegate?.recorderItem?(self,
                                         enableDevice: self.isBackCameraEnabled,
                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                         position: AVCaptureDevice.Position.back)
            self.delegate?.recorderItem?(self,
                                         enableDevice: isEnabled,
                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                         position: AVCaptureDevice.Position.front)
        }
    }
    
    private func detachFrontCamera()
    {
        self.sessionQueue.async
        {
            self.session.beginConfiguration()
            self.removeFrontCameraInputIfNeeded()
            self.removePhotoOutputIfNeeded()
            self.removeVideoOutputIfNeeded()
            self.session.commitConfiguration()
            self.delegate?.recorderItem?(self,
                                         enableDevice: false,
                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                         position: AVCaptureDevice.Position.front)
        }
    }
    
    func enableBackCamera(_ isEnabled: Bool)
    {
        if (isEnabled)
        {
            if (!self.isBackCameraEnabled)
            {
                if (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized)
                {
                    self.attachBackCamera()
                }
                else
                {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video)
                    { (isGranted) -> Void in
                        
                        if (isGranted)
                        {
                            self.attachBackCamera()
                        }
                        else
                        {
                            self.delegate?.recorderItem?(self,
                                                         enableDevice: false,
                                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                                         position: AVCaptureDevice.Position.back)
                        }
                    }
                }
            }
        }
        else
        {
            if (self.isBackCameraEnabled)
            {
                self.detachBackCamera()
            }
        }
    }
    
    private func attachBackCamera()
    {
        self.sessionQueue.async
        {
            self.session.beginConfiguration()
            
            self.removeFrontCameraInputIfNeeded()
            
            var isEnabled = true
            
            if (isEnabled)
            {
                isEnabled = self.addBackCameraInputIfNeeded()
            }
            
            if (isEnabled)
            {
                isEnabled = self.addPhotoOutputIfNeeded()
            }
            
            if (isEnabled)
            {
                isEnabled = self.addVideoOutputIfNeeded()
            }
            
            if (!isEnabled)
            {
                self.removeBackCameraInputIfNeeded()
                self.removePhotoOutputIfNeeded()
                self.removeVideoOutputIfNeeded()
            }
            
            self.session.commitConfiguration()
            
            self.delegate?.recorderItem?(self,
                                         enableDevice: self.isFrontCameraEnabled,
                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                         position: AVCaptureDevice.Position.front)
            self.delegate?.recorderItem?(self,
                                         enableDevice: isEnabled,
                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                         position: AVCaptureDevice.Position.back)
        }
    }
    
    private func detachBackCamera()
    {
        self.sessionQueue.async
        {
            self.session.beginConfiguration()
            self.removeBackCameraInputIfNeeded()
            self.removePhotoOutputIfNeeded()
            self.removeVideoOutputIfNeeded()
            self.session.commitConfiguration()
            self.delegate?.recorderItem?(self,
                                         enableDevice: false,
                                         type: AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                         position: AVCaptureDevice.Position.back)
        }
    }
    
    func enableMicrophone(_ isEnabled: Bool)
    {
        if (isEnabled)
        {
            if (!self.isMicrophoneEnabled)
            {
                if (AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) ==  AVAuthorizationStatus.authorized)
                {
                    self.attachMicrophone()
                }
                else
                {
                    AVCaptureDevice.requestAccess(for: AVMediaType.audio)
                    { (isGranted) -> Void in
                        
                        if (isGranted)
                        {
                            self.attachMicrophone()
                        }
                        else
                        {
                            self.delegate?.recorderItem?(self,
                                                         enableDevice: false,
                                                         type: AVCaptureDevice.DeviceType.builtInMicrophone,
                                                         position: AVCaptureDevice.Position.unspecified)
                        }
                    }
                }
            }
        }
        else
        {
            if (self.isMicrophoneEnabled)
            {
                self.detachMicrophone()
            }
        }
    }
    
    private func attachMicrophone()
    {
        self.sessionQueue.async
        {
            self.session.beginConfiguration()
            
            var isEnabled = true
            
            if (isEnabled)
            {
                isEnabled = self.addMicrophoneInputIfNeeded()
            }
            
            if (isEnabled)
            {
                isEnabled = self.addAudioOutputIfNeeded()
            }
            
            if (!isEnabled)
            {
                self.removeMicrophoneInputIfNeeded()
                self.removeAudioOutputIfNeeded()
            }
            
            self.session.commitConfiguration()
            self.delegate?.recorderItem?(self,
                                         enableDevice: isEnabled,
                                         type: AVCaptureDevice.DeviceType.builtInMicrophone,
                                         position: AVCaptureDevice.Position.unspecified)
        }
    }
    
    private func detachMicrophone()
    {
        self.sessionQueue.async
        {
            self.session.beginConfiguration()
            self.removeMicrophoneInputIfNeeded()
            self.removeAudioOutputIfNeeded()
            self.session.commitConfiguration()
            self.delegate?.recorderItem?(self,
                                         enableDevice: false,
                                         type: AVCaptureDevice.DeviceType.builtInMicrophone,
                                         position: AVCaptureDevice.Position.unspecified)
        }
    }
    
    private func addFrontCameraInputIfNeeded() -> Bool
    {
        var isEnabled = true
        
        do
        {
            if (self._frontCameraInput == nil)
            {
                let frontCamera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                                          for: AVMediaType.video,
                                                          position: AVCaptureDevice.Position.front)
                
                if (frontCamera != nil)
                {
                    let frontCameraInput = try AVCaptureDeviceInput(device: frontCamera!)
                    
                    if (self.session.canAddInput(frontCameraInput))
                    {
                        self._frontCameraInput = frontCameraInput
                        self.session.addInput(frontCameraInput)
                    }
                    else
                    {
                        isEnabled = false
                    }
                }
                else
                {
                    isEnabled = false
                }
            }
        }
        catch
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    private func removeFrontCameraInputIfNeeded()
    {
        if (self._frontCameraInput != nil)
        {
            self.session.removeInput(self._frontCameraInput!)
            self._frontCameraInput = nil
        }
    }
    
    private func addBackCameraInputIfNeeded() -> Bool
    {
        var isEnabled = true
        
        do
        {
            if (self._backCameraInput == nil)
            {
                let backCamera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                                         for: AVMediaType.video,
                                                         position: AVCaptureDevice.Position.back)
                
                if (backCamera != nil)
                {
                    let backCameraInput = try AVCaptureDeviceInput(device: backCamera!)
                    
                    if (self.session.canAddInput(backCameraInput))
                    {
                        self._backCameraInput = backCameraInput
                        self.session.addInput(backCameraInput)
                    }
                    else
                    {
                        isEnabled = false
                    }
                }
                else
                {
                    isEnabled = false
                }
            }
        }
        catch
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    private func removeBackCameraInputIfNeeded()
    {
        if (self._backCameraInput != nil)
        {
            self.session.removeInput(self._backCameraInput!)
            self._backCameraInput = nil
        }
    }
    
    private func addMicrophoneInputIfNeeded() -> Bool
    {
        var isEnabled = true
        
        do
        {
            if (self._microphoneInput == nil)
            {
                let microphone = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInMicrophone,
                                                         for: AVMediaType.audio,
                                                         position: AVCaptureDevice.Position.unspecified)
                
                if (microphone != nil)
                {
                    let microphoneInput = try AVCaptureDeviceInput(device: microphone!)
                    
                    if (self.session.canAddInput(microphoneInput))
                    {
                        self._microphoneInput = microphoneInput
                        self.session.addInput(microphoneInput)
                    }
                    else
                    {
                        isEnabled = false
                    }
                }
                else
                {
                    isEnabled = false
                }
            }
        }
        catch
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    private func removeMicrophoneInputIfNeeded()
    {
        if (self._microphoneInput != nil)
        {
            self.session.removeInput(self._microphoneInput!)
            self._microphoneInput = nil
        }
    }
    
    private func addPhotoOutputIfNeeded() -> Bool
    {
        var isEnabled = true
        
        if (self.photoOutput == nil)
        {
            let photoOutput = AVCapturePhotoOutput()
            
            if (self.session.canAddOutput(photoOutput))
            {
                self.photoOutput = photoOutput
                self.session.addOutput(photoOutput)
            }
            else
            {
                isEnabled = false
            }
        }
        
        return isEnabled
    }
    
    private func removePhotoOutputIfNeeded()
    {
        if (self._frontCameraInput == nil && self._backCameraInput == nil)
        {
            if (self.photoOutput != nil)
            {
                self.session.removeOutput(self.photoOutput!)
                self.photoOutput = nil
            }
        }
    }
    
    private func addVideoOutputIfNeeded() -> Bool
    {
        var isEnabled = true
        
        if (self.videoOutput == nil)
        {
            let videoOutput = AVCaptureVideoDataOutput()
            
            if (self.session.canAddOutput(videoOutput))
            {
                videoOutput.setSampleBufferDelegate(self.delegate, queue: self._videoOutputQueue)
                self.videoOutput = videoOutput
                self.session.addOutput(videoOutput)
            }
            else
            {
                isEnabled = false
            }
        }
        
        return isEnabled
    }
    
    private func removeVideoOutputIfNeeded()
    {
        if (self._frontCameraInput == nil && self._backCameraInput == nil)
        {
            if (self.videoOutput != nil)
            {
                self.session.removeOutput(self.videoOutput!)
                self.videoOutput = nil
            }
        }
    }
    
    private func addAudioOutputIfNeeded() -> Bool
    {
        var isEnabled = true
        
        if (self.audioOutput == nil)
        {
            let audioOutput = AVCaptureAudioDataOutput()
            
            if (self.session.canAddOutput(audioOutput))
            {
                audioOutput.setSampleBufferDelegate(self.delegate, queue: self._audioOutputQueue)
                self.audioOutput = audioOutput
                self.session.addOutput(audioOutput)
            }
            else
            {
                isEnabled = false
            }
        }
        
        return isEnabled
    }
    
    private func removeAudioOutputIfNeeded()
    {
        if (self._microphoneInput == nil)
        {
            if (self.audioOutput != nil)
            {
                self.session.removeOutput(self.audioOutput!)
                self.audioOutput = nil
            }
        }
    }
}

enum AVRecorderItemScheme : Int
{
    case onDemand
    case live
    case unknown
}
