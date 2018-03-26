//
//  DynamicCompassDelegate.swift
//  Pacific
//
//  Created by Minh Nguyen on 10/15/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

import UIKit

@objc
protocol DynamicCompassDelegate
{
    @objc optional func compass(_ compass: DynamicCompass, didChangeTo interfaceOrientation: UIInterfaceOrientation)
}
