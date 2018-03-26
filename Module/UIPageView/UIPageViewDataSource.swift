//
//  UIPageViewDataSource.swift
//  jasmine
//
//  Created by Minh Nguyen on 11/25/15.
//  Copyright © 2015 Minh Nguyen. All rights reserved.
//

import UIKit

@objc
protocol UIPageViewDataSource
{
    func pageView(_ pageView: UIPageView, cellForItemAt indexPath: IndexPath) -> UIPageViewCell
    @objc optional func numberOfSections(in pageView: UIPageView) -> Int
    func pageView(_ pageView: UIPageView, numberOfItemsInSection section: Int) -> Int
    @objc optional func pageView(_ pageView: UIPageView, titleForHeaderInSection section: Int) -> String?
    @objc optional func pageView(_ pageView: UIPageView, titleForFooterInSection section: Int) -> String?
}
