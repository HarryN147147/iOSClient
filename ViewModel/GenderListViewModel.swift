//
//  genderList.swift
//  Venues
//
//  Created by Harry Nguyen on 3/21/18.
//  Copyright © 2018 Harry Nguyen. All rights reserved.
//

import UIKit

class GenderListViewModel: DynamicViewModel
{
    @objc dynamic var item1: String!
    @objc dynamic var item2: String!
    
    init(item1: String, item2: String)
    {
        super.init()
        self.item1 = item1
        self.item2 = item2
    }
    
    @objc dynamic func back()
    {
        self.transit(transition: "Back", to: self.state)
    }
}



