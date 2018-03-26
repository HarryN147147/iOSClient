//
//  UIPageViewDelegate.swift
//  jasmine
//
//  Created by Minh Nguyen on 2/28/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import UIKit

@objc
protocol UIPageViewDelegate : UIScrollViewDelegate
{
    @objc optional func pageView(_ pageView: UIPageView, willSelectItemAt indexPath: IndexPath) -> IndexPath?
    @objc optional func pageView(_ pageView: UIPageView, didSelectItemAt indexPath: IndexPath)
    @objc optional func pageView(_ pageView: UIPageView, willDeselectItemAt indexPath: IndexPath) -> IndexPath?
    @objc optional func pageView(_ pageView: UIPageView, didDeselectItemAt indexPath: IndexPath)
    @objc optional func pageView(_ pageView: UIPageView, willDisplay cell: UIPageViewCell, forItemAt indexPath: IndexPath)
    @objc optional func pageView(_ pageView: UIPageView, didEndDisplaying cell: UIPageViewCell, forItemAt indexPath: IndexPath)
    @objc optional func pageView(_ pageView: UIPageView, sizeForItemAt indexPath: IndexPath) -> CGSize
    @objc optional func pageView(_ pageView: UIPageView, estimatedSizeForItemAt indexPath: IndexPath) -> CGSize
    @objc optional func pageView(_ pageView: UIPageView, viewForHeaderInSection section: Int) -> UIView?
    @objc optional func pageView(_ pageView: UIPageView, viewForFooterInSection section: Int) -> UIView?
    @objc optional func pageView(_ pageView: UIPageView, widthForHeaderInSection section: Int) -> CGFloat
    @objc optional func pageView(_ pageView: UIPageView, estimatedWidthForHeaderInSection section: Int) -> CGFloat
    @objc optional func pageView(_ pageView: UIPageView, widthForFooterInSection section: Int) -> CGFloat
    @objc optional func pageView(_ pageView: UIPageView, estimatedWidthForFooterInSection section: Int) -> CGFloat
    @objc optional func pageView(_ pageView: UIPageView, willDisplayHeaderView view: UIView, forSection section: Int)
    @objc optional func pageView(_ pageView: UIPageView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    @objc optional func pageView(_ pageView: UIPageView, willDisplayFooterView view: UIView, forSection section: Int)
    @objc optional func pageView(_ pageView: UIPageView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    @objc optional func pageView(_ pageView: UIPageView, willSlideToItemAt indexPath: IndexPath)
    @objc optional func pageView(_ pageView: UIPageView, slidingDistanceForItemAt indexPath: IndexPath) -> CGFloat
    @objc optional func pageView(_ pageView: UIPageView, didSlideToItemAt indexPath: IndexPath)
}




