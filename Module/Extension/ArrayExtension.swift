//
//  ArrayExtension.swift
//  Pacific
//
//  Created by Minh Nguyen on 8/22/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

extension Array
{
    mutating func shift() -> Element?
    {
        if (!self.isEmpty)
        {
            return self.remove(at: 0)
        }
        
        return nil
    }
}
