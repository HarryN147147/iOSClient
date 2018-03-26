//
//  UIRecorderViewDelegate.swift
//  jasmine
//
//  Created by Minh Nguyen on 3/6/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import AVFoundation
import UIKit

@objc
protocol UIRecorderViewDelegate
{
    @objc optional func recorderView(_ recorderView: UIRecorderView, enableDevice isEnabled: Bool, type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position)
    @objc optional func recorderView(_ recorderView: UIRecorderView, didCapturePhotoWithData data: Data, orientation: String?, error: Error?)
    @objc optional func recorderView(_ recorderView: UIRecorderView, didStartOnDemandRecordingWithSegment segment: AVSegment)
    @objc optional func recorderView(_ recorderView: UIRecorderView, didFinishOnDemandRecordingWithSegment segment: AVSegment)
    @objc optional func recorderView(_ recorderView: UIRecorderView, didStartLiveRecordingWithSegment segment: AVSegment)
    @objc optional func recorderView(_ recorderView: UIRecorderView, didOutputLiveSegment segment: AVSegment)
    @objc optional func recorderView(_ recorderView: UIRecorderView, didFinishLiveRecordingWithSegment segment: AVSegment)
    @objc optional func recorderViewDidStopBeforeRecording(_ recorderView: UIRecorderView)
    @objc optional func liveSegmentDuration(_ recorderView: UIRecorderView) -> Int
    @objc optional func recorderView(_ recorderView: UIRecorderView, pathForLiveSegmentIndex index: Int) -> String
    @objc optional func recorderViewWillLoad(_ recorderView: UIRecorderView)
    @objc optional func recorderViewDidLoad(_ recorderView: UIRecorderView)
    @objc optional func recorderViewWillUnload(_ recorderView: UIRecorderView)
    @objc optional func recorderViewDidUnload(_ recorderView: UIRecorderView)
    @objc optional func recorderView(_ recorderView: UIRecorderView, didChangeTo interfaceOrientation: UIInterfaceOrientation)
}
