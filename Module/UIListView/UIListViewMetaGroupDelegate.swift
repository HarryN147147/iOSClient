//
//  UIListViewMetaGroupDelegate.swift
//  Pacific
//
//  Created by Minh Nguyen on 2/20/18.
//  Copyright © 2018 Langtutheky. All rights reserved.
//

import Foundation

@objc
protocol UIListViewMetaGroupDelegate
{
    @objc optional func listViewMetaGroup(_ listViewMetaGroup: UIListViewMetaGroup, willChangeHeightFrom oldHeight: CGFloat, to newHeight: CGFloat)
    @objc optional func listViewMetaGroup(_ listViewMetaGroup: UIListViewMetaGroup, didChangeHeightFrom oldHeight: CGFloat, to newHeight: CGFloat)
}
