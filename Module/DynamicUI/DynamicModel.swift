//
//  DynamicModel.swift
//  Pacific
//
//  Created by Minh Nguyen on 8/31/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation
import SwiftyJSON

class DynamicModel : NSObject, NSCoding
{
    var uuid : UUID?
    
    required override init()
    {
        self.uuid = nil
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        
        let data = aDecoder.decodeObject(forKey: "data") as? [String:Any]
                
        if (data != nil)
        {
            self.data = JSON(data!)
        }
    }
    
    func encode(with aCoder: NSCoder)
    {
        let data = self.data.dictionaryObject
        aCoder.encode(data, forKey: "data")
    }
    
    var data : JSON
    {
        get
        {
            return JSON.null
        }
        
        set(newValue){}
    }    
}

