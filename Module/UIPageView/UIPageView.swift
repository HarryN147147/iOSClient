//
//  UIPageView.swift
//  jasmine
//
//  Created by Minh Nguyen on 11/24/15.
//  Copyright © 2015 Minh Nguyen. All rights reserved.
//

import UIKit

enum UIPageViewScrollPosition : Int
{
    case none
    case left
    case middle
    case right
}

enum UIPageViewStyle : Int
{
    case plain = 0
    case grouped = 1
}

let UIPageViewAutomaticDimension = UITableViewAutomaticDimension

class UIPageView : UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIPageViewMetaGroupDelegate
{
    private weak var _dataSource : UIPageViewDataSource?
    private weak var _delegate : UIPageViewDelegate?
    
    var itemSize : CGSize
    var estimatedItemSize : CGSize
    var sectionHeaderWidth: CGFloat
    var estimatedSectionHeaderWidth: CGFloat
    var sectionFooterWidth: CGFloat
    var estimatedSectionFooterWidth: CGFloat
    var isSlidingEnabled : Bool
    var slidingPosition : UIPageViewScrollPosition
    var anchorPosition : UIPageViewScrollPosition
    var slidingSpeed : Double
    var slidingDistance : CGFloat
    var allowsSelection : Bool
    var allowsMultipleSelection : Bool
    
    private var _shouldLoadPartialViews : Bool
    private var _contentWidth : CGFloat
    private var _numberOfItemsBySection : [Int:Int]
    private var _style : UIPageViewStyle
    private var _pageHeaderView : UIView?
    private var _pageFooterView : UIView?
    private var _isSlidingAllowed : Bool
    private var _initialOffset : CGPoint
    private var _decelerationOffset : CGPoint?
    private var _previousOffset : CGPoint
    private var _visibleIndexPaths : [IndexPath]
    private var _selectedIndexPaths : [IndexPath]
    private var _focusSectionHeaderIndexPath : IndexPath?
    private var _focusSectionFooterIndexPath : IndexPath?
    private var _slidingIndexPath : IndexPath?
    private var _metaGroups : [UIPageViewMetaGroup]
    private var _modifiedMetaGroup : UIPageViewMetaGroup?
    private var _scrollingAnimations : [UIPageViewScrollingAnimation]
    private var _tapGestureRecognizer : UITapGestureRecognizer
    
    override init(frame: CGRect)
    {
        self.itemSize = CGSize(width: UIPageViewAutomaticDimension, height: UIPageViewAutomaticDimension)
        self.estimatedItemSize = CGSize(width: UIPageViewAutomaticDimension, height: UIPageViewAutomaticDimension)
        self.sectionHeaderWidth = UIPageViewAutomaticDimension
        self.estimatedSectionHeaderWidth = UIPageViewAutomaticDimension
        self.sectionFooterWidth = UIPageViewAutomaticDimension
        self.estimatedSectionFooterWidth = UIPageViewAutomaticDimension
        
        self.isSlidingEnabled = false
        self.slidingPosition = UIPageViewScrollPosition.left
        self.anchorPosition = UIPageViewScrollPosition.none
        self.slidingSpeed = 0.35
        self.slidingDistance = 0
        self.allowsSelection = true
        self.allowsMultipleSelection = false
        
        self._shouldLoadPartialViews = false
        self._contentWidth = 0
        self._numberOfItemsBySection = [Int:Int]()
        self._style = UIPageViewStyle.plain
        self._isSlidingAllowed = false
        self._initialOffset = CGPoint.zero
        self._previousOffset = CGPoint.zero
        self._visibleIndexPaths = [IndexPath]()
        self._selectedIndexPaths = [IndexPath]()
        self._metaGroups = [UIPageViewMetaGroup]()
        self._scrollingAnimations = [UIPageViewScrollingAnimation]()
        self._tapGestureRecognizer = UITapGestureRecognizer()
        
        super.init(frame: frame)
        
        self.alwaysBounceHorizontal = true
        self.alwaysBounceVertical = false
        self.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 241/255, alpha: 1)
        
        self._tapGestureRecognizer.addTarget(self, action: #selector(UIPageView.toggleCell(_:)))
        self._tapGestureRecognizer.cancelsTouchesInView = false
        self._tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(self._tapGestureRecognizer)
    }
    
    convenience init(frame: CGRect, style: UIPageViewStyle)
    {
        self.init(frame: CGRect.zero)
        
        self._style = style
    }
    
    convenience init(style: UIPageViewStyle)
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
                self._delegate = newValue as? UIPageViewDelegate
                super.delegate = self
            }
        }
    }
    
    var dataSource : UIPageViewDataSource?
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
    
    var style : UIPageViewStyle
    {
        get
        {
            let style = self._style
            
            return style
        }
    }
    
    var pageHeaderView : UIView?
    {
        get
        {
            let pageHeaderView = self._pageHeaderView
            
            return pageHeaderView
        }
        
        set(newValue)
        {
            if (self._pageHeaderView != nil)
            {
                self._pageHeaderView!.removeFromSuperview()
                self._contentWidth -= self._pageHeaderView!.frame.width
            }
            
            self._pageHeaderView = newValue
            self._contentWidth += self._pageHeaderView!.frame.width
        }
    }
    
    var pageFooterView : UIView?
    {
        get
        {
            let pageFooterView = self._pageFooterView
            
            return pageFooterView
        }
        
        set(newValue)
        {
            if (self._pageFooterView != nil)
            {
                self._pageFooterView!.removeFromSuperview()
                self._contentWidth -= self._pageFooterView!.frame.width
            }
            
            self._pageFooterView = newValue
            self._contentWidth += self._pageFooterView!.frame.width
        }
    }
    
    var visibleCells : [UIPageViewCell]
    {
        get
        {
            var visibleCells = [UIPageViewCell]()
            
            for visibleIndexPath in self._visibleIndexPaths
            {
                let meta = self.getMeta(item: visibleIndexPath.item, section: visibleIndexPath.section)
                
                if (meta.type == UIMetaType.cell)
                {
                    visibleCells.append(meta._view as! UIPageViewCell)
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
            
            if (self._decelerationOffset!.x <= self._initialOffset.x)
            {
                self._isSlidingAllowed = true
                let slidingDistance = self.getSlidingDistanceForCellAt(indexPath: currentIndexPath)
                
                if (self._initialOffset.x - self._decelerationOffset!.x >= slidingDistance)
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
                
                if (self._decelerationOffset!.x - self._initialOffset.x >= slidingDistance)
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
        
        if (self.contentOffset.x + self.frame.width > self.contentSize.width)
        {
            self.contentOffset.x = self.contentSize.width - self.frame.width
        }
        else if (self.contentOffset.x < 0)
        {
            self.contentOffset.x = 0
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
            
            self._scrollingAnimations = [UIPageViewScrollingAnimation]()
        }
    }
    
    private func loadHeaderViewIfNeeded()
    {
        if (self._pageHeaderView != nil)
        {
            self._pageHeaderView!.frame.origin.x = 0
            
            if (self._pageHeaderView!.superview == nil)
            {
                self.addSubview(self._pageHeaderView!)
            }
            
            for visibleIndexPath in self._visibleIndexPaths
            {
                let meta = self.getMeta(item: visibleIndexPath.item, section: visibleIndexPath.section)
                
                if (meta._view != nil)
                {
                    meta._view!.frame.origin.x = meta._globalOffset.x
                }
            }
        }
    }
    
    private func loadFooterViewIfNeeded()
    {
        if (self._pageFooterView != nil)
        {
            if (self._pageFooterView!.superview == nil)
            {
                self.addSubview(self._pageFooterView!)
            }
            
            self._pageFooterView!.frame.origin.x = self.contentSize.width - self._pageFooterView!.frame.width
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
                    headerMeta._view!.frame.origin.x = headerMeta._globalOffset.x
                }
                
                self._focusSectionHeaderIndexPath = nil
            }
            
            let focusSection = self._visibleIndexPaths.first!.section
            let headerMeta = self.getMeta(item: -1, section: focusSection)
            let footerMeta = self.getMeta(item: self.numberOfItems(inSection: focusSection), section: focusSection)
            
            var headerOriginX = self.contentOffset.x
            
            var minimumOffsetX = headerMeta._globalOffset.x
            
            if (self._pageHeaderView != nil)
            {
                minimumOffsetX += self._pageHeaderView!.frame.height
            }
            
            if (headerOriginX < minimumOffsetX)
            {
                headerOriginX = minimumOffsetX
            }
            
            if (headerMeta.width + headerOriginX > footerMeta._globalOffset.x)
            {
                headerOriginX = footerMeta._globalOffset.x - headerMeta.width
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
            
            headerMeta._view!.frame.origin.x = headerOriginX
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
                    footerMeta._view!.frame.origin.x = footerMeta._globalOffset.x
                }
                
                self._focusSectionFooterIndexPath = nil
            }
            
            let focusSection = self._visibleIndexPaths.last!.section
            let headerMeta = self.getMeta(item: -1, section: focusSection)
            let footerMeta = self.getMeta(item: self.numberOfItems(inSection: focusSection), section: focusSection)
            
            var footerOriginX = self.contentOffset.x + self.frame.width - footerMeta.width
            
            if (footerOriginX > footerMeta._globalOffset.x)
            {
                footerOriginX = footerMeta._globalOffset.x
            }
            
            if (footerOriginX < headerMeta._globalOffset.x + headerMeta.width)
            {
                footerOriginX = headerMeta._globalOffset.x + headerMeta.width
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
            
            footerMeta._view!.frame.origin.x = footerOriginX
            self._focusSectionFooterIndexPath = indexPath
        }
    }
    
    override func layoutSubviews()
    {
        if ((self.contentSize.height - self.frame.height) > 1 && self._shouldLoadPartialViews)
        {
            self.reloadData()
        }
        
        self.loadViews()
        self.animateViewsIfNeeded()
    }
    
    private func anchorViewsIfNeeded()
    {
        if (self.anchorPosition != UIPageViewScrollPosition.none)
        {
            if (self.contentSize.width < self.frame.width)
            {
                self.isScrollEnabled = false
                
                if (self.anchorPosition == UIPageViewScrollPosition.right)
                {
                    self.contentOffset.x = self.contentSize.width - self.frame.width
                }
                else if (self.anchorPosition == UIPageViewScrollPosition.middle)
                {
                    self.contentOffset.x = (self.contentSize.width - self.frame.width) / 2
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
        var slidingDistance = self._delegate?.pageView?(self, slidingDistanceForItemAt: indexPath)
        
        if (slidingDistance == nil)
        {
            slidingDistance = self.slidingDistance
        }
        
        return slidingDistance!
    }
    
    private func getEstimatedSectionHeaderWidthAt(section: Int) -> CGFloat
    {
        var estimatedSectionHeaderWidth = self._delegate?.pageView?(self, estimatedWidthForHeaderInSection: section)
        
        if (estimatedSectionHeaderWidth == nil)
        {
            estimatedSectionHeaderWidth = self.estimatedSectionHeaderWidth
        }
        
        if (estimatedSectionHeaderWidth == UIPageViewAutomaticDimension)
        {
            if (self.style == UIPageViewStyle.plain)
            {
                estimatedSectionHeaderWidth = 100
            }
            else if (self.style == UIPageViewStyle.grouped)
            {
                estimatedSectionHeaderWidth = 120
            }
        }
        
        return estimatedSectionHeaderWidth!
    }
    
    private func getEstimatedItemSizeAt(indexPath: IndexPath) -> CGSize
    {
        var estimatedItemSize : CGSize! = self._delegate?.pageView?(self, estimatedSizeForItemAt: indexPath)
        
        if (estimatedItemSize == nil)
        {
            estimatedItemSize = self.estimatedItemSize
        }
        
        if (estimatedItemSize.width == UIPageViewAutomaticDimension)
        {
            estimatedItemSize.width = 100
        }
        
        if (estimatedItemSize.height == UIListViewAutomaticDimension)
        {
            estimatedItemSize.height = self.frame.height
        }
        
        return estimatedItemSize
    }
    
    private func getEstimatedSectionFooterWidthAt(section: Int) -> CGFloat
    {
        var estimatedSectionFooterWidth = self._delegate?.pageView?(self, estimatedWidthForFooterInSection: section)
        
        if (estimatedSectionFooterWidth == nil)
        {
            estimatedSectionFooterWidth = self.estimatedSectionFooterWidth
        }
        
        if (estimatedSectionFooterWidth == UIPageViewAutomaticDimension)
        {
            if (self.style == UIPageViewStyle.plain)
            {
                estimatedSectionFooterWidth = 100
            }
            else if (self.style == UIPageViewStyle.grouped)
            {
                estimatedSectionFooterWidth = 100
            }
        }
        
        return estimatedSectionFooterWidth!
    }
    
    private func getSectionHeaderWidthAt(section: Int) -> CGFloat
    {
        var sectionHeaderWidth = self._delegate?.pageView?(self, widthForHeaderInSection: section)
        
        if (sectionHeaderWidth == nil)
        {
            sectionHeaderWidth = self.sectionHeaderWidth
        }
        
        if (sectionHeaderWidth == UIPageViewAutomaticDimension)
        {
            if (self.style == UIPageViewStyle.plain)
            {
                sectionHeaderWidth = 100
            }
            else if (self.style == UIPageViewStyle.grouped)
            {
                sectionHeaderWidth = 120
            }
        }
        
        return sectionHeaderWidth!
    }
    
    private func getItemSizeAt(indexPath: IndexPath) -> CGSize
    {
        var itemSize : CGSize! = self._delegate?.pageView?(self, sizeForItemAt: indexPath)
        
        if (itemSize == nil)
        {
            itemSize = self.itemSize
        }
        
        if (itemSize.width == UIPageViewAutomaticDimension)
        {
            itemSize.width = 100
        }
        
        if (itemSize.height == UIPageViewAutomaticDimension)
        {
            itemSize.height = self.frame.height
        }
        
        return itemSize
    }
    
    private func getSectionFooterWidthAt(section: Int) -> CGFloat
    {
        var sectionFooterWidth = self._delegate?.pageView?(self, widthForFooterInSection: section)
        
        if (sectionFooterWidth == nil)
        {
            sectionFooterWidth = self.sectionFooterWidth
        }
        
        if (sectionFooterWidth == UIPageViewAutomaticDimension)
        {
            if (self.style == UIPageViewStyle.plain)
            {
                sectionFooterWidth = 100
            }
            else if (self.style == UIPageViewStyle.grouped)
            {
                sectionFooterWidth = 100
            }
        }
        
        return sectionFooterWidth!
    }
    
    private func getContentView(text: String?, type: UIMetaType) -> UIPageViewHeaderFooterContentView
    {
        var title = text
        var font = UIFont.boldSystemFont(ofSize: 17)
        var textColor = UIColor(red: 115/255, green: 115/255, blue: 120/255, alpha: 1)
        
        if (self.style == UIPageViewStyle.plain)
        {
            textColor = UIColor.black
        }
        
        if (type == UIMetaType.header)
        {
            if (self.style == UIPageViewStyle.grouped)
            {
                title = text?.uppercased()
                font = UIFont.systemFont(ofSize: 16)
            }
        }
        else if (type == UIMetaType.footer)
        {
            if (self.style == UIPageViewStyle.grouped)
            {
                font = UIFont.systemFont(ofSize: 15)
            }
        }
        
        let contentView = UIPageViewHeaderFooterContentView()
        contentView.label.font = font
        contentView.label.textColor = textColor
        contentView.label.text = title
        
        if (self.style == UIPageViewStyle.plain)
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
                
                if (meta._view!.frame.origin.x + meta._view!.frame.width  < self.contentOffset.x || meta._view!.frame.origin.x > self.contentOffset.x + self.frame.width)
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
        
        if (meta._globalOffset.y + meta.height < self.frame.height)
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
                        
                        if (nextMeta._globalOffset.y + nextMeta.height == self.frame.height)
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
        
        if (meta._globalOffset.y > 0)
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
                        
                        if (previousMeta._globalOffset.y == 0)
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
                var headerView = self._delegate?.pageView?(self, viewForHeaderInSection: meta.section)
                
                if (headerView == nil)
                {
                    let title = self._dataSource!.pageView?(self, titleForHeaderInSection: meta.section)
                    
                    if (title != nil || self.style == UIPageViewStyle.plain)
                    {
                        headerView = self.getContentView(text: title, type: meta.type)
                    }
                }
                
                meta._view = headerView
                self.assertSize(at: indexPath)
                
                if (headerView != nil)
                {
                    self.setViewFrameIfNeeded(at: indexPath)
                    self._delegate?.pageView?(self, willDisplayHeaderView: headerView!, forSection: indexPath.section)
                    self.addSubview(headerView!)
                }
            }
            else if (meta.type == UIMetaType.footer)
            {
                var footerView = self._delegate?.pageView?(self, viewForFooterInSection: meta.section)
                
                if (footerView == nil)
                {
                    let title = self._dataSource!.pageView?(self, titleForFooterInSection: meta.section)
                    
                    if (title != nil || self.style == UIPageViewStyle.plain)
                    {
                        footerView = self.getContentView(text: title, type: meta.type)
                    }
                }
                
                meta._view = footerView
                self.assertSize(at: indexPath)
                
                if (footerView != nil)
                {
                    self.setViewFrameIfNeeded(at: indexPath)
                    self._delegate?.pageView?(self, willDisplayFooterView: footerView!, forSection: indexPath.section)
                    self.addSubview(footerView!)
                }
            }
            else
            {
                let cell = self.dataSource!.pageView(self, cellForItemAt: indexPath)
                meta._view = cell
                self.assertSize(at: indexPath)
                self.setViewFrameIfNeeded(at: indexPath)
                self._delegate?.pageView?(self, willDisplay: cell, forItemAt: indexPath)
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
                self._delegate?.pageView?(self, didEndDisplayingHeaderView: meta._view!, forSection: meta.section)
            }
            else if (meta.type == UIMetaType.footer)
            {
                self._delegate?.pageView?(self, didEndDisplayingFooterView: meta._view!, forSection: meta.section)
            }
            else
            {
                let cell = meta._view as! UIPageViewCell
                self._delegate?.pageView?(self, didEndDisplaying: cell, forItemAt: indexPath)
            }
            
            meta._view = nil
        }
    }
    
    private func getMeta(item: Int, section: Int) -> UIMeta
    {
        self.setInitialOffsetIfNeeded(at: section)
        let metaGroup = self._metaGroups[section]
        let meta = metaGroup.getMeta(at: item)
        
        if (self._pageHeaderView != nil)
        {
            meta._globalOffset.x += self._pageHeaderView!.frame.width
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
            initialOffset += metaGroup.width
        }
    }
    
    private func setInitialOffsetIfNeeded(at section: Int)
    {
        if (self._modifiedMetaGroup != nil)
        {
            if (section > self._modifiedMetaGroup!.section)
            {
                let initialOffset = self._modifiedMetaGroup!.initialOffset + self._modifiedMetaGroup!.width
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
        var size = CGSize(width: 0, height: self.frame.height)
        
        if (meta.type == UIMetaType.header)
        {
            size.width = self.getSectionHeaderWidthAt(section: indexPath.section)
        }
        else if (meta.type == UIMetaType.footer)
        {
            size.width = self.getSectionFooterWidthAt(section: indexPath.section)
        }
        else
        {
            size = self.getItemSizeAt(indexPath: indexPath)
        }
        
        if (meta.type == UIMetaType.header || meta.type == UIMetaType.footer)
        {
            if (meta._view != nil &&
                meta._view is UIPageViewHeaderFooterContentView &&
                self.numberOfSections == 1)
            {
                let view = meta._view as! UIPageViewHeaderFooterContentView
                
                if (view.label.text == nil || view.label.text == "")
                {
                    size.width = 0
                }
            }
        }
        
        if (meta.width != size.width || meta.height != size.height)
        {
            let metaGroup = self._metaGroups[indexPath.section]
            
            if (meta.width != size.width)
            {
                meta.width = size.width
            }
            
            if (meta.height != size.height)
            {
                meta.height = size.height
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
        
        self._contentWidth = 0
        
        for section in 0...numberOfSections! - 1
        {
            let metaGroup = UIPageViewMetaGroup(section: section,
                                                initialOffset: self._contentWidth,
                                                height: self.frame.height,
                                                delegate: self)
            self._metaGroups.append(metaGroup)
            
            let estimatedSectionHeaderWidth = self.getEstimatedSectionHeaderWidthAt(section: section)
            metaGroup.headerMeta.width = estimatedSectionHeaderWidth
            metaGroup.headerMeta.height = self.frame.height
            
            let estimatedSectionFooterWidth = self.getEstimatedSectionFooterWidthAt(section: section)
            metaGroup.footerMeta.width = estimatedSectionFooterWidth
            metaGroup.footerMeta.height = self.frame.height
            
            let numberOfItems = self.dataSource?.pageView(self, numberOfItemsInSection: section)
            
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
        
        if (self._pageHeaderView != nil)
        {
            self._contentWidth += self._pageHeaderView!.frame.width
        }
        
        if (self._pageFooterView != nil)
        {
            self._contentWidth += self._pageFooterView!.frame.width
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
        
        self.contentSize = CGSize(width: self._contentWidth, height: self.frame.height)
        self.loadFooterViewIfNeeded()
        
        if (self.style == UIPageViewStyle.plain)
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
                if (self.contentOffset.x < 0)
                {
                    self.contentOffset.x = 0
                }
                
                let lastContentOffset = self.contentOffset
                
                findMetaGroup:
                for metaGroup in self._metaGroups
                {
                    let initialMeta = self.getMeta(item: -1, section: metaGroup.section)
                    
                    if (initialMeta._globalOffset.x < lastContentOffset.x + self.frame.width)
                    {
                        let indexPath = IndexPath(item: initialMeta.item, section: initialMeta.section)
                        self.displayView(at: indexPath)
                        self._visibleIndexPaths.append(indexPath)
                    }
                    
                    self.loadRightViews()
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
    
    private var shouldLoadRightViews : Bool
    {
        get
        {
            var shouldLoadRightViews = self._visibleIndexPaths.count > 0
            
            if (shouldLoadRightViews)
            {
                let lastVisibleIndexPath = self._visibleIndexPaths.last!
                let lastVisibleMeta = self.getMeta(item: lastVisibleIndexPath.item, section: lastVisibleIndexPath.section)
                
                if (lastVisibleMeta._view != nil)
                {
                    let frame = CGRect(x: lastVisibleMeta._globalOffset.x,
                                       y: lastVisibleMeta._globalOffset.y,
                                       width: lastVisibleMeta.width,
                                       height: lastVisibleMeta.height)
                    shouldLoadRightViews = self.frame.width - (frame.maxX - self.contentOffset.x) > 1
                }
            }
            
            return shouldLoadRightViews
        }
    }
    
    private func loadRightViews()
    {
        while (self.shouldLoadRightViews)
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
    
    private var shouldLoadLeftViews : Bool
    {
        get
        {
            var shouldLoadLeftViews = self._visibleIndexPaths.count > 0
            
            if (shouldLoadLeftViews)
            {
                let firstVisibleIndexPath = self._visibleIndexPaths.first!
                let firstVisibleMeta = self.getMeta(item: firstVisibleIndexPath.item, section: firstVisibleIndexPath.section)
                
                if (firstVisibleMeta._view != nil)
                {
                    let frame = CGRect(x: firstVisibleMeta._globalOffset.x,
                                       y: firstVisibleMeta._globalOffset.y,
                                       width: firstVisibleMeta.width,
                                       height: firstVisibleMeta.height)
                    shouldLoadLeftViews = frame.minX - self.contentOffset.x > 1
                }
            }
            
            return shouldLoadLeftViews
        }
    }
    
    private func loadLeftViews()
    {
        while (self.shouldLoadLeftViews)
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
    
    private var shouldUnloadRightViews : Bool
    {
        get
        {
            var shouldUnloadRightViews = self._visibleIndexPaths.count > 0 && !self._isSlidingAllowed
            
            if (shouldUnloadRightViews)
            {
                let firstVisibleIndexPath = self._visibleIndexPaths.first!
                let firstVisibleMeta = self.getMeta(item: firstVisibleIndexPath.item, section: firstVisibleIndexPath.section)
                shouldUnloadRightViews = self.contentOffset.x + firstVisibleMeta._globalOffset.x > -1
            }
            
            if (shouldUnloadRightViews)
            {
                let lastVisibleIndexPath = self._visibleIndexPaths.last!
                let lastVisibleMeta = self.getMeta(item: lastVisibleIndexPath.item, section: lastVisibleIndexPath.section)
                
                if (lastVisibleMeta._view != nil)
                {
                    let frame = CGRect(x: lastVisibleMeta._globalOffset.x,
                                       y: lastVisibleMeta._globalOffset.y,
                                       width: lastVisibleMeta.width,
                                       height: lastVisibleMeta.height)
                    shouldUnloadRightViews = (frame.minX - self.contentOffset.x) - self.frame.width > -1
                }
            }
            
            return shouldUnloadRightViews
        }
    }
    
    private func unloadRightViews()
    {
        while (self.shouldUnloadRightViews)
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
    
    private var shouldUnloadLeftViews : Bool
    {
        get
        {
            var shouldUnloadLeftViews = self._visibleIndexPaths.count > 0 && !self._isSlidingAllowed
            
            if (shouldUnloadLeftViews)
            {
                let lastVisibleIndexPath = self._visibleIndexPaths.last!
                let lastVisibleMeta = self.getMeta(item: lastVisibleIndexPath.item, section: lastVisibleIndexPath.section)
                shouldUnloadLeftViews = (lastVisibleMeta._globalOffset.x + lastVisibleMeta.width) - (self.contentOffset.x + self.frame.width) > -1
            }
            
            if (shouldUnloadLeftViews)
            {
                let firstVisibleIndexPath = self._visibleIndexPaths.first!
                let firstVisibleMeta = self.getMeta(item: firstVisibleIndexPath.item, section: firstVisibleIndexPath.section)
                
                if (firstVisibleMeta._view != nil)
                {
                    let frame = CGRect(x: firstVisibleMeta._globalOffset.x,
                                       y: firstVisibleMeta._globalOffset.y,
                                       width: firstVisibleMeta.width,
                                       height: firstVisibleMeta.height)
                    shouldUnloadLeftViews = self.contentOffset.x - frame.maxX > -1
                }
            }
            
            return shouldUnloadLeftViews
        }
    }
    
    private func unloadLeftViews()
    {
        while (self.shouldUnloadLeftViews)
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
            if (self.contentOffset.x < self._previousOffset.x)
            {
                if (self._previousOffset.x - self.contentOffset.x < self.frame.width)
                {
                    self.unloadRightViews()
                    self.loadLeftViews()
                }
                else
                {
                    self.loadLeftViews()
                    self.setNeedsLayout()
                }
            }
            else if (self.contentOffset.x > self._previousOffset.x)
            {
                if (self.contentOffset.x - self._previousOffset.x < self.frame.width)
                {
                    self.unloadLeftViews()
                    self.loadRightViews()
                }
                else
                {
                    self.loadRightViews()
                    self.setNeedsLayout()
                }
            }
            else
            {
                self.unloadRightViews()
                self.loadLeftViews()
                self.unloadLeftViews()
                self.loadRightViews()
            }
            
            self._previousOffset = self.contentOffset
        }
    }
    
    func reloadData()
    {
        self.unloadViews()
        self._shouldLoadPartialViews = false
        self._metaGroups = [UIPageViewMetaGroup]()
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
    
    private func animate(_ scrollingAnimation: UIPageViewScrollingAnimation)
    {
        self.displayViewsFromVisibleIndexPathsIfNeeded(to: scrollingAnimation.indexPath)
        let meta = self.getMeta(item: scrollingAnimation.indexPath.item, section: scrollingAnimation.indexPath.section)
        
        var contentOffsetX = CGFloat(0)
        
        if (scrollingAnimation.scrollPosition == UIPageViewScrollPosition.none)
        {
            if (meta._globalOffset.x < self.contentOffset.x)
            {
                self.scrollToItem(at: scrollingAnimation.indexPath,
                                    at: UIPageViewScrollPosition.left,
                                    animated: scrollingAnimation.allowsAnimation)
            }
            else if (meta._globalOffset.x + meta.width > self.contentOffset.x + self.frame.width)
            {
                self.scrollToItem(at: scrollingAnimation.indexPath,
                                    at: UIPageViewScrollPosition.right,
                                    animated: scrollingAnimation.allowsAnimation)
            }
            
            return
        }
        else if (scrollingAnimation.scrollPosition == UIPageViewScrollPosition.left)
        {
            contentOffsetX = meta._globalOffset.x
            
            if (self.style == UIPageViewStyle.plain)
            {
                let headerMeta = self.getMeta(item: -1, section: meta.section)
                contentOffsetX -= headerMeta.width
            }
        }
        else if (scrollingAnimation.scrollPosition == UIPageViewScrollPosition.middle)
        {
            contentOffsetX = meta._globalOffset.x - (self.frame.width / 2)
        }
        else if (scrollingAnimation.scrollPosition == UIPageViewScrollPosition.right)
        {
            contentOffsetX = meta._globalOffset.x - (self.frame.width - meta.width)
            
            if (self.style == UIPageViewStyle.plain)
            {
                let footerMeta = self.getMeta(item: self.numberOfItems(inSection: meta.section), section: meta.section)
                contentOffsetX += footerMeta.width
            }
        }
        
        if (self.isSlidingEnabled)
        {
            self._initialOffset.x = contentOffsetX
            self._slidingIndexPath = scrollingAnimation.indexPath
        }
        
        if (self._isSlidingAllowed)
        {
            self._delegate?.pageView?(self, willSlideToItemAt: scrollingAnimation.indexPath)
            UIView.animate(withDuration: self.slidingSpeed, animations:
            {
                self.contentOffset = CGPoint(x: contentOffsetX, y: 0)
            }, completion:
            { (isCompleted) in
                
                self._isSlidingAllowed = false
                self.scrollViewDidEndScrollingAnimation(self)
                self._delegate?.pageView?(self, didSlideToItemAt: scrollingAnimation.indexPath)
            })
        }
        else
        {
            self.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: scrollingAnimation.allowsAnimation)
            
            if (!scrollingAnimation.allowsAnimation)
            {
                self.loadViews()
            }
        }
    }
    
    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UIPageViewScrollPosition, animated: Bool)
    {
        let scrollingAnimation = UIPageViewScrollingAnimation(indexPath: indexPath, at: scrollPosition, allowsAnimation: animated)
        self._scrollingAnimations.append(scrollingAnimation)
        self.setNeedsLayout()
    }
    
    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UIPageViewScrollPosition)
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
                        let cell = meta._view as! UIPageViewCell
                        cell.isSelected = false
                    }
                }
                
                self._selectedIndexPaths = [IndexPath]()
            }
            
            let meta = self.getMeta(item: indexPath!.item, section: indexPath!.section)
            
            if (meta._view != nil)
            {
                let cell = meta._view as! UIPageViewCell
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
                        let cell = meta._view as! UIPageViewCell
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
                        let cell = meta._view as! UIPageViewCell
                        
                        if ((sender.location(in: cell).x >= 0 && sender.location(in: cell).x < cell.frame.width) &&
                            (sender.location(in: cell).y >= 0 && sender.location(in: cell).y < cell.frame.height))
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
        let selectedIndexPath = self._delegate?.pageView?(self, willSelectItemAt: indexPath)
        
        if (selectedIndexPath != nil)
        {
            let meta = self.getMeta(item: indexPath.item, section: indexPath.section)
            
            if (meta._view != nil)
            {
                let cell = meta._view as! UIPageViewCell
                cell.isSelected = true
            }
            
            self._selectedIndexPaths.append(indexPath)
            self._delegate?.pageView?(self, didSelectItemAt: selectedIndexPath!)
        }
    }
    
    private func deselectCell(at indexPath: IndexPath)
    {
        let deselectedIndexPath = self._delegate?.pageView?(self, willDeselectItemAt: indexPath)
        
        if (deselectedIndexPath != nil)
        {
            for (counter, selectedIndexPath) in self._selectedIndexPaths.enumerated().reversed()
            {
                if (selectedIndexPath == indexPath)
                {
                    let meta = self.getMeta(item: selectedIndexPath.item, section: selectedIndexPath.section)
                    
                    if (meta._view != nil)
                    {
                        let cell = meta._view as! UIPageViewCell
                        cell.isSelected = false
                    }
                    
                    self._selectedIndexPaths.remove(at: counter)
                    break
                }
            }
            
            self._delegate?.pageView?(self, didDeselectItemAt: deselectedIndexPath!)
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
    
    func pageViewMetaGroup(_ pageViewMetaGroup: UIPageViewMetaGroup, didChangeWidthFrom oldWidth: CGFloat, to newWidth: CGFloat)
    {
        self._contentWidth = self._contentWidth - oldWidth + newWidth
    }
}
