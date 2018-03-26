//
//  UIListViewDelegate.swift
//  jasmine
//
//  Created by Minh Nguyen on 2/28/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import UIKit

@objc
protocol UIListViewDelegate : UIScrollViewDelegate
{
    @objc optional func listView(_ listView: UIListView, willSelectItemAt indexPath: IndexPath) -> IndexPath?
    @objc optional func listView(_ listView: UIListView, didSelectItemAt indexPath: IndexPath)
    @objc optional func listView(_ listView: UIListView, willDeselectItemAt indexPath: IndexPath) -> IndexPath?
    @objc optional func listView(_ listView: UIListView, didDeselectItemAt indexPath: IndexPath)
    @objc optional func listView(_ listView: UIListView, willDisplay cell: UIListViewCell, forItemAt indexPath: IndexPath)
    @objc optional func listView(_ listView: UIListView, didEndDisplaying cell: UIListViewCell, forItemAt indexPath: IndexPath)
    @objc optional func listView(_ listView: UIListView, sizeForItemAt indexPath: IndexPath) -> CGSize
    @objc optional func listView(_ listView: UIListView, estimatedSizeForItemAt indexPath: IndexPath) -> CGSize
    @objc optional func listView(_ listView: UIListView, viewForHeaderInSection section: Int) -> UIView?
    @objc optional func listView(_ listView: UIListView, viewForFooterInSection section: Int) -> UIView?
    @objc optional func listView(_ listView: UIListView, heightForHeaderInSection section: Int) -> CGFloat
    @objc optional func listView(_ listView: UIListView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    @objc optional func listView(_ listView: UIListView, heightForFooterInSection section: Int) -> CGFloat
    @objc optional func listView(_ listView: UIListView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    @objc optional func listView(_ listView: UIListView, willDisplayHeaderView view: UIView, forSection section: Int)
    @objc optional func listView(_ listView: UIListView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    @objc optional func listView(_ listView: UIListView, willDisplayFooterView view: UIView, forSection section: Int)
    @objc optional func listView(_ listView: UIListView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    @objc optional func listView(_ listView: UIListView, willSlideToItemAt indexPath: IndexPath)
    @objc optional func listView(_ listView: UIListView, slidingDistanceForItemAt indexPath: IndexPath) -> CGFloat
    @objc optional func listView(_ listView: UIListView, didSlideToItemAt indexPath: IndexPath)
}
