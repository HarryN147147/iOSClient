//
//  UIMetaDelegate.swift
//  Pacific
//
//  Created by Minh Nguyen on 2/7/18.
//  Copyright © 2018 Langtutheky. All rights reserved.
//

import Foundation

@objc
protocol UIMetaDelegate
{
    @objc optional func meta(_ meta: UIMeta, willChangeWidthFrom oldWidth: CGFloat, to newWidth: CGFloat)
    @objc optional func meta(_ meta: UIMeta, didChangeWidthFrom oldWidth: CGFloat, to newWidth: CGFloat)
    @objc optional func meta(_ meta: UIMeta, willChangeHeightFrom oldHeight: CGFloat, to newHeight: CGFloat)
    @objc optional func meta(_ meta: UIMeta, didChangeHeightFrom oldHeight: CGFloat, to newHeight: CGFloat)
}
