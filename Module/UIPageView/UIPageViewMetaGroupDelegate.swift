//
//  UIPageViewMetaGroupDelegate.swift
//  Pacific
//
//  Created by Minh Nguyen on 2/21/18.
//  Copyright © 2018 Langtutheky. All rights reserved.
//

import Foundation

@objc
protocol UIPageViewMetaGroupDelegate
{
    @objc optional func pageViewMetaGroup(_ pageViewMetaGroup: UIPageViewMetaGroup, willChangeWidthFrom oldWidth: CGFloat, to newWidth: CGFloat)
    @objc optional func pageViewMetaGroup(_ pageViewMetaGroup: UIPageViewMetaGroup, didChangeWidthFrom oldWidth: CGFloat, to newWidth: CGFloat)
}

