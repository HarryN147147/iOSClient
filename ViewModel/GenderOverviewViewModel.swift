//
//  genderOverview.swift
//  Venues
//
//  Created by Harry Nguyen on 3/21/18.
//  Copyright © 2018 Harry Nguyen. All rights reserved.
//

import UIKit

class GenderOverviewViewModel: DynamicViewModel
{
    private var _genderViewModel: GenderViewModel!
    private var _genderListViewModel: GenderListViewModel!
    
    var genderViewModel: GenderViewModel
    {
        get
        {
            if(self._genderViewModel == nil)
            {
                self._genderViewModel = GenderViewModel(gender: "Gender", listbutton: "Male")
            }
            
            let genderViewModel = self._genderViewModel!
            
            return genderViewModel
        }
    }
    
    var genderListViewModel: GenderListViewModel!
    {
        get
        {
            if(self._genderListViewModel == nil)
            {
                self._genderListViewModel = GenderListViewModel(item1: "Male", item2: "Female")
            }
            
            let genderListViewModel = self._genderListViewModel!
            
            return genderListViewModel
        }
    }
    
    
    override init()
    {
        super.init(state: "Gender")
    }
    
    func enterGender()
    {
        self.transit(transition: "EnterGender", to: self.state)
    }
    
    func enterGenderList()
    {
        self.transit(transition: "EnterGenderList", to: self.state)
    }
}



