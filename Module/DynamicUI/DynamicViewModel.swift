//
//  DynamicViewModel.swift
//  Pacific
//
//  Created by Minh Nguyen on 8/22/17.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

class DynamicViewModel :  NSObject
{
    private var _previousState : String?
    private var _state : String!
    private var _nextState : String?
    private var _event : String!
    private var _transitions : [DynamicViewModelTransition]
    private var _isTransitioning : Bool
    weak var delegate : DynamicViewModelDelegate?
    @objc dynamic var identifier : String?
    var tag: Int?
    
    override init()
    {
        self._transitions = [DynamicViewModelTransition]()
        self._isTransitioning = false
        
        super.init()
        
        self._state = "Default"
        self._event = "Enter" + self.state
    }
    
    init(state: String)
    {
        self._transitions = [DynamicViewModelTransition]()
        self._isTransitioning = false
        
        super.init()
        
        self._state = state
        self._event = "Enter" + self.state
    }
    
    var previousState : String?
    {
        get
        {
            let previousState = self._previousState
            
            return previousState
        }
    }
    
    var state : String
    {
        get
        {
            let state = self._state
            
            return state!
        }
    }
    
    var nextState : String?
    {
        get
        {
            let nextState = self._nextState
            
            return nextState
        }
    }
    
    @objc dynamic var event : String
    {
        get
        {
            let event = self._event
            
            return event!
        }
    }
    
    private func transitIfNeeded(transition: String, from oldState: String, to newState: String)
    {
        if (self._state != oldState)
        {
            fatalError("DynamicViewModel: Cannot Transition From Invalid State " + oldState + " To " + newState)
        }
        
        self._nextState = newState
        
        self.willChangeValue(forKey: "event")
        self._event = "Will" + transition
        self.didChangeValue(forKey: "event")
        
        self.willChangeValue(forKey: "event")
        self._event = "Leave" + oldState
        self.didChangeValue(forKey: "event")
        
        self._previousState = oldState
        self._state = newState
        self._nextState = nil
        self.delegate?.viewModel(self, transition: transition, from: oldState, to: newState)
        
        self.willChangeValue(forKey: "event")
        self._event = "Enter" + newState
        self.didChangeValue(forKey: "event")
        
        self.willChangeValue(forKey: "event")
        self._event = "Did" + transition
        self.didChangeValue(forKey: "event")
        
        if (transition == "Reset")
        {
            self._event = "Enter" + state
        }
    }
    
    func transit(transition: String, from oldState: String, to newState: String)
    {
        let transition = DynamicViewModelTransition(transition: transition, oldState: oldState, newState: newState)
        self._transitions.append(transition)
        
        if (!self._isTransitioning)
        {
            self._isTransitioning = true

            var counter = 0

            while (counter < self._transitions.count)
            {
                let currentTransition = self._transitions[counter]
                self.transitIfNeeded(transition: currentTransition.transition,
                                     from: currentTransition.oldState,
                                     to: currentTransition.newState)
                counter += 1
            }

            self._transitions = [DynamicViewModelTransition]()
            self._isTransitioning = false
        }
    }
    
    func transit(transition: String, to newState: String)
    {
        self.transit(transition: transition, from: self.state, to: newState)
    }
    
    func reset(state: String)
    {
        self.transit(transition: "Reset", to: state)
    }
    
    func reset()
    {
        self.reset(state: self.state)
    }
}
