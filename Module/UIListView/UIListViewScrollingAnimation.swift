//
//  UIListViewScrollingAnimation.swift
//  Pacific
//
//  Created by Minh Nguyen on 1/9/18.
//  Copyright © 2018 Langtutheky. All rights reserved.
//

import Foundation

class UIListViewScrollingAnimation
{
    var indexPath : IndexPath
    var scrollPosition : UIListViewScrollPosition
    var allowsAnimation : Bool
    
    init(indexPath: IndexPath, at scrollPosition: UIListViewScrollPosition, allowsAnimation: Bool)
    {
        self.indexPath = indexPath
        self.scrollPosition = scrollPosition
        self.allowsAnimation = allowsAnimation
    }
}
