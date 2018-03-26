//
//  AVRecorderItemDelegate.swift
//  Pacific
//
//  Created by Minh Nguyen on 10/14/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import AVFoundation
import UIKit

@objc
protocol AVRecorderItemDelegate : AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate
{
    @objc optional func recorderItem(_ recorderItem: AVRecorderItem, enableDevice isEnabled: Bool, type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position)
}
