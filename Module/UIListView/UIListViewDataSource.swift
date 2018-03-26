//
//  UIListViewDataSource.swift
//  jasmine
//
//  Created by Minh Nguyen on 11/25/15.
//  Copyright © 2015 Minh Nguyen. All rights reserved.
//

import UIKit

@objc
protocol UIListViewDataSource 
{
    func listView(_ listView: UIListView, cellForItemAt indexPath: IndexPath) -> UIListViewCell
    @objc optional func numberOfSections(in listView: UIListView) -> Int
    func listView(_ listView: UIListView, numberOfItemsInSection section: Int) -> Int
    @objc optional func listView(_ listView: UIListView, titleForHeaderInSection section: Int) -> String?
    @objc optional func listView(_ listView: UIListView, titleForFooterInSection section: Int) -> String?
}
