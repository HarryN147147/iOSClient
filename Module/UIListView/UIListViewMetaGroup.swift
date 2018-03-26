//
//  UIListViewMetaGroup.swift
//  Pacific
//
//  Created by Minh Nguyen on 2/4/18.
//  Copyright © 2018 Langtutheky. All rights reserved.
//

import Foundation

class UIListViewMetaGroup : NSObject, UIMetaDelegate
{
    private var _width : CGFloat
    private var _height : CGFloat
    private var _initialOffset : CGFloat
    private var _cellMetas : [UIMeta]
    private var _headerMeta : UIMeta!
    private var _footerMeta : UIMeta!
    private var _cursoredItem : Int
    private var _section : Int
    private var _maxHeightByStack : [Int:CGFloat]
    private weak var _delegate : UIListViewMetaGroupDelegate!
    
    init(section: Int, initialOffset : CGFloat, width : CGFloat, delegate: UIListViewMetaGroupDelegate)
    {
        self._width = width
        self._height = 0
        self._initialOffset = initialOffset
        self._cellMetas = [UIMeta]()
        self._cursoredItem = 0
        self._section = section
        self._maxHeightByStack = [Int:CGFloat]()
        self._delegate = delegate
    }
    
    var headerMeta : UIMeta
    {
        get
        {
            if (self._headerMeta == nil)
            {
                self._headerMeta = UIMeta(indexPath: IndexPath(item: -1, section: section),
                                          type: UIMetaType.header,
                                          delegate: self)
            }
            
            let headerMeta = self._headerMeta!
            headerMeta._globalOffset.y = self._initialOffset
            
            return headerMeta
        }
    }
    
    var footerMeta : UIMeta
    {
        get
        {
            if (self._footerMeta == nil)
            {
                self._footerMeta = UIMeta(indexPath: IndexPath(item: 0, section: section),
                                          type: UIMetaType.footer,
                                          delegate: self)
            }
            
            let footerMeta = self._footerMeta!
            footerMeta._localOffset.y = self.headerMeta._localOffset.y + (self._height - footerMeta.height)
            footerMeta._globalOffset.y = footerMeta._localOffset.y + self._initialOffset
            
            return footerMeta
        }
    }
    
    var section : Int
    {
        get
        {
            let section = self._section
            
            return section
        }
    }
    
    var width : CGFloat
    {
        get
        {
            let width = self._width
            
            return width
        }
    }
    
    var height : CGFloat
    {
        get
        {
            let height = self._height
            
            return height
        }
    }
    
    var numberOfItems : Int
    {
        get
        {
            let numberOfItems = self._cellMetas.count
            
            return numberOfItems
        }
    }
    
    var initialOffset : CGFloat
    {
        get
        {
            let initialOffset = self._initialOffset
            
            return initialOffset
        }
        
        set(newValue)
        {
            self._initialOffset = newValue
        }
    }
    
    private func setHeight(_ height: CGFloat)
    {
        let oldHeight = self._height
        let newHeight = height
        self._delegate.listViewMetaGroup?(self, willChangeHeightFrom: oldHeight, to: newHeight)
        self._height = height
        self._delegate.listViewMetaGroup?(self, didChangeHeightFrom: oldHeight, to: newHeight)
    }
    
    private func setCellLocalOffset(for meta: UIMeta)
    {
        var previousMeta : UIMeta? = nil
        
        if (meta.item - 1 >= 0)
        {
            previousMeta = self._cellMetas[meta.item - 1]
        }
        
        if (meta.stack != nil && meta._localOffset.x == 0)
        {
            let maxHeight = self._maxHeightByStack[meta.stack]
            
            if (maxHeight != nil)
            {
                self.setHeight(self._height - maxHeight!)
                self._maxHeightByStack[meta.stack] = nil
            }
        }
        
        var localOffsetX : CGFloat = 0
        var localOffsetY : CGFloat = 0
        
        if (previousMeta != nil)
        {
            if (previousMeta!._localOffset.x + previousMeta!.width + meta.width <= self.width)
            {
                localOffsetX = previousMeta!._localOffset.x + previousMeta!.width
                localOffsetY = previousMeta!._localOffset.y
                meta.stack = previousMeta!.stack
            }
            else
            {
                localOffsetY = previousMeta!._localOffset.y + self._maxHeightByStack[previousMeta!.stack]!
                meta.stack = previousMeta!.stack + 1
            }
        }
        
        let localOffset = CGPoint(x: localOffsetX, y: localOffsetY)
        meta._localOffset = localOffset

        if (meta.stack == nil)
        {
            meta.stack = 0
        }
        
        var maxHeight : CGFloat! = self._maxHeightByStack[meta.stack]
        
        if (maxHeight == nil)
        {
            maxHeight = 0
        }

        if (maxHeight <= meta.height)
        {
            self.setHeight(self._height - maxHeight + meta.height)
            self._maxHeightByStack[meta.stack] = meta.height
        }
    }
    
    private func setCellLocalOffset(from startIndex: Int, to endIndex: Int)
    {
        for index in startIndex...endIndex
        {
            let meta = self._cellMetas[index]
            self.setCellLocalOffset(for: meta)
        }
    }
    
    private func setCellLocalOffsetIfNeeded(for meta: UIMeta)
    {
        if (meta.item < self._cellMetas.count && meta.type == UIMetaType.cell)
        {
            if (meta.item > self._cursoredItem)
            {
                self.setCellLocalOffset(from: self._cursoredItem + 1, to: meta.item)
                self._cursoredItem = meta.item
            }
        }
    }
    
    func appendCellMeta(size: CGSize)
    {
        let numberOfMetas = self._cellMetas.count
        let indexPath = IndexPath(item: numberOfMetas, section: self._section)
        let meta = UIMeta(indexPath: indexPath, type: UIMetaType.cell, delegate: self)
        meta.width = size.width
        meta.height = size.height
        self.setCellLocalOffset(for: meta)
        self.footerMeta.item = indexPath.item + 1
        self._cellMetas.append(meta)
    }
    
    func getMeta(at item: Int) -> UIMeta
    {
        var meta : UIMeta! = nil
        
        if (item == -1)
        {
            meta = self.headerMeta
        }
        else if (item == self._cellMetas.count)
        {
            meta = self.footerMeta
        }
        else
        {
            meta = self._cellMetas[item]
            self.setCellLocalOffsetIfNeeded(for: meta)
            meta._globalOffset.x = meta._localOffset.x
            meta._globalOffset.y = meta._localOffset.y + self.headerMeta._localOffset.y + self.headerMeta.height + self._initialOffset
        }
        
        return meta
    }
    
    private func setCursoredMetaIfNeeded(for meta: UIMeta)
    {
        if (meta.item < self._cellMetas.count && self._cellMetas.count > 0)
        {
            var cursoredMeta = meta
            
            for index in (0...meta.item).reversed()
            {
                let cellMeta = self._cellMetas[index]
                
                if (cellMeta._localOffset.y == meta._localOffset.y)
                {
                    if (cellMeta._localOffset.x == 0)
                    {
                        cursoredMeta = cellMeta
                        break
                    }
                    else
                    {
                        continue
                    }
                }
                else
                {
                    break
                }
            }
            
            self.setCellLocalOffsetIfNeeded(for: cursoredMeta)
            self._cursoredItem = cursoredMeta.item - 1
        }
    }
    
    func meta(_ meta: UIMeta, didChangeWidthFrom oldWidth: CGFloat, to newWidth: CGFloat)
    {
        if (meta.type == UIMetaType.cell)
        {
            self.setCursoredMetaIfNeeded(for: meta)
        }
    }
    
    func meta(_ meta: UIMeta, didChangeHeightFrom oldHeight: CGFloat, to newHeight: CGFloat)
    {
        if (meta.type == UIMetaType.cell)
        {
            self.setCursoredMetaIfNeeded(for: meta)
        }
        else
        {
            self.setHeight(self._height - oldHeight + newHeight)
        }
    }
}

