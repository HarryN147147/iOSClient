//
//  UIPageViewCell.swift
//  jasmine
//
//  Created by Minh Nguyen on 11/24/15.
//  Copyright © 2015 Minh Nguyen. All rights reserved.
//

import UIKit

class UIPageViewCell : UIView
{
    var reuseIdentifier : String?
    var contentView : UIView
    var isSelected : Bool
    
    override init(frame: CGRect)
    {
        self.isSelected = false
        
        self.contentView = UIView()
        
        super.init(frame: frame)
        
        self.autoresizesSubviews = false
        self.addSubview(self.contentView)
    }
    
    convenience init()
    {
        self.init(frame: CGRect.zero)
    }
    
    convenience init(reuseIdentifier: String!)
    {
        self.init()
        
        self.reuseIdentifier = reuseIdentifier
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        self.contentView.frame.size = self.frame.size
    }
}

