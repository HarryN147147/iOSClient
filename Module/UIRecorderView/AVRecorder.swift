//
//  AVRecorder.swift
//  jasmine
//
//  Created by Minh Nguyen on 3/6/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import AVFoundation
import UIKit

class AVRecorder : NSObject, AVRecorderItemDelegate
{
    weak var delegate : AVRecorderDelegate?
    var liveSegmentDuration : Int
    private var _recorderItem : AVRecorderItem
    private var _enableRecording : Bool?
    private var _isReadyToSegment : Bool
    private var _currentSecond : Int?
    private var _previousTime : Double?
    private var _fileType : String?
    private var _compass : DynamicCompass
    
    init(recorderItem: AVRecorderItem, compass: DynamicCompass)
    {
        self._recorderItem = recorderItem
        self._isReadyToSegment = false
        self.liveSegmentDuration = 5
        self._compass = compass
        
        super.init()
    
        self._recorderItem.delegate = self
    }
    
    var currentItem : AVRecorderItem
    {
        get
        {
            return self._recorderItem
        }
    }
    
    var isRecording : Bool
    {
        get
        {
            if (self._enableRecording == nil)
            {
                return false
            }
            else
            {
                return true
            }
        }
    }
    
    var status : AVAssetWriterStatus?
    {
        get
        {
            if (self.currentItem.scheme == AVRecorderItemScheme.onDemand)
            {
                return self.currentItem.onDemandWriter.movieAssetWriter.status
            }
            else if (self.currentItem.scheme == AVRecorderItemScheme.live)
            {
                return self.currentItem.liveWriter.movieAssetWriter.status
            }
            
            return nil
        }
    }
    
    var orientation : String?
    {
        if (self._compass.orientation == UIInterfaceOrientation.portrait || self._compass.orientation == UIInterfaceOrientation.portraitUpsideDown)
        {
            return "portrait"
        }
        else if (self._compass.orientation == UIInterfaceOrientation.landscapeRight || self._compass.orientation == UIInterfaceOrientation.landscapeLeft)
        {
            return "landscape"
        }
        
        return nil
    }
    
    func enableFrontCamera(_ isEnabled: Bool)
    {
        self.currentItem.enableFrontCamera(isEnabled)
    }
    
    func enableBackCamera(_ isEnabled: Bool)
    {
        self.currentItem.enableBackCamera(isEnabled)
    }
    
    func enableMicrophone(_ isEnabled: Bool)
    {
        self.currentItem.enableMicrophone(isEnabled)
    }

    func recorderItem(_ recorderItem: AVRecorderItem, enableDevice isEnabled: Bool, type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position)
    {
        self.delegate?.recorder?(self, enableDevice: isEnabled, type: type, position: position)
    }
    
    func setOrientationForOnDemandVideo() -> Bool
    {
        if (self._compass.orientation == UIInterfaceOrientation.portrait || self._compass.orientation == UIInterfaceOrientation.portraitUpsideDown)
        {
            self.currentItem.onDemandWriter.videoAssetWriterInput.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
        else if (self._compass.orientation == UIInterfaceOrientation.landscapeLeft)
        {
            self.currentItem.onDemandWriter.videoAssetWriterInput.transform = CGAffineTransform(rotationAngle: .pi)
        }
        else if (self._compass.orientation == UIInterfaceOrientation.landscapeRight)
        {
            self.currentItem.onDemandWriter.videoAssetWriterInput.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }
        else if (self._compass.orientation == UIInterfaceOrientation.unknown)
        {
            return false
        }
        
        return true
    }
    
    func setOrientationForLiveVideo() -> Bool
    {
        if (self._compass.orientation == UIInterfaceOrientation.portrait || self._compass.orientation == UIInterfaceOrientation.portraitUpsideDown)
        {
            self.currentItem.liveWriter.videoAssetWriterInput.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
        else if (self._compass.orientation == UIInterfaceOrientation.landscapeLeft)
        {
            self.currentItem.liveWriter.videoAssetWriterInput.transform = CGAffineTransform(rotationAngle: .pi)
        }
        else if (self._compass.orientation == UIInterfaceOrientation.landscapeRight)
        {
            self.currentItem.liveWriter.videoAssetWriterInput.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }
        else if (self._compass.orientation == UIInterfaceOrientation.unknown)
        {
            return false
        }
        
        return true
    }
    
    func setOrientationForPhoto() -> Bool
    {
        if (self._compass.orientation == UIInterfaceOrientation.portrait || self._compass.orientation == UIInterfaceOrientation.portraitUpsideDown)
        {
            self.currentItem.photoOutput?.connection(with: AVMediaType.video)?.videoOrientation = AVCaptureVideoOrientation.portrait
        }
        else if (self._compass.orientation == UIInterfaceOrientation.landscapeLeft)
        {
            self.currentItem.photoOutput?.connection(with: AVMediaType.video)?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        }
        else if (self._compass.orientation == UIInterfaceOrientation.landscapeRight)
        {
            self.currentItem.photoOutput?.connection(with: AVMediaType.video)?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        }
        else if (self._compass.orientation == UIInterfaceOrientation.unknown)
        {
            return false
        }
        
        return true
    }
    
    func stopLiveRecording()
    {
        self.currentItem.sessionQueue.async
        {            
            if (self.currentItem.scheme == AVRecorderItemScheme.live && self._enableRecording != nil)
            {
                self._enableRecording = false
            }
        }
    }
    
    func stopOnDemandRecording()
    {
        self.currentItem.sessionQueue.async
        {
            if (self.currentItem.scheme == AVRecorderItemScheme.onDemand && self._enableRecording != nil)
            {
                self._enableRecording = false
            }
        }
    }
    
    func startOnDemandRecording(forFileType fileType: String, withOutputURL outputURL: URL)
    {
        self.currentItem.sessionQueue.async
        {            
            if (self.currentItem.scheme == AVRecorderItemScheme.onDemand)
            {
                self.currentItem.onDemandWriter = AVDynamicWriter(withOutputURL: outputURL, forFileType: fileType, atSegmentIndex: 0, fromVideoOutput: self.currentItem.videoOutput!, andAudioOutput: self.currentItem.audioOutput!)
                
                if (self.setOrientationForOnDemandVideo())
                {
                    self._enableRecording = true
                }
            }
        }
    }
    
    func startLiveRecording(forFileType fileType: String)
    {
        self.currentItem.sessionQueue.async
        {
            if (self.currentItem.scheme == AVRecorderItemScheme.live)
            {
                let segmentDuration = self.delegate?.liveSegmentDuration?(self)
                
                if (segmentDuration != nil)
                {
                    self.liveSegmentDuration = segmentDuration!
                }
                
                self._fileType = fileType
                
                self.currentItem.liveWriter = self.createLiveWriter(atSegmentIndex: 0, forFileType: fileType)
                
                if (self.setOrientationForLiveVideo())
                {
                    self._enableRecording = true
                }
            }
        }
    }
    
    private func createLiveWriter(atSegmentIndex index: Int, forFileType fileType: String) -> AVDynamicWriter
    {
        var path : String? = self.delegate?.recorder?(self, pathForLiveSegmentIndex: index)
        
        if (path == nil)
        {
            path = self.generateUniquePath()
        }
        
        let outputURL = URL(fileURLWithPath: path!)
        
        let liveWriter = AVDynamicWriter(withOutputURL: outputURL,
                                         forFileType: fileType,
                                         atSegmentIndex: index,
                                         fromVideoOutput: self.currentItem.videoOutput!,
                                         andAudioOutput: self.currentItem.audioOutput!)
        
        return liveWriter
    }
    
    func generateUniquePath() -> String
    {
        let directoryPath = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        return directoryPath.appendingPathComponent(UUID().uuidString + ".mp4")
    }
    
    func snapPhoto()
    {
        self.currentItem.sessionQueue.async
        {
            self._recorderItem.photoOutput!.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        self.currentItem.sessionQueue.async
        {
            if (self.setOrientationForPhoto())
            {
                let videoConnection = self.currentItem.photoOutput!.connection(with: AVMediaType.video)
                
                if (videoConnection != nil)
                {
                    let imageData = photo.fileDataRepresentation()
                    
                    if (imageData != nil)
                    {
                        DispatchQueue.main.async
                        {
                            self.delegate?.recorder?(self, didCapturePhotoWithData: imageData!, orientation: self.orientation, error: error)
                        }
                    }
                }
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        if (self._enableRecording != nil)
        {
            if (self._enableRecording!)
            {
                if (self.status == AVAssetWriterStatus.unknown)
                {
                    self.startWriting(output, sampleBuffer: sampleBuffer)
                }
                else if (self.status == AVAssetWriterStatus.writing)
                {
                    self.currentItem.sessionQueue.async
                    {
                        self.writeToFile(output, sampleBuffer: sampleBuffer)
                    }
                }
            }
            else
            {
                self.finishWriting(output, sampleBuffer: sampleBuffer)
            }
        }
    }
    
    private func startWriting(_ captureOutput: AVCaptureOutput!, sampleBuffer: CMSampleBuffer!)
    {
        self.currentItem.sessionQueue.async
        {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let currentTime = CMTimeGetSeconds(timestamp)
            
            if (self.status == AVAssetWriterStatus.unknown)
            {
                if (self._currentSecond == nil)
                {
                    if (self._previousTime == nil)
                    {
                        if (captureOutput == self.currentItem.videoOutput)
                        {
                            self._previousTime = currentTime
                            return
                        }
                        else
                        {
                            return
                        }
                    }
                    else
                    {
                        if (captureOutput == self.currentItem.videoOutput)
                        {
                            if (floor(currentTime) - floor(self._previousTime!) == 1.0)
                            {
                                self._previousTime = currentTime
                                self._currentSecond = 0
                            }
                            else
                            {
                                return
                            }
                        }
                        else
                        {
                            return
                        }
                    }
                }
                
                self.startWriter(atStartTime: currentTime, andTimestamp: timestamp)
                
                DispatchQueue.main.async
                {
                    self.didStartRecordingWithSegment()
                }
            }
            
            self.writeToFile(captureOutput, sampleBuffer: sampleBuffer)
        }
    }
    
    private func startWriter(atStartTime currentTime: Double, andTimestamp timestamp: CMTime)
    {
        if (self.currentItem.scheme == AVRecorderItemScheme.onDemand)
        {
            self.currentItem.onDemandWriter.segment.startTime = currentTime
            self.currentItem.onDemandWriter.movieAssetWriter.startWriting()
            self.currentItem.onDemandWriter.movieAssetWriter.startSession(atSourceTime: timestamp)
        }
        else if (self.currentItem.scheme == AVRecorderItemScheme.live)
        {
            self.currentItem.liveWriter.segment.startTime = currentTime
            self.currentItem.liveWriter.movieAssetWriter.startWriting()
            self.currentItem.liveWriter.movieAssetWriter.startSession(atSourceTime: timestamp)
        }
    }
    
    private func didStartRecordingWithSegment()
    {
        if (self.currentItem.scheme == AVRecorderItemScheme.onDemand)
        {
            self.currentItem.onDemandWriter.segment.orientation = self.orientation
            self.delegate?.recorder?(self, didStartOnDemandRecordingWithSegment: self.currentItem.onDemandWriter.segment)
        }
        else if (self.currentItem.scheme == AVRecorderItemScheme.live)
        {
            self.currentItem.liveWriter.segment.orientation = self.orientation
            self.delegate?.recorder?(self, didStartLiveRecordingWithSegment: self.currentItem.liveWriter.segment)
        }
    }
    
    private func writeToFile(_ captureOutput: AVCaptureOutput!, sampleBuffer: CMSampleBuffer!)
    {
        if (captureOutput == self.currentItem.audioOutput)
        {
            self.writeAudioToFile(captureOutput, sampleBuffer: sampleBuffer)
        }
        else if (captureOutput == self.currentItem.videoOutput)
        {
            if (self.currentItem.scheme == AVRecorderItemScheme.live)
            {
                self.checkWriterForExpiration(captureOutput, sampleBuffer: sampleBuffer)
            }
            
            self.writeVideoToFile(captureOutput, sampleBuffer: sampleBuffer)
        }
    }
    
    private func writeVideoToFile(_ captureOutput: AVCaptureOutput!, sampleBuffer: CMSampleBuffer!)
    {
        if (self.currentItem.scheme == AVRecorderItemScheme.onDemand)
        {
            if (self.currentItem.onDemandWriter.videoAssetWriterInput.isReadyForMoreMediaData)
            {
                self.currentItem.onDemandWriter.videoAssetWriterInput.append(sampleBuffer)
            }
        }
        else if (self.currentItem.scheme == AVRecorderItemScheme.live)
        {
            if (self.currentItem.liveWriter.videoAssetWriterInput.isReadyForMoreMediaData)
            {
                self.currentItem.liveWriter.videoAssetWriterInput.append(sampleBuffer)
            }
        }
    }
    
    private func writeAudioToFile(_ captureOutput: AVCaptureOutput!, sampleBuffer: CMSampleBuffer!)
    {
        if (self.currentItem.scheme == AVRecorderItemScheme.onDemand)
        {
            if (self.currentItem.onDemandWriter.audioAssetWriterInput.isReadyForMoreMediaData)
            {
                self.currentItem.onDemandWriter.audioAssetWriterInput.append(sampleBuffer)
            }
        }
        else if (self.currentItem.scheme == AVRecorderItemScheme.live)
        {
            if (self.currentItem.liveWriter.audioAssetWriterInput.isReadyForMoreMediaData)
            {
                self.currentItem.liveWriter.audioAssetWriterInput.append(sampleBuffer)
            }
        }
    }
    
    private func finishWriting(_ captureOutput: AVCaptureOutput!, sampleBuffer: CMSampleBuffer!)
    {
        self.currentItem.sessionQueue.async
        {
            if (self._enableRecording != nil)
            {
                self._enableRecording = nil
                self._isReadyToSegment = false
                self.liveSegmentDuration = 5
                self._currentSecond = nil
                self._previousTime = nil
                let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                let currentTime = CMTimeGetSeconds(timestamp)
                
                if (self.currentItem.scheme == AVRecorderItemScheme.onDemand)
                {
                    self.currentItem.onDemandWriter.segment.endTime = currentTime
                    self.currentItem.onDemandWriter.stopWriterWithCompletionHandler
                    {
                        if (self.currentItem.onDemandWriter.movieAssetWriter.status == AVAssetWriterStatus.completed)
                        {
                            DispatchQueue.main.async
                            {
                                self.currentItem.onDemandWriter.segment.orientation = self.orientation
                                self.delegate?.recorder?(self, didFinishOnDemandRecordingWithSegment: self.currentItem.onDemandWriter.segment)
                            }
                        }
                        else if (self.currentItem.onDemandWriter.movieAssetWriter.status == AVAssetWriterStatus.unknown)
                        {
                            DispatchQueue.main.async
                            {
                                self.delegate?.recorderDidStopBeforeRecording?(self)
                            }
                        }
                    }
                }
                else if (self.currentItem.scheme == AVRecorderItemScheme.live)
                {
                    self.currentItem.liveWriter.segment.endTime = currentTime
                    self.currentItem.liveWriter.stopWriterWithCompletionHandler()
                    {
                        if (self.currentItem.liveWriter.movieAssetWriter.status == AVAssetWriterStatus.completed)
                        {
                            DispatchQueue.main.async
                            {
                                self.currentItem.liveWriter.segment.orientation = self.orientation
                                self.delegate?.recorder?(self, didFinishLiveRecordingWithSegment: self.currentItem.liveWriter.segment)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func checkWriterForExpiration(_ captureOutput: AVCaptureOutput!, sampleBuffer: CMSampleBuffer!)
    {
        if (captureOutput == self.currentItem.videoOutput)
        {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let currentTime = CMTimeGetSeconds(timestamp)
            
            if (floor(currentTime) - floor(self._previousTime!) == 1.0)
            {
                self._currentSecond! += 1
                self._previousTime = currentTime
                
                if (self._currentSecond! >= self.liveSegmentDuration - 1)
                {
                    if (!self._isReadyToSegment)
                    {
                        self._isReadyToSegment = true
                    }
                    else
                    {
                        let expiredLiveWriter = self.currentItem.liveWriter
                        expiredLiveWriter!.segment.endTime = currentTime
                        expiredLiveWriter!.stopWriterWithCompletionHandler()
                        {
                            if (expiredLiveWriter!.movieAssetWriter.status == AVAssetWriterStatus.completed)
                            {
                                DispatchQueue.main.async
                                {
                                    expiredLiveWriter!.segment.orientation = self.orientation
                                    self.delegate?.recorder?(self, didOutputLiveSegment: expiredLiveWriter!.segment)
                                }
                            }
                        }
                        
                        if (expiredLiveWriter!.segment.index + 1 <= self.liveSegmentDuration)
                        {
                            self.currentItem.liveWriter = self.createLiveWriter(atSegmentIndex: expiredLiveWriter!.segment.index + 1, forFileType: self._fileType!)
                            
                            if (self.setOrientationForLiveVideo())
                            {
                                self._currentSecond = 0
                                self._isReadyToSegment = false
                                self.currentItem.liveWriter.segment.startTime = CMTimeGetSeconds(timestamp)
                                self.currentItem.liveWriter.movieAssetWriter.startWriting()
                                self.currentItem.liveWriter.movieAssetWriter.startSession(atSourceTime: timestamp)
                            }
                        }
                        else
                        {
                            self.finishWriting(captureOutput, sampleBuffer: sampleBuffer)
                        }
                    }
                }
            }
            else
            {
                self._previousTime = currentTime
            }
        }
    }
}
