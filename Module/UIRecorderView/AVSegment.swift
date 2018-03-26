//
//  AVSegment.swift
//  jasmine
//
//  Created by Minh Nguyen on 5/6/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import Foundation

class AVSegment : NSObject
{
    var index : Int
    var outputFileURL : URL
    var startTime : Double
    var endTime : Double
    var orientation : String?
    
    init(withIndex index: Int, toOutputFileURL url: URL)
    {
        self.index = index
        self.outputFileURL = url
        self.startTime = 0
        self.endTime = 0
        
        super.init()
    }
}
