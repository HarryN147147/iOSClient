//
//  DynamicService.swift
//  Pacific
//
//  Created by Minh Nguyen on 8/22/17.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

class DynamicService : DynamicViewModel
{
    func bind(){}
    func unbind(){}
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        let keyValueChange = NSKeyValueChange(rawValue: change![NSKeyValueChangeKey.kindKey] as! UInt)!
        
        if (keyValueChange == NSKeyValueChange.setting)
        {
            self.shouldSetKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        else if (keyValueChange == NSKeyValueChange.insertion)
        {
            self.shouldInsertKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        else if (keyValueChange == NSKeyValueChange.removal)
        {
            self.shouldRemoveKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        else if ((keyValueChange == NSKeyValueChange.replacement))
        {
            self.shouldReplaceKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func shouldSetKeyPath(_ keyPath: String?, ofObject object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){}
    
    func shouldInsertKeyPath(_ keyPath: String?, ofObject object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){}
    
    func shouldReplaceKeyPath(_ keyPath: String?, ofObject object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){}
    
    func shouldRemoveKeyPath(_ keyPath: String?, ofObject object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){}
}
