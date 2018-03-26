//
//  DynamicViewModelTransition.swift
//  Pacific
//
//  Created by Minh Nguyen on 1/23/18.
//  Copyright © 2018 Langtutheky. All rights reserved.
//

import Foundation

class DynamicViewModelTransition
{
    var transition : String
    var oldState : String
    var newState : String
    
    init(transition: String, oldState: String, newState: String)
    {
        self.transition = transition
        self.oldState = oldState
        self.newState = newState
    }
}
