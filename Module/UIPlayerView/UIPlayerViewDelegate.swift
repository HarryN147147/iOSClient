//
//  UIPlayerViewDelegate.swift
//  jasmine
//
//  Created by Minh Nguyen on 12/15/15.
//  Copyright © 2015 Minh Nguyen. All rights reserved.
//

import UIKit

@objc
protocol UIPlayerViewDelegate
{
    @objc optional func playerViewDidReady(_ playerView: UIPlayerView)
    @objc optional func playerViewDidFailed(_ playerView: UIPlayerView)
    @objc optional func playerViewDidLoad(_ playerView: UIPlayerView)
    @objc optional func playerViewDidUnload(_ playerView: UIPlayerView)
    @objc optional func playerViewDidPlayToEndTime(_ playerView: UIPlayerView)
}
