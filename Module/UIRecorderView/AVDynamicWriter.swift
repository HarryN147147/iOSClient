//
//  AVDynamicWriter.swift
//  jasmine
//
//  Created by Minh Nguyen on 5/5/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import UIKit
import AVFoundation

class AVDynamicWriter : NSObject
{
    var movieAssetWriter : AVAssetWriter
    var videoAssetWriterInput : AVAssetWriterInput
    var audioAssetWriterInput : AVAssetWriterInput
    var segment : AVSegment
    
    init(withOutputURL url: URL, forFileType fileType: String, atSegmentIndex index: Int, fromVideoOutput videoOutput: AVCaptureVideoDataOutput, andAudioOutput audioOutput: AVCaptureAudioDataOutput)
    {
        if (FileManager.default.fileExists(atPath: url.path) && FileManager.default.isDeletableFile(atPath: url.path))
        {
            do
            {
                try FileManager.default.removeItem(at: url)
                
            } catch
            {
                fatalError("AVDynamicWriter: Cannot Remove Existing File")
            }
        }
        
        do
        {
            self.videoAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutput.recommendedVideoSettingsForAssetWriter(writingTo: AVFileType(rawValue: fileType)))
            self.videoAssetWriterInput.expectsMediaDataInRealTime = true
            
            self.audioAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutput.recommendedAudioSettingsForAssetWriter(writingTo: AVFileType(rawValue: fileType)) as? [String:Any])
            self.audioAssetWriterInput.expectsMediaDataInRealTime = true
            
            self.segment = AVSegment(withIndex: index, toOutputFileURL: url)

            try self.movieAssetWriter = AVAssetWriter(outputURL: url, fileType: AVFileType(rawValue: fileType))
            
            if (!self.movieAssetWriter.canAdd(self.videoAssetWriterInput))
            {
                fatalError("AVDynamicWriter: Input Cannot Be Added")
            }
            
            self.movieAssetWriter.add(self.videoAssetWriterInput)
            
            if (!self.movieAssetWriter.canAdd(self.audioAssetWriterInput))
            {
                fatalError("AVDynamicWriter: Audio Asset Writer Input Cannot Be Added")
            }
            
            self.movieAssetWriter.add(self.audioAssetWriterInput)
        
        } catch
        {
            fatalError("AVDynamicWriter: Cannot Create Asset Writer")
        }
        
        super.init()
    }

    func stopWriterWithCompletionHandler(_ handler: @escaping () -> Void)
    {
        if (self.movieAssetWriter.status == AVAssetWriterStatus.writing)
        {
            self.videoAssetWriterInput.markAsFinished()
            self.audioAssetWriterInput.markAsFinished()
            self.movieAssetWriter.finishWriting(completionHandler: handler)
        } else
        {
            handler()
        }
    }
}
