//
//  age.swift
//  Venues
//
//  Created by Harry Nguyen on 3/20/18.
//  Copyright © 2018 Harry Nguyen. All rights reserved.
//

import UIKit

class GenderViewModel: DynamicViewModel
{
    @objc dynamic var gender: String!
    @objc dynamic var listbutton: String?
    
    init(gender: String, listbutton: String)
    {
        super.init()
        self.gender = gender
        self.listbutton = listbutton
    }
    
    @objc dynamic func click()
    {
        self.transit(transition: "Click", to: self.state)
        
    }
}






