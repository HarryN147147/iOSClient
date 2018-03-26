//
//  setting.swift
//  Venues
//
//  Created by Harry Nguyen on 3/18/18.
//  Copyright © 2018 Harry Nguyen. All rights reserved.
//

import UIKit

class TextViewModel: DynamicViewModel
{
    var content: String!
    init(content: String?)
    {
        super.init(state: "Inactive")
        self.content = content
    }
    
    @objc func begin()
    {
        self.transit(transition: "Begin", from: "Inactive", to: "Active")
    }
    
    @objc func change()
    {
        self.transit(transition: "Change", to: self.state)
    }
    
    @objc func complete()
    {
        self.transit(transition: "Complete", from: "Active", to: "Inactive")
    }
    
    @objc func clear()
    {
        self.transit(transition: "Clear", to: "Inactive")
    }
}


class UserInfoViewModel: DynamicViewModel
{
    @objc dynamic var jobTitle: String
    @objc dynamic var jobInitital: String
    private var _textViewModel: TextViewModel!
    
    init(jobInitital: String, jobTitle: String)
    {
        self.jobInitital = jobInitital
        self.jobTitle = jobTitle
        
        super.init()
        
       
    }
    
    var content: String?
    {
        get
        {
            let content = self._textViewModel.content
            
            return content
        }
        
        set(newValue)
        {
            self._textViewModel.content = newValue
        }
    }
    
    var textViewModel: TextViewModel
    {
        get
        {
            if(self._textViewModel ==  nil)
            {
                self._textViewModel = TextViewModel(content: nil)
            }
            
            let textViewModel = self._textViewModel!
            
            return textViewModel
        }
    }
    
    @objc func edit()
    {
        self.transit(transition: "Edit", to: self.state)
    }
    
    @objc func submit()
    {
        self.transit(transition: "Submit", to: self.state)
    }
    
    @objc func cancel()
    {
        self.transit(transition: "Cancel", to: self.state)
    }
}



