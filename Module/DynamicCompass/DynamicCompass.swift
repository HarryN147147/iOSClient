//
//  DynamicCompass.swift
//  jasmine
//
//  Created by Minh Nguyen on 4/28/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import UIKit
import CoreMotion

class DynamicCompass: NSObject
{
    weak var delegate : DynamicCompassDelegate?
    private var _orientation : UIInterfaceOrientation?
    private var _accelerometerQueue : OperationQueue
    private var _motionManager: CMMotionManager
    
    override init()
    {
        self._accelerometerQueue = OperationQueue()
        self._motionManager = CMMotionManager()
        
        super.init()
        
        self._motionManager.deviceMotionUpdateInterval = 0.01
        
        if (self._motionManager.isAccelerometerAvailable)
        {
            self._motionManager.startAccelerometerUpdates(to: self._accelerometerQueue, withHandler:
            { (data, error) in
                
                if (data == nil)
                {
                    return
                }
                
                var interfaceOrientation : UIInterfaceOrientation? = nil
                let angle = (atan2(data!.acceleration.y, data!.acceleration.x)) * 180 / .pi
                
                if (fabs(angle) <= 45)
                {
                    interfaceOrientation = UIInterfaceOrientation.landscapeLeft

                }
                else if ((fabs(angle) > 45) && (fabs(angle) < 135))
                {
                    if (angle > 0)
                    {
                        interfaceOrientation = UIInterfaceOrientation.portraitUpsideDown
                    }
                    else
                    {
                        interfaceOrientation = UIInterfaceOrientation.portrait
                    }
                }
                else
                {
                    interfaceOrientation = UIInterfaceOrientation.landscapeRight
                }
                
                if (self._orientation == nil || interfaceOrientation != self._orientation)
                {
                    self._orientation = interfaceOrientation
                    
                    self.delegate?.compass?(self, didChangeTo: interfaceOrientation!)
                }
            })
        }        
    }
    
    deinit
    {
        self._motionManager.stopAccelerometerUpdates()
    }

    
    var orientation : UIInterfaceOrientation?
    {
        get
        {
            return self._orientation
        }
    }
}
