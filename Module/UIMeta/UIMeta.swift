//
//  UIMeta.swift
//  Pacific
//
//  Created by Minh Nguyen on 10/3/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import UIKit

enum UIMetaType
{
    case header
    case cell
    case footer
}

class UIMeta : NSObject
{
    private var _size : CGSize
    private var _indexPath : IndexPath
    private var _type : UIMetaType
    private weak var _delegate : UIMetaDelegate!
    internal var _localOffset : CGPoint
    internal var _globalOffset : CGPoint
    internal weak var _view : UIView?
    var stack : Int!
    
    init(indexPath : IndexPath, type: UIMetaType, delegate: UIMetaDelegate)
    {
        self._size = CGSize.zero
        self._indexPath = indexPath
        self._type = type
        self._delegate = delegate
        self._localOffset = CGPoint.zero
        self._globalOffset = CGPoint.zero
        
        super.init()
    }
    
    var width : CGFloat
    {
        get
        {
            let width = self._size.width
            
            return width
        }
        
        set(newValue)
        {
            let oldWidth = self._size.width
            let newWidth = newValue
            self._delegate.meta?(self, willChangeWidthFrom: oldWidth, to: newWidth)
            self._size.width = newWidth
            self._delegate.meta?(self, didChangeWidthFrom: oldWidth, to: newWidth)
        }
    }
    
    var height : CGFloat
    {
        get
        {
            let height = self._size.height
            
            return height
        }
        
        set(newValue)
        {
            let oldHeight = self._size.height
            let newHeight = newValue
            self._delegate.meta?(self, willChangeHeightFrom: oldHeight, to: newHeight)
            self._size.height = newHeight
            self._delegate.meta?(self, didChangeHeightFrom: oldHeight, to: newHeight)
        }
    }
    
    var item : Int
    {
        get
        {
            let item = self._indexPath.item
            
            return item
        }
        
        set(newValue)
        {
            self._indexPath.row = newValue
        }
    }
    
    var section : Int
    {
        get
        {
            let section = self._indexPath.section
            
            return section
        }
    }
    
    var type : UIMetaType
    {
        get
        {
            let type = self._type
            
            return type
        }
    }
}
