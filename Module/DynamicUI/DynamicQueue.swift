//
//  DynamicQueue.swift
//  Pacific
//
//  Created by Minh Nguyen on 9/28/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import UIKit

class DynamicQueue<ElementType> : Sequence
{
    private var _mainElementByIdentifier : [String:ElementType]
    private var _reservedElements : [ElementType]
    typealias Element = ElementType
    typealias Iterator = IndexingIterator<[ElementType]>
    
    init()
    {
        self._mainElementByIdentifier = [String:ElementType]()
        self._reservedElements = [ElementType]()
    }
    
    func makeIterator() -> IndexingIterator<[ElementType]>
    {
        return Array(self._mainElementByIdentifier.values).makeIterator()
    }
    
    func retrieveElement(withIdentifier identifier: String) -> ElementType?
    {
        let element = self._mainElementByIdentifier[identifier]
        
        return element
    }
    
    func dequeueElement(withIdentifier identifier: String, initialize: () -> ElementType) -> ElementType
    {
        var element = self._reservedElements.popLast()
        
        if (element == nil)
        {
            element = initialize()
        }
        
        self._mainElementByIdentifier[identifier] = element
                
        return element!
    }
    
    func enqueueElement(withIdentifier identifier: String, deinitialize: ((ElementType?) -> Void)?)
    {
        let element = self._mainElementByIdentifier[identifier]
        
        deinitialize?(element)
        
        if (element != nil)
        {
            self._mainElementByIdentifier.removeValue(forKey: identifier)
            self._reservedElements.append(element!)
        }
    }
    
    func purge(deinitialize: ((String, ElementType) -> Void)?)
    {
        for (identifier, element) in self._mainElementByIdentifier
        {
            deinitialize?(identifier, element)
        }
        
        self._mainElementByIdentifier = [String:ElementType]()
        self._reservedElements = [ElementType]()
    }
}



