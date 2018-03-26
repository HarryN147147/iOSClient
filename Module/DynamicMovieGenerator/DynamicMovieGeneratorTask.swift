//
//  DynamicMovieGeneratorTask.swift
//  Pacific
//
//  Created by Minh Nguyen on 10/16/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

class DynamicMovieGeneratorTask
{
    var id : String
    var session : SDAVAssetExportSession
    
    init(session: SDAVAssetExportSession)
    {
        self.id = UUID().uuidString
        self.session = session
    }
}
