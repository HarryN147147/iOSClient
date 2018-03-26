//
//  DynamicMovieGenerator.swift
//  Pacific
//
//  Created by Minh Nguyen on 10/16/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation
import AVFoundation

class DynamicMovieGenerator : DynamicViewModel
{
    private static var _defaultGenerator : DynamicMovieGenerator = DynamicMovieGenerator()
    
    class var `default` : DynamicMovieGenerator
    {
        return DynamicMovieGenerator._defaultGenerator
    }
    
    private var tasks : [DynamicMovieGeneratorTask]
    private var currentTask : DynamicMovieGeneratorTask?
    
    override init()
    {
        self.tasks = [DynamicMovieGeneratorTask]()
        
        super.init(state: "Off")
    }
    
    var currentTaskId : String?
    {
        get
        {
            return self.currentTask?.id
        }
    }
    
    func dropTask(id: String)
    {
        if (self.currentTask != nil)
        {
            if (self.currentTask!.id == id)
            {
                self.currentTask!.session.cancelExport()
            }
            else
            {
                self.dequeue(id: id)
            }
        }
    }
    
    func addTask(withSession session: SDAVAssetExportSession) -> String
    {
        let task = DynamicMovieGeneratorTask(session: session)
        self.tasks.append(task)
        
        if (self.state == "Off")
        {
            self.processNext()
        }
        
        return task.id
    }
    
    private func processNext()
    {
        let task = self.dequeueNext()
        
        if (task != nil)
        {
            self.currentTask = task

            self.currentTask!.session.exportAsynchronously()
            {
                DispatchQueue.main.async
                {
                    if (self.currentTask!.session.status == AVAssetExportSessionStatus.completed)
                    {
                        self.end()
                    }
                    else if (self.currentTask!.session.status == AVAssetExportSessionStatus.cancelled)
                    {
                        self.cancel()
                    }
                    else
                    {
                        self.error()
                    }
                    
                    self.currentTask = nil
                    self.processNext()
                }
            }
            
            self.begin()
        }
        else
        {
            self.reset()
        }
    }
    
    private func dequeueNext() -> DynamicMovieGeneratorTask?
    {
        if (self.tasks.count > 0)
        {
            return self.tasks.removeFirst()
        }
        
        return nil
    }
    
    private func dequeue(id: String)
    {
        for (counter, task) in self.tasks.enumerated().reversed()
        {
            if (task.id == id)
            {
                self.tasks.remove(at: counter)
                break
            }
        }
    }
        
    private func begin()
    {
        self.transit(transition: "Begin", from: "Off", to: "On")
    }
    
    private func end()
    {
        self.transit(transition: "End", from: "On", to: "Off")
    }
    
    private func cancel()
    {
        self.transit(transition: "Cancel", from: "On", to: "Off")
    }
    
    private func error()
    {
        self.transit(transition: "Error", from: "On", to: "Off")
    }
    
    override func reset()
    {
        self.reset(state: "Off")
    }
}
