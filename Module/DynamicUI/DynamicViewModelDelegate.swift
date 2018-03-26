//
//  DynamicViewModelDelegate.swift
//  Pacific
//
//  Created by Minh Nguyen on 12/13/17.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

@objc
protocol DynamicViewModelDelegate
{
    func viewModel(_ viewModel: DynamicViewModel, transition: String, from oldState: String, to newState: String)
}
