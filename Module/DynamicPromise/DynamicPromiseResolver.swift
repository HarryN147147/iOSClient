//
//  DynamicPromiseResolver.swift
//  Pacific
//
//  Created by Minh Nguyen on 8/22/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

class DynamicPromiseResolver
{
    var fulfiller : ((_ value: Any?) throws -> Any?)?
    var rejector : ((_ reason: DynamicPromiseError) throws -> Any?)?
    
    init(fulfiller: @escaping (_ value: Any?) throws -> Any?)
    {
        self.fulfiller = fulfiller
    }
    
    init(rejector: @escaping (_ reason: DynamicPromiseError) throws -> Any?)
    {
        self.rejector = rejector
    }
}
