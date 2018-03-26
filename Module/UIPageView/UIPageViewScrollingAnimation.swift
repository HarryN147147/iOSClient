//
//  UIPageViewScrollingAnimation.swift
//  Pacific
//
//  Created by Minh Nguyen on 1/9/18.
//  Copyright © 2018 Langtutheky. All rights reserved.
//

import Foundation

class UIPageViewScrollingAnimation
{
    var indexPath : IndexPath
    var scrollPosition : UIPageViewScrollPosition
    var allowsAnimation : Bool
    
    init(indexPath: IndexPath, at scrollPosition: UIPageViewScrollPosition, allowsAnimation: Bool)
    {
        self.indexPath = indexPath
        self.scrollPosition = scrollPosition
        self.allowsAnimation = allowsAnimation
    }
}

