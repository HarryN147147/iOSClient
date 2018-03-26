//
//  UIPageViewHeaderFooterContentView.swift
//  Pacific
//
//  Created by Minh Nguyen on 2/4/18.
//  Copyright © 2018 Langtutheky. All rights reserved.
//

import UIKit

class UIPageViewHeaderFooterContentView : UIView
{
    private var _label : UILabel!
    
    var label : UILabel
    {
        get
        {
            if (self._label == nil)
            {
                self._label = UILabel()
                self.addSubview(self._label)
            }
            
            let label = self._label!
            
            return label
        }
    }
    
    override func layoutSubviews()
    {
        if (self.label.numberOfLines == 0)
        {
            self.label.frame.size.width = self.frame.width - 20
        }
        
        self.label.sizeToFit()
        
        if (self.label.numberOfLines == 1)
        {
            if (self.label.frame.width > self.frame.width - 20)
            {
                self.label.frame.size.width = self.frame.width - 20
            }
            
            self.label.center.y = self.frame.height / 2
        }
        else if (self.label.numberOfLines == 0)
        {
            self.label.frame.origin.y = 5
        }
        
        self.label.frame.origin.x = 10
    }
}

