//
//  UIListView.swift
//  jasmine
//
//  Created by Minh Nguyen on 11/24/15.
//  Copyright © 2015 Minh Nguyen. All rights reserved.
//

import UIKit

enum UIListViewScrollPosition : Int
{
    case none
    case top
    case middle
    case bottom
}

enum UIListViewStyle : Int
{
    case plain = 0
    case grouped = 1
}

let UIListViewAutomaticDimension = UITableViewAutomaticDimension

class UIListView : UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIListViewMetaGroupDelegate
{
    private weak var _dataSource : UIListViewDataSource?
    private weak var _delegate : UIListViewDelegate?
    
    var itemSize : CGSize
    var estimatedItemSize : CGSize
    var sectionHeaderHeight: CGFloat
    var estimatedSectionHeaderHeight: CGFloat
    var sectionFooterHeight: CGFloat
    var estimatedSectionFooterHeight: CGFloat
    var isSlidingEnabled : Bool
    var slidingPosition : UIListViewScrollPosition
    var anchorPosition : UIListViewScrollPosition
    var slidingSpeed : Double
    var slidingDistance : CGFloat
    var allowsSelection : Bool
    var allowsMultipleSelection : Bool
    
    private var _shouldLoadPartialViews : Bool
    private var _contentHeight : CGFloat
    private var _numberOfItemsBySection : [Int:Int]
    private var _style : UIListViewStyle
    private var _listHeaderView : UIView?
    private var _listFooterView : UIView?
    private var _isSlidingAllowed : Bool
    private var _initialOffset : CGPoint
    private var _decelerationOffset : CGPoint?
    private var _previousOffset : CGPoint
    private var _visibleIndexPaths : [IndexPath]
    private var _selectedIndexPaths : [IndexPath]
    private var _focusSectionHeaderIndexPath : IndexPath?
    private var _focusSectionFooterIndexPath : IndexPath?
    private var _slidingIndexPath : IndexPath?
    private var _metaGroups : [UIListViewMetaGroup]
    private var _modifiedMetaGroup : UIListViewMetaGroup?
    private var _scrollingAnimations : [UIListViewScrollingAnimation]
    private var _tapGestureRecognizer : UITapGestureRecognizer
    
    override init(frame: CGRect)
    {
        self.itemSize = CGSize(width: UIListViewAutomaticDimension, height: UIListViewAutomaticDimension)
        self.estimatedItemSize = CGSize(width: UIListViewAutomaticDimension, height: UIListViewAutomaticDimension)
        self.sectionHeaderHeight = UIListViewAutomaticDimension
        self.estimatedSectionHeaderHeight = UIListViewAutomaticDimension
        self.sectionFooterHeight = UIListViewAutomaticDimension
        self.estimatedSectionFooterHeight = UIListViewAutomaticDimension
        
        self.isSlidingEnabled = false
        self.slidingPosition = UIListViewScrollPosition.top
        self.anchorPosition = UIListViewScrollPosition.none
        self.slidingSpeed = 0.35
        self.slidingDistance = 0
        self.allowsSelection = true
        self.allowsMultipleSelection = false
        
        self._shouldLoadPartialViews = false
        self._contentHeight = 0
        self._numberOfItemsBySection = [Int:Int]()
        self._style = UIListViewStyle.plain
        self._isSlidingAllowed = false
        self._initialOffset = CGPoint.zero
        self._previousOffset = CGPoint.zero
        self._visibleIndexPaths = [IndexPath]()
        self._selectedIndexPaths = [IndexPath]()
        self._metaGroups = [UIListViewMetaGroup]()
        self._scrollingAnimations = [UIListViewScrollingAnimation]()
        self._tapGestureRecognizer = UITapGestureRecognizer()
        
        super.init(frame: frame)
        
        self.alwaysBounceHorizontal = false
        self.alwaysBounceVertical = true
        self.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 241/255, alpha: 1)
        
        self._tapGestureRecognizer.addTarget(self, action: #selector(UIListView.toggleCell(_:)))
        self._tapGestureRecognizer.cancelsTouchesInView = false
        self._tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(self._tapGestureRecognizer)
    }
    
    convenience init(frame: CGRect, style: UIListViewStyle)
    {
        self.init(frame: CGRect.zero)
        
        self._style = style
    }
    
    convenience init(style: UIListViewStyle)
    {
        self.init(frame: CGRect.zero)
        
        self._style = style
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var delegate: UIScrollViewDelegate?
    {
        get
        {
            let delegate = self._delegate
            
            return delegate
        }
        
        set(newValue)
        {
            if (newValue != nil)
            {
                self._delegate = newValue as? UIListViewDelegate
                super.delegate = self
            }
        }
    }
    
    var dataSource : UIListViewDataSource?
    {
        get
        {
            return self._dataSource
        }
        
        set(newValue)
        {
            self._dataSource = newValue
        }
    }
    
    var style : UIListViewStyle
    {
        get
        {
            let style = self._style
            
            return style
        }
    }
    
    var listHeaderView : UIView?
    {
        get
        {
            let listHeaderView = self._listHeaderView
            
            return listHeaderView
        }
        
        set(newValue)
        {
            if (self._listHeaderView != nil)
            {
                self._listHeaderView!.removeFromSuperview()
                self._contentHeight -= self._listHeaderView!.frame.height
            }
            
            self._listHeaderView = newValue
            self._contentHeight += self._listHeaderView!.frame.height
        }
    }
    
    var listFooterView : UIView?
    {
        get
        {
            let listFooterView = self._listFooterView
            
            return listFooterView
        }
        
        set(newValue)
        {
            if (self._listFooterView != nil)
            {
                self._listFooterView!.removeFromSuperview()
                self._contentHeight -= self._listFooterView!.frame.height
            }
            
            self._listFooterView = newValue
            self._contentHeight += self._listFooterView!.frame.height
        }
    }
    
    var visibleCells : [UIListViewCell]
    {
        get
        {
            var visibleCells = [UIListViewCell]()
            
            for visibleIndexPath in self._visibleIndexPaths
            {
                let meta = self.getMeta(item: visibleIndexPath.item, section: visibleIndexPath.section)
                
                if (meta.type == UIMetaType.cell)
                {
                    visibleCells.append(meta._view as! UIListViewCell)
                }
            }
            
            return visibleCells
        }
    }
    
    var indexPathsForVisibleItems : [IndexPath]?
    {
        get
        {
            var indexPaths : [IndexPath]? = nil
            
            if (self._visibleIndexPaths.count > 0)
            {
                indexPaths = [IndexPath]()
                
                for visibleIndexPath in self._visibleIndexPaths
                {
                    let meta = self.getMeta(item: visibleIndexPath.item, section: visibleIndexPath.section)
                    
                    if (meta.type == UIMetaType.cell)
                    {
                        let indexPath = IndexPath(item: meta.item, section: meta.section)
                        indexPaths!.append(indexPath)
                    }
                }
            }
            
            return indexPaths
        }
    }
    
    var indexPathForSelectedItem : IndexPath?
    {
        get
        {
            var indexPath : IndexPath? = nil
            
            for selectedIndexPath in self._selectedIndexPaths
            {
                let meta = self.getMeta(item: selectedIndexPath.item, section: selectedIndexPath.section)
                
                if (meta.type == UIMetaType.cell)
                {
                    indexPath = IndexPath(item: meta.item, section: meta.section)
                    break
                }
            }
            
            return indexPath
        }
    }
    
    var indexPathsForSelectedItems : [IndexPath]?
    {
        get
        {
            var indexPaths : [IndexPath]? = nil
            
            if (self._selectedIndexPaths.count > 0)
            {
                indexPaths = [IndexPath]()
                
                for selectedIndexPath in self._selectedIndexPaths
                {
                    let meta = self.getMeta(item: selectedIndexPath.item, section: selectedIndexPath.section)
                    
                    if (meta.type == UIMetaType.cell)
                    {
                        let indexPath = IndexPath(item: meta.item, section: meta.section)
                        indexPaths!.append(indexPath)
                    }
                }
            }
            
            return indexPaths
        }
    }
    
    var numberOfSections : Int
    {
        get
        {
            let numberOfSections = self._metaGroups.count
            
            return numberOfSections
        }
    }

    func numberOfItems(inSection section: Int) -> Int
    {
        if (self._numberOfItemsBySection[section] == nil)
        {
            self._numberOfItemsBySection[section] = self._metaGroups[section].numberOfItems
        }
        
        let numberOfItems = self._numberOfItemsBySection[section]
        
        return numberOfItems!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self._delegate?.scrollViewDidScroll?(self)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        self._delegate?.scrollViewWillBeginDragging?(self)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    {
        self._delegate?.scrollViewWillBeginDecelerating?(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        self._delegate?.scrollViewDidEndDecelerating?(self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if (self.isSlidingEnabled)
        {
            self._decelerationOffset = targetContentOffset.pointee
            targetContentOffset.pointee = self.contentOffset
        }
        
        self._delegate?.scrollViewWillEndDragging?(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if (self.isSlidingEnabled)
        {
            if (self.visibleCells.count < 2 && self._slidingIndexPath != nil)
            {
                return
            }
            
            let currentIndexPath = self._slidingIndexPath!
            
            if (self._decelerationOffset!.y <= self._initialOffset.y)
            {
                self._isSlidingAllowed = true
                let slidingDistance = self.getSlidingDistanceForCellAt(indexPath: currentIndexPath)

                if (self._initialOffset.y - self._decelerationOffset!.y >= slidingDistance)
                {
                    let previousIndexPath = self.getPreviousIndexPath(from: currentIndexPath)
                    
                    if (previousIndexPath != nil)
                    {
                        self.scrollToItem(at: previousIndexPath!, at: self.slidingPosition, animated: true)
                    }
                }
                else
                {
                    self.scrollToItem(at: currentIndexPath, at: self.slidingPosition, animated: true)
                }
            }
            else
            {
                self._isSlidingAllowed = true
                let slidingDistance = self.getSlidingDistanceForCellAt(indexPath: currentIndexPath)
                
                if (self._decelerationOffset!.y - self._initialOffset.y >= slidingDistance)
                {
                    let nextIndexPath = self.getNextIndexPath(from: currentIndexPath)
                    
                    if (nextIndexPath != nil)
                    {
                        self.scrollToItem(at: nextIndexPath!, at: self.slidingPosition, animated: true)
                    }
                }
                else
                {
                    self.scrollToItem(at: currentIndexPath, at: self.slidingPosition, animated: true)
                }
            }
        }
        
        self._delegate?.scrollViewDidEndDragging?(self, willDecelerate: decelerate)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        self.loadViews()
        
        if (self.contentOffset.y + self.frame.height > self.contentSize.height)
        {
            self.contentOffset.y = self.contentSize.height - self.frame.height
        }
        else if (self.contentOffset.y < 0)
        {
            self.contentOffset.y = 0
        }
        
        self._delegate?.scrollViewDidEndScrollingAnimation?(self)
    }
    
    private func animateViewsIfNeeded()
    {
        if (self._scrollingAnimations.count > 0)
        {
            for scrollingAnimation in self._scrollingAnimations
            {
                self.animate(scrollingAnimation)
            }
            
            self._scrollingAnimations = [UIListViewScrollingAnimation]()
        }
    }
    
    private func loadHeaderViewIfNeeded()
    {
        if (self._listHeaderView != nil)
        {
            self._listHeaderView!.frame.origin.y = 0
            
            if (self._listHeaderView!.superview == nil)
            {
                self.addSubview(self._listHeaderView!)
            }
            
            for visibleIndexPath in self._visibleIndexPaths
            {
                let meta = self.getMeta(item: visibleIndexPath.item, section: visibleIndexPath.section)
                
                if (meta._view != nil)
                {
                    meta._view!.frame.origin.y = meta._globalOffset.y
                }
            }
        }
    }
    
    private func loadFooterViewIfNeeded()
    {
        if (self._listFooterView != nil)
        {
            if (self._listFooterView!.superview == nil)
            {
                self.addSubview(self._listFooterView!)
            }
            
            self._listFooterView!.frame.origin.y = self.contentSize.height - self._listFooterView!.frame.height
        }
    }
    
    private func displaySectionHeaderViewIfNeeded()
    {
        if (self._visibleIndexPaths.count > 0)
        {
            if (self._focusSectionHeaderIndexPath != nil)
            {
                let headerMeta = self.getMeta(item: self._focusSectionHeaderIndexPath!.item,
                                              section: self._focusSectionHeaderIndexPath!.section)
                
                if (headerMeta._view != nil)
                {
                    headerMeta._view!.frame.origin.y = headerMeta._globalOffset.y
                }
                
                self._focusSectionHeaderIndexPath = nil
            }
            
            let focusSection = self._visibleIndexPaths.first!.section
            let headerMeta = self.getMeta(item: -1, section: focusSection)
            let footerMeta = self.getMeta(item: self.numberOfItems(inSection: focusSection), section: focusSection)
            
            var headerOriginY = self.contentOffset.y
            
            var minimumOffsetY = headerMeta._globalOffset.y
            
            if (self._listHeaderView != nil)
            {
                minimumOffsetY += self._listHeaderView!.frame.height
            }
            
            if (headerOriginY < minimumOffsetY)
            {
                headerOriginY = minimumOffsetY
            }

            if (headerMeta.height + headerOriginY > footerMeta._globalOffset.y)
            {
                headerOriginY = footerMeta._globalOffset.y - headerMeta.height
            }
            
            let indexPath = IndexPath(item: headerMeta.item, section: headerMeta.section)
            
            if (headerMeta._view == nil)
            {
                self.displayView(at: indexPath)
            }
            else
            {
                self.addSubview(headerMeta._view!)
            }
            
            headerMeta._view!.frame.origin.y = headerOriginY
            self._focusSectionHeaderIndexPath = indexPath
        }
    }
    
    private func displaySectionFooterViewIfNeeded()
    {
        if (self._visibleIndexPaths.count > 0)
        {
            if (self._focusSectionFooterIndexPath != nil)
            {
                let footerMeta = self.getMeta(item: self._focusSectionFooterIndexPath!.item,
                                              section: self._focusSectionFooterIndexPath!.section)
                
                if (footerMeta._view != nil)
                {
                    footerMeta._view!.frame.origin.y = footerMeta._globalOffset.y
                }
                
                self._focusSectionFooterIndexPath = nil
            }
            
            let focusSection = self._visibleIndexPaths.last!.section
            let headerMeta = self.getMeta(item: -1, section: focusSection)
            let footerMeta = self.getMeta(item: self.numberOfItems(inSection: focusSection), section: focusSection)

            var footerOriginY = self.contentOffset.y + self.frame.height - footerMeta.height

            if (footerOriginY > footerMeta._globalOffset.y)
            {
                footerOriginY = footerMeta._globalOffset.y
            }
            
            if (footerOriginY < headerMeta._globalOffset.y + headerMeta.height)
            {
                footerOriginY = headerMeta._globalOffset.y + headerMeta.height
            }

            let indexPath = IndexPath(item: footerMeta.item, section: footerMeta.section)
            
            if (footerMeta._view == nil)
            {
                self.displayView(at: indexPath)
            }
            else
            {
                self.addSubview(footerMeta._view!)
            }

            footerMeta._view!.frame.origin.y = footerOriginY
            self._focusSectionFooterIndexPath = indexPath
        }
    }
    
    override func layoutSubviews()
    {
        if ((self.contentSize.width - self.frame.width) > 1 && self._shouldLoadPartialViews)
        {
            self.reloadData()
        }
        
        self.loadViews()
        self.animateViewsIfNeeded()
        self.anchorViewsIfNeeded()
    }
    
    private func anchorViewsIfNeeded()
    {
        if (self.anchorPosition != UIListViewScrollPosition.none)
        {
            if (self.contentSize.height < self.frame.height)
            {
                self.isScrollEnabled = false
                
                if (self.anchorPosition == UIListViewScrollPosition.bottom)
                {
                    self.contentOffset.y = self.contentSize.height - self.frame.height
                }
                else if (self.anchorPosition == UIListViewScrollPosition.middle)
                {
                    self.contentOffset.y = (self.contentSize.height - self.frame.height) / 2
                }                
            }
            else
            {
                self.isScrollEnabled = true
            }
        }
    }
    
    private func getSlidingDistanceForCellAt(indexPath: IndexPath) -> CGFloat
    {
        var slidingDistance = self._delegate?.listView?(self, slidingDistanceForItemAt: indexPath)
        
        if (slidingDistance == nil)
        {
            slidingDistance = self.slidingDistance
        }
        
        return slidingDistance!
    }
    
    private func getEstimatedSectionHeaderHeightAt(section: Int) -> CGFloat
    {
        var estimatedSectionHeaderHeight = self._delegate?.listView?(self, estimatedHeightForHeaderInSection: section)
        
        if (estimatedSectionHeaderHeight == nil)
        {
            estimatedSectionHeaderHeight = self.estimatedSectionHeaderHeight
        }
        
        if (estimatedSectionHeaderHeight == UIListViewAutomaticDimension)
        {
            if (self.style == UIListViewStyle.plain)
            {
                estimatedSectionHeaderHeight = 40
            }
            else if (self.style == UIListViewStyle.grouped)
            {
                estimatedSectionHeaderHeight = 60
            }
        }
        
        return estimatedSectionHeaderHeight!
    }
    
    private func getEstimatedItemSizeAt(indexPath: IndexPath) -> CGSize
    {
        var estimatedItemSize : CGSize! = self._delegate?.listView?(self, estimatedSizeForItemAt: indexPath)
        
        if (estimatedItemSize == nil)
        {
            estimatedItemSize = self.estimatedItemSize
        }
        
        if (estimatedItemSize.height == UIListViewAutomaticDimension)
        {
            estimatedItemSize.height = 40
        }
        
        if (estimatedItemSize.width == UIListViewAutomaticDimension)
        {
            estimatedItemSize.width = self.frame.width
        }
        
        return estimatedItemSize
    }
    
    private func getEstimatedSectionFooterHeightAt(section: Int) -> CGFloat
    {
        var estimatedSectionFooterHeight = self._delegate?.listView?(self, estimatedHeightForFooterInSection: section)
        
        if (estimatedSectionFooterHeight == nil)
        {
            estimatedSectionFooterHeight = self.estimatedSectionFooterHeight
        }
        
        if (estimatedSectionFooterHeight == UIListViewAutomaticDimension)
        {
            if (self.style == UIListViewStyle.plain)
            {
                estimatedSectionFooterHeight = 40
            }
            else if (self.style == UIListViewStyle.grouped)
            {
                estimatedSectionFooterHeight = 40
            }
        }
        
        return estimatedSectionFooterHeight!
    }
    
    private func getSectionHeaderHeightAt(section: Int) -> CGFloat
    {
        var sectionHeaderHeight = self._delegate?.listView?(self, heightForHeaderInSection: section)
        
        if (sectionHeaderHeight == nil)
        {
            sectionHeaderHeight = self.sectionHeaderHeight
        }
        
        if (sectionHeaderHeight == UIListViewAutomaticDimension)
        {
            if (self.style == UIListViewStyle.plain)
            {
                sectionHeaderHeight = 40
            }
            else if (self.style == UIListViewStyle.grouped)
            {
                sectionHeaderHeight = 60
            }
        }
        
        return sectionHeaderHeight!
    }
    
    private func getItemSizeAt(indexPath: IndexPath) -> CGSize
    {
        var itemSize : CGSize! = self._delegate?.listView?(self, sizeForItemAt: indexPath)
        
        if (itemSize == nil)
        {
            itemSize = self.itemSize
        }
        
        if (itemSize.height == UIListViewAutomaticDimension)
        {
            itemSize.height = 40
        }
        
        if (itemSize.width == UIListViewAutomaticDimension)
        {
            itemSize.width = self.frame.width
        }
        
        return itemSize
    }
    
    private func getSectionFooterHeightAt(section: Int) -> CGFloat
    {
        var sectionFooterHeight = self._delegate?.listView?(self, heightForFooterInSection: section)
        
        if (sectionFooterHeight == nil)
        {
            sectionFooterHeight = self.sectionFooterHeight
        }
        
        if (sectionFooterHeight == UIListViewAutomaticDimension)
        {
            if (self.style == UIListViewStyle.plain)
            {
                sectionFooterHeight = 40
            }
            else if (self.style == UIListViewStyle.grouped)
            {
                sectionFooterHeight = 40
            }
        }
        
        return sectionFooterHeight!
    }
    
    private func getContentView(text: String?, type: UIMetaType) -> UIListViewHeaderFooterContentView
    {
        var title = text
        var font = UIFont.boldSystemFont(ofSize: 17)
        var textColor = UIColor(red: 115/255, green: 115/255, blue: 120/255, alpha: 1)
        
        if (self.style == UIListViewStyle.plain)
        {
            textColor = UIColor.black
        }
        
        if (type == UIMetaType.header)
        {
            if (self.style == UIListViewStyle.grouped)
            {
                title = text?.uppercased()
                font = UIFont.systemFont(ofSize: 16)
            }
        }
        else if (type == UIMetaType.footer)
        {
            if (self.style == UIListViewStyle.grouped)
            {
                font = UIFont.systemFont(ofSize: 15)
            }
        }
        
        let contentView = UIListViewHeaderFooterContentView()
        contentView.label.font = font
        contentView.label.textColor = textColor
        contentView.label.text = title
        
        if (self.style == UIListViewStyle.plain)
        {
            contentView.backgroundColor = self.backgroundColor
        }
        
        return contentView
    }
    
    private func setViewFrameIfNeeded(at indexPath: IndexPath)
    {
        let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
        
        if (meta._view != nil)
        {
            meta._view!.frame = CGRect(x: meta._globalOffset.x,
                                       y: meta._globalOffset.y,
                                       width: meta.width,
                                       height: meta.height)
        }
    }
    
    private func displayCellViewForRowIfNeeded(at indexPath: IndexPath) -> Bool
    {
        var shouldDisplayCellView = false
        let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
        
        if (meta._view == nil)
        {
            if (meta.type == UIMetaType.cell)
            {
                self.displayView(at: indexPath)
                
                if (meta._view!.frame.origin.y + meta._view!.frame.height  < self.contentOffset.y || meta._view!.frame.origin.y > self.contentOffset.y + self.frame.height)
                {
                    self.endDisplayView(at: indexPath)
                }
                else
                {
                    shouldDisplayCellView = true
                }
            }
        }
        else
        {
            self.setViewFrameIfNeeded(at: indexPath)
        }
        
        return shouldDisplayCellView
    }
    
    private func displayNextCellViewsIfNeeded(from indexPath: IndexPath)
    {
        let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
        
        if (meta._globalOffset.x + meta.width < self.frame.width)
        {
            if (indexPath.item + 1 <= self.numberOfItems(inSection: indexPath.section) - 1)
            {
                for item in indexPath.item + 1...self.numberOfItems(inSection: indexPath.section) - 1
                {
                    let nextIndexPath = IndexPath(item: item, section: indexPath.section)
                    
                    if (self.displayCellViewForRowIfNeeded(at: nextIndexPath))
                    {
                        self._visibleIndexPaths.append(nextIndexPath)
                        
                        let nextMeta = self.getMeta(item: nextIndexPath.item, section: nextIndexPath.section)
                        
                        if (nextMeta._globalOffset.x + nextMeta.width == self.frame.width)
                        {
                            break
                        }
                    }
                    else
                    {
                        break
                    }
                }
            }
        }
    }
    
    private func displayPreviousCellViewsIfNeeded(from indexPath: IndexPath)
    {
        let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
        
        if (meta._globalOffset.x > 0)
        {
            if (indexPath.item - 1 >= 0)
            {
                for item in (0...indexPath.item - 1).reversed()
                {
                    let previousIndexPath = IndexPath(item: item, section: indexPath.section)
                    
                    if (self.displayCellViewForRowIfNeeded(at: previousIndexPath))
                    {
                        self._visibleIndexPaths.insert(previousIndexPath, at: 0)
                        
                        let previousMeta = self.getMeta(item: previousIndexPath.item, section: previousIndexPath.section)
                        
                        if (previousMeta._globalOffset.x == 0)
                        {
                            break
                        }
                    }
                    else
                    {
                        break
                    }
                }
            }
        }
    }
    
    private func displayView(at indexPath: IndexPath)
    {
        let meta = self.getMeta(item: indexPath.item, section: indexPath.section)

        if (meta._view == nil)
        {
            if (meta.type == UIMetaType.header)
            {
                var headerView = self._delegate?.listView?(self, viewForHeaderInSection: meta.section)
                
                if (headerView == nil)
                {
                    let title = self._dataSource!.listView?(self, titleForHeaderInSection: meta.section)
                    
                    if (title != nil || self.style == UIListViewStyle.plain)
                    {
                        headerView = self.getContentView(text: title, type: meta.type)
                    }
                }
                
                meta._view = headerView
                self.assertSize(at: indexPath)
                
                if (headerView != nil)
                {
                    self.setViewFrameIfNeeded(at: indexPath)
                    self._delegate?.listView?(self, willDisplayHeaderView: headerView!, forSection: indexPath.section)
                    self.addSubview(headerView!)
                }
            }
            else if (meta.type == UIMetaType.footer)
            {
                var footerView = self._delegate?.listView?(self, viewForFooterInSection: meta.section)
                
                if (footerView == nil)
                {
                    let title = self._dataSource!.listView?(self, titleForFooterInSection: meta.section)
                    
                    if (title != nil || self.style == UIListViewStyle.plain)
                    {
                        footerView = self.getContentView(text: title, type: meta.type)
                    }
                }
                
                meta._view = footerView
                self.assertSize(at: indexPath)
                
                if (footerView != nil)
                {
                    self.setViewFrameIfNeeded(at: indexPath)
                    self._delegate?.listView?(self, willDisplayFooterView: footerView!, forSection: indexPath.section)
                    self.addSubview(footerView!)
                }
            }
            else
            {
                let cell = self.dataSource!.listView(self, cellForItemAt: indexPath)
                meta._view = cell
                self.assertSize(at: indexPath)
                self.setViewFrameIfNeeded(at: indexPath)
                self._delegate?.listView?(self, willDisplay: cell, forItemAt: indexPath)
                self.addSubview(cell)
            }
        }
        else
        {
            self.setViewFrameIfNeeded(at: indexPath)
        }
    }
    
    private func endDisplayView(at indexPath: IndexPath)
    {
        let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
        
        if (meta._view != nil)
        {
            meta._view!.removeFromSuperview()
            
            if (meta.type == UIMetaType.header)
            {
                self._delegate?.listView?(self, didEndDisplayingHeaderView: meta._view!, forSection: meta.section)
            }
            else if (meta.type == UIMetaType.footer)
            {
                self._delegate?.listView?(self, didEndDisplayingFooterView: meta._view!, forSection: meta.section)
            }
            else
            {
                let cell = meta._view as! UIListViewCell
                self._delegate?.listView?(self, didEndDisplaying: cell, forItemAt: indexPath)
            }
            
            meta._view = nil
        }
    }
    
    private func getMeta(item: Int, section: Int) -> UIMeta
    {
        self.setInitialOffsetIfNeeded(at: section)
        let metaGroup = self._metaGroups[section]
        let meta = metaGroup.getMeta(at: item)
        
        if (self._listHeaderView != nil)
        {
            meta._globalOffset.y += self._listHeaderView!.frame.height
        }
        
        return meta
    }

    private func setInitialOffset(from startIndex: Int, to endIndex: Int, with initialOffset: CGFloat)
    {
        var initialOffset = initialOffset
        
        for index in startIndex...endIndex
        {
            let metaGroup = self._metaGroups[index]
            metaGroup.initialOffset = initialOffset
            initialOffset += metaGroup.height
        }
    }
    
    private func setInitialOffsetIfNeeded(at section: Int)
    {
        if (self._modifiedMetaGroup != nil)
        {
            if (section > self._modifiedMetaGroup!.section)
            {
                let initialOffset = self._modifiedMetaGroup!.initialOffset + self._modifiedMetaGroup!.height
                self.setInitialOffset(from: self._modifiedMetaGroup!.section  + 1,
                                      to: section,
                                      with: initialOffset)
                self._modifiedMetaGroup = self._metaGroups[section]
            }
        }
    }
    
    private func assertSize(at indexPath: IndexPath)
    {
        let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
        var size = CGSize(width: self.frame.width, height: 0)
        
        if (meta.type == UIMetaType.header)
        {
            size.height = self.getSectionHeaderHeightAt(section: indexPath.section)
        }
        else if (meta.type == UIMetaType.footer)
        {
            size.height = self.getSectionFooterHeightAt(section: indexPath.section)
        }
        else
        {
            size = self.getItemSizeAt(indexPath: indexPath)
        }
        
        if (meta.type == UIMetaType.header || meta.type == UIMetaType.footer)
        {
            if (meta._view != nil &&
                meta._view is UIListViewHeaderFooterContentView &&
                self.numberOfSections == 1)
            {
                let view = meta._view as! UIListViewHeaderFooterContentView
                
                if (view.label.text == nil || view.label.text == "")
                {
                    size.height = 0
                }
            }            
        }
        
        if (meta.width != size.width || meta.height != size.height)
        {
            let metaGroup = self._metaGroups[indexPath.section]
            
            if (meta.height != size.height)
            {
                meta.height = size.height
            }
            
            if (meta.width != size.width)
            {
                meta.width = size.width
            }
            
            self.setInitialOffsetIfNeeded(at: indexPath.section)
            self._modifiedMetaGroup = metaGroup
        }
    }

    private func loadMetaGroups()
    {
        var numberOfSections = self.dataSource?.numberOfSections?(in: self)
        
        if (numberOfSections == nil)
        {
            numberOfSections = 1
        }
        
        self._contentHeight = 0
        
        for section in 0...numberOfSections! - 1
        {
            let metaGroup = UIListViewMetaGroup(section: section,
                                                initialOffset: self._contentHeight,
                                                width: self.frame.width,
                                                delegate: self)
            self._metaGroups.append(metaGroup)
            
            let estimatedSectionHeaderHeight = self.getEstimatedSectionHeaderHeightAt(section: section)
            metaGroup.headerMeta.width = self.frame.width
            metaGroup.headerMeta.height = estimatedSectionHeaderHeight
            
            let estimatedSectionFooterHeight = self.getEstimatedSectionFooterHeightAt(section: section)
            metaGroup.footerMeta.width = self.frame.width
            metaGroup.footerMeta.height = estimatedSectionFooterHeight
            
            let numberOfItems = self.dataSource?.listView(self, numberOfItemsInSection: section)

            if (numberOfItems != nil && numberOfItems! > 0)
            {
                for counter in 0...numberOfItems! - 1
                {
                    let indexPath = IndexPath(item: counter, section: section)
                    let estimatedItemSize = self.getEstimatedItemSizeAt(indexPath: indexPath)
                    metaGroup.appendCellMeta(size: estimatedItemSize)
                }                
            }
        }
        
        if (self._listHeaderView != nil)
        {
            self._contentHeight += self._listHeaderView!.frame.height
        }
        
        if (self._listFooterView != nil)
        {
            self._contentHeight += self._listFooterView!.frame.height
        }
    }
    
    private func loadViews()
    {
        self.loadHeaderViewIfNeeded()
        
        if (self._shouldLoadPartialViews)
        {
            self.loadPartialViews()
        }
        else
        {
            self.loadInitialViews()
        }
        
        self.contentSize = CGSize(width: self.frame.width, height: self._contentHeight)
        self.loadFooterViewIfNeeded()
        
        if (self.style == UIListViewStyle.plain)
        {
            self.displaySectionHeaderViewIfNeeded()
            self.displaySectionFooterViewIfNeeded()
        }
    }
    
    private func unloadViews()
    {
        for visibleIndexPath in self._visibleIndexPaths
        {
            self.endDisplayView(at: visibleIndexPath)
        }
        
        self._visibleIndexPaths = [IndexPath]()
        self._selectedIndexPaths = [IndexPath]()
    }
    
    private func loadInitialViews()
    {
        if (self.dataSource != nil)
        {
            if (self._metaGroups.count == 0)
            {
                self.loadMetaGroups()
            }
            
            if (self._metaGroups.count > 0)
            {
                if (self.contentOffset.y < 0)
                {
                    self.contentOffset.y = 0
                }
                
                let lastContentOffset = self.contentOffset
             
                findMetaGroup:
                for metaGroup in self._metaGroups
                {
                    let initialMeta = self.getMeta(item: -1, section: metaGroup.section)
                    
                    if (initialMeta._globalOffset.y < lastContentOffset.y + self.frame.height)
                    {
                        let indexPath = IndexPath(item: initialMeta.item, section: initialMeta.section)
                        self.displayView(at: indexPath)
                        self._visibleIndexPaths.append(indexPath)
                    }
                    
                    self.loadBottomViews()
                }
                
                self.setContentOffset(lastContentOffset, animated: false)
                self._previousOffset = lastContentOffset
                self._shouldLoadPartialViews = true
            }
        }
    }
    
    private func getPreviousIndexPath(from currentIndexPath: IndexPath) -> IndexPath?
    {
        var previousIndexPath : IndexPath? = nil
        
        if (currentIndexPath.item - 1 >= -1)
        {
            previousIndexPath = IndexPath(item: currentIndexPath.item - 1, section: currentIndexPath.section)
        }
        else if (currentIndexPath.section - 1 >= 0)
        {
            let previousItem = self.numberOfItems(inSection: currentIndexPath.section - 1)
            previousIndexPath = IndexPath(item: previousItem, section: currentIndexPath.section - 1)
        }
        
        return previousIndexPath
    }
    
    private func getNextIndexPath(from currentIndexPath: IndexPath) -> IndexPath?
    {
        var nextIndexPath : IndexPath? = nil
        
        if (currentIndexPath.item + 1 <= self.numberOfItems(inSection: currentIndexPath.section))
        {
            nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: currentIndexPath.section)
        }
        else if (currentIndexPath.section + 1 < self._metaGroups.count)
        {
            nextIndexPath = IndexPath(item: -1, section: currentIndexPath.section + 1)
        }
        
        return nextIndexPath
    }
    
    private var shouldLoadBottomViews : Bool
    {
        get
        {
            var shouldLoadBottomViews = self._visibleIndexPaths.count > 0
            
            if (shouldLoadBottomViews)
            {
                let lastVisibleIndexPath = self._visibleIndexPaths.last!
                let lastVisibleMeta = self.getMeta(item: lastVisibleIndexPath.item, section: lastVisibleIndexPath.section)
                
                if (lastVisibleMeta._view != nil)
                {
                    let frame = CGRect(x: lastVisibleMeta._globalOffset.x,
                                       y: lastVisibleMeta._globalOffset.y,
                                       width: lastVisibleMeta.width,
                                       height: lastVisibleMeta.height)
                    shouldLoadBottomViews = self.frame.height - (frame.maxY - self.contentOffset.y) > 1
                }
            }
            
            return shouldLoadBottomViews
        }
    }
    
    private func loadBottomViews()
    {
        while (self.shouldLoadBottomViews)
        {
            let nextIndexPath = self.getNextIndexPath(from: self._visibleIndexPaths.last!)
            
            if (nextIndexPath != nil)
            {
                self.displayView(at: nextIndexPath!)
                self._visibleIndexPaths.append(nextIndexPath!)
                self.displayNextCellViewsIfNeeded(from: nextIndexPath!)
            }
            else
            {
                break
            }
        }
    }
    
    private var shouldLoadTopViews : Bool
    {
        get
        {
            var shouldLoadTopViews = self._visibleIndexPaths.count > 0
            
            if (shouldLoadTopViews)
            {
                let firstVisibleIndexPath = self._visibleIndexPaths.first!
                let firstVisibleMeta = self.getMeta(item: firstVisibleIndexPath.item, section: firstVisibleIndexPath.section)
  
                if (firstVisibleMeta._view != nil)
                {
                    let frame = CGRect(x: firstVisibleMeta._globalOffset.x,
                                       y: firstVisibleMeta._globalOffset.y,
                                       width: firstVisibleMeta.width,
                                       height: firstVisibleMeta.height)
                    shouldLoadTopViews = frame.minY - self.contentOffset.y > 1
                }
            }
            
            return shouldLoadTopViews
        }
    }
    
    private func loadTopViews()
    {
        while (self.shouldLoadTopViews)
        {
            let previousIndexPath = self.getPreviousIndexPath(from: self._visibleIndexPaths.first!)
            
            if (previousIndexPath != nil)
            {
                self.displayView(at: previousIndexPath!)
                self._visibleIndexPaths.insert(previousIndexPath!, at: 0)
                self.displayPreviousCellViewsIfNeeded(from: previousIndexPath!)
            }
            else
            {
                break
            }
        }
    }
    
    private var shouldUnloadBottomViews : Bool
    {
        get
        {
            var shouldUnloadBottomViews = self._visibleIndexPaths.count > 0 && !self._isSlidingAllowed
            
            if (shouldUnloadBottomViews)
            {
                let firstVisibleIndexPath = self._visibleIndexPaths.first!
                let firstVisibleMeta = self.getMeta(item: firstVisibleIndexPath.item, section: firstVisibleIndexPath.section)
                shouldUnloadBottomViews = self.contentOffset.y + firstVisibleMeta._globalOffset.y > -1
            }
            
            if (shouldUnloadBottomViews)
            {
                let lastVisibleIndexPath = self._visibleIndexPaths.last!
                let lastVisibleMeta = self.getMeta(item: lastVisibleIndexPath.item, section: lastVisibleIndexPath.section)
                
                if (lastVisibleMeta._view != nil)
                {
                    let frame = CGRect(x: lastVisibleMeta._globalOffset.x,
                                       y: lastVisibleMeta._globalOffset.y,
                                       width: lastVisibleMeta.width,
                                       height: lastVisibleMeta.height)
                    shouldUnloadBottomViews = (frame.minY - self.contentOffset.y) - self.frame.height > -1
                }
            }
            
            return shouldUnloadBottomViews
        }
    }
    
    private func unloadBottomViews()
    {
        while (self.shouldUnloadBottomViews)
        {
            if (self._visibleIndexPaths.count > 1)
            {
                self.endDisplayView(at: self._visibleIndexPaths.last!)
                self._visibleIndexPaths.removeLast()
            }
            else
            {
                break
            }
        }
    }
    
    private var shouldUnloadTopViews : Bool
    {
        get
        {
            var shouldUnloadTopViews = self._visibleIndexPaths.count > 0 && !self._isSlidingAllowed
            
            if (shouldUnloadTopViews)
            {
                let lastVisibleIndexPath = self._visibleIndexPaths.last!
                let lastVisibleMeta = self.getMeta(item: lastVisibleIndexPath.item, section: lastVisibleIndexPath.section)
                shouldUnloadTopViews = (lastVisibleMeta._globalOffset.y + lastVisibleMeta.height) - (self.contentOffset.y + self.frame.height) > -1
            }
            
            if (shouldUnloadTopViews)
            {
                let firstVisibleIndexPath = self._visibleIndexPaths.first!
                let firstVisibleMeta = self.getMeta(item: firstVisibleIndexPath.item, section: firstVisibleIndexPath.section)
                
                if (firstVisibleMeta._view != nil)
                {
                    let frame = CGRect(x: firstVisibleMeta._globalOffset.x,
                                       y: firstVisibleMeta._globalOffset.y,
                                       width: firstVisibleMeta.width,
                                       height: firstVisibleMeta.height)
                    shouldUnloadTopViews = self.contentOffset.y - frame.maxY > -1
                }
            }
            
            return shouldUnloadTopViews
        }
    }
    
    private func unloadTopViews()
    {
        while (self.shouldUnloadTopViews)
        {
            if (self._visibleIndexPaths.count > 1)
            {
                self.endDisplayView(at: self._visibleIndexPaths.first!)
                self._visibleIndexPaths.removeFirst()
            }
            else
            {
                break
            }
        }
    }
    
    private func loadPartialViews()
    {
        if (self._visibleIndexPaths.count > 0)
        {
            if (self.contentOffset.y < self._previousOffset.y)
            {
                if (self._previousOffset.y - self.contentOffset.y < self.frame.height)
                {
                    self.unloadBottomViews()
                    self.loadTopViews()
                }
                else
                {
                    self.loadTopViews()
                    self.setNeedsLayout()
                }
            }
            else if (self.contentOffset.y > self._previousOffset.y)
            {
                if (self.contentOffset.y - self._previousOffset.y < self.frame.height)
                {
                    self.unloadTopViews()
                    self.loadBottomViews()
                }
                else
                {
                    self.loadBottomViews()
                    self.setNeedsLayout()
                }
            }
            else
            {
                self.unloadBottomViews()
                self.loadTopViews()
                self.unloadTopViews()
                self.loadBottomViews()
            }
            
            self._previousOffset = self.contentOffset
        }
    }
    
    func reloadData()
    {
        self.unloadViews()
        self._shouldLoadPartialViews = false
        self._metaGroups = [UIListViewMetaGroup]()
        self._numberOfItemsBySection = [Int:Int]()
        self._focusSectionHeaderIndexPath = nil
        self._focusSectionFooterIndexPath = nil
        self.loadMetaGroups()
        
        if (self._metaGroups.count > 0)
        {
            self.setNeedsLayout()
        }
    }
    
    private func displayViewsFromVisibleIndexPathsIfNeeded(to indexPath: IndexPath)
    {
        let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
        
        if (meta._view == nil)
        {
            var startSection = indexPath.section
            var endSection = indexPath.section
            var initialItem : Int! = nil
            var finalItem : Int! = nil
            var shouldAssertSizes = true
            
            if (indexPath.section < self.indexPathsForVisibleItems!.first!.section)
            {
                endSection = self.indexPathsForVisibleItems!.first!.section
                initialItem = indexPath.item
                finalItem = self.indexPathsForVisibleItems!.first!.item - 1
            }
            else if (indexPath.section > self.indexPathsForVisibleItems!.last!.section)
            {
                startSection = self.indexPathsForVisibleItems!.last!.section
                initialItem = self.indexPathsForVisibleItems!.last!.item + 1
                finalItem = indexPath.item
            }
            else
            {
                if (indexPath.item < self.indexPathsForVisibleItems!.first!.item)
                {
                    initialItem = indexPath.item
                    finalItem = self.indexPathsForVisibleItems!.first!.item - 1
                }
                else if (indexPath.item > self.indexPathsForVisibleItems!.last!.item)
                {
                    initialItem = self.indexPathsForVisibleItems!.last!.item + 1
                    finalItem = indexPath.item
                }
                else
                {
                    shouldAssertSizes = false
                }
            }
            
            if (shouldAssertSizes)
            {
                for section in startSection...endSection
                {
                    var startItem = -1
                    var endItem = self.numberOfItems(inSection: section)
                    
                    if (section == startSection)
                    {
                        startItem = initialItem
                    }
                    
                    if (section == endSection)
                    {
                        endItem = finalItem
                    }
                    
                    for item in startItem...endItem
                    {
                        let indexPath = IndexPath(item: item, section: section)
                        self.displayView(at: indexPath)
                    }
                }
            }
        }
    }
    
    private func animate(_ scrollingAnimation: UIListViewScrollingAnimation)
    {
        self.displayViewsFromVisibleIndexPathsIfNeeded(to: scrollingAnimation.indexPath)
        let meta = self.getMeta(item: scrollingAnimation.indexPath.item, section: scrollingAnimation.indexPath.section)
        
        var contentOffsetY = CGFloat(0)
        
        if (scrollingAnimation.scrollPosition == UIListViewScrollPosition.none)
        {
            if (meta._globalOffset.y < self.contentOffset.y)
            {
                self.scrollToItem(at: scrollingAnimation.indexPath,
                                 at: UIListViewScrollPosition.top,
                                 animated: scrollingAnimation.allowsAnimation)
            }
            else if (meta._globalOffset.y + meta.height > self.contentOffset.y + self.frame.height)
            {
                self.scrollToItem(at: scrollingAnimation.indexPath,
                                 at: UIListViewScrollPosition.bottom,
                                 animated: scrollingAnimation.allowsAnimation)
            }
            
            return
        }
        else if (scrollingAnimation.scrollPosition == UIListViewScrollPosition.top)
        {
            contentOffsetY = meta._globalOffset.y
            
            if (self.style == UIListViewStyle.plain)
            {
                let headerMeta = self.getMeta(item: -1, section: meta.section)
                contentOffsetY -= headerMeta.height
            }
        }
        else if (scrollingAnimation.scrollPosition == UIListViewScrollPosition.middle)
        {
            contentOffsetY = meta._globalOffset.y - (self.frame.height / 2)
        }
        else if (scrollingAnimation.scrollPosition == UIListViewScrollPosition.bottom)
        {
            contentOffsetY = meta._globalOffset.y - (self.frame.height - meta.height)
            
            if (self.style == UIListViewStyle.plain)
            {
                let footerMeta = self.getMeta(item: self.numberOfItems(inSection: meta.section), section: meta.section)
                contentOffsetY += footerMeta.height
            }
        }
        
        if (self.isSlidingEnabled)
        {
            self._initialOffset.y = contentOffsetY
            self._slidingIndexPath = scrollingAnimation.indexPath
        }
                
        if (self._isSlidingAllowed)
        {
            self._delegate?.listView?(self, willSlideToItemAt: scrollingAnimation.indexPath)
            UIView.animate(withDuration: self.slidingSpeed, animations:
            {
                self.contentOffset = CGPoint(x: 0, y: contentOffsetY)
            }, completion:
            { (isCompleted) in
                
                self._isSlidingAllowed = false
                self.scrollViewDidEndScrollingAnimation(self)
                self._delegate?.listView?(self, didSlideToItemAt: scrollingAnimation.indexPath)
            })
        }
        else
        {
            self.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: scrollingAnimation.allowsAnimation)
            
            if (!scrollingAnimation.allowsAnimation)
            {
                self.loadViews()
            }
        }
    }
    
    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UIListViewScrollPosition, animated: Bool)
    {
        let scrollingAnimation = UIListViewScrollingAnimation(indexPath: indexPath, at: scrollPosition, allowsAnimation: animated)
        self._scrollingAnimations.append(scrollingAnimation)
        self.setNeedsLayout()
    }
    
    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UIListViewScrollPosition)
    {
        if (self.allowsSelection && indexPath != nil)
        {
            if (!self.allowsMultipleSelection)
            {
                for selectedIndexPath in self._selectedIndexPaths
                {
                    let meta = self.getMeta(item: selectedIndexPath.item, section: selectedIndexPath.section)
                    
                    if (meta._view != nil)
                    {
                        let cell = meta._view as! UIListViewCell
                        cell.isSelected = false
                    }
                }
                
                self._selectedIndexPaths = [IndexPath]()
            }
            
            let meta = self.getMeta(item: indexPath!.item, section: indexPath!.section)
            
            if (meta._view != nil)
            {
                let cell = meta._view as! UIListViewCell
                cell.isSelected = true
            }
            
            self._selectedIndexPaths.append(indexPath!)
        }
    }
    
    func deselectItem(at indexPath: IndexPath, animated: Bool)
    {
        if (self.allowsSelection)
        {
            for (counter, selectedIndexPath) in self._selectedIndexPaths.enumerated().reversed()
            {
                if (selectedIndexPath == indexPath)
                {
                    let meta = self.getMeta(item: selectedIndexPath.item, section: selectedIndexPath.section)
                    
                    if (meta._view != nil)
                    {
                        let cell = meta._view as! UIListViewCell
                        cell.isSelected = false
                    }
                    
                    self._selectedIndexPaths.remove(at: counter)
                    break
                }
            }
        }
    }
    
    @objc private func toggleCell(_ sender: UITapGestureRecognizer!)
    {
        if (self.allowsSelection)
        {
            if (sender.state == UIGestureRecognizerState.ended)
            {
                var toggledIndexpath : IndexPath? = nil
                var isToggledCellSelected = false
                
                for visibleIndexPath in self._visibleIndexPaths
                {
                    let meta = self.getMeta(item: visibleIndexPath.item, section: visibleIndexPath.section)
                    
                    if (meta.type == UIMetaType.cell)
                    {
                        let cell = meta._view as! UIListViewCell
                        
                        if ((sender.location(in: cell).y >= 0 && sender.location(in: cell).y < cell.frame.height) && (sender.location(in: cell).x >= 0 && sender.location(in: cell).x < cell.frame.width))
                        {
                            isToggledCellSelected = cell.isSelected
                            toggledIndexpath = visibleIndexPath
                            break
                        }
                    }
                }
                
                if (toggledIndexpath != nil)
                {
                    if (self.allowsMultipleSelection)
                    {
                        if (isToggledCellSelected)
                        {
                            self.deselectCell(at: toggledIndexpath!)
                        }
                        else
                        {
                            self.selectCell(at: toggledIndexpath!)
                        }
                    }
                    else
                    {
                        for selectedIndexPath in self._selectedIndexPaths
                        {
                            self.deselectCell(at: selectedIndexPath)
                        }
                        
                        self.selectCell(at: toggledIndexpath!)
                    }
                }
            }
        }
    }
    
    private func selectCell(at indexPath: IndexPath)
    {
        let selectedIndexPath = self._delegate?.listView?(self, willSelectItemAt: indexPath)
        
        if (selectedIndexPath != nil)
        {
            let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
            
            if (meta._view != nil)
            {
                let cell = meta._view as! UIListViewCell
                cell.isSelected = true
            }
            
            self._selectedIndexPaths.append(indexPath)
            self._delegate?.listView?(self, didSelectItemAt: selectedIndexPath!)
        }
    }
    
    private func deselectCell(at indexPath: IndexPath)
    {
        let deselectedIndexPath = self._delegate?.listView?(self, willDeselectItemAt: indexPath)
        
        if (deselectedIndexPath != nil)
        {
            for (counter, selectedIndexPath) in self._selectedIndexPaths.enumerated().reversed()
            {
                if (selectedIndexPath == indexPath)
                {
                    let meta = self.getMeta(item: selectedIndexPath.item, section: selectedIndexPath.section)
                    
                    if (meta._view != nil)
                    {
                        let cell = meta._view as! UIListViewCell
                        cell.isSelected = false
                    }
                    
                    self._selectedIndexPaths.remove(at: counter)
                    break
                }
            }
            
            self._delegate?.listView?(self, didDeselectItemAt: deselectedIndexPath!)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if (gestureRecognizer === self._tapGestureRecognizer)
        {
            if (touch.view is UIControl)
            {
                return false
            }
        }
        
        return true
    }
    
    func listViewMetaGroup(_ listViewMetaGroup: UIListViewMetaGroup, didChangeHeightFrom oldHeight: CGFloat, to newHeight: CGFloat)
    {
        self._contentHeight = self._contentHeight - oldHeight + newHeight
    }
}
