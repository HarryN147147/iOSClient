//
//  DynamicAsyncAwait.swift
//  Pacific
//
//  Created by Minh Nguyen on 8/2/17.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

@discardableResult
func async(_ block: @escaping () throws -> Any?) -> DynamicPromise
{
    let promise = DynamicPromise
    { (resolve, reject) in
        
        DispatchQueue(label: "dynamic.async.await.queue", attributes: .concurrent).async
        {
            do
            {
                let value = try block()
                
                DispatchQueue.main.async
                {
                    resolve(value)
                }
            }
            catch
            {
                DispatchQueue.main.async
                {
                    reject(error as! DynamicPromiseError)
                }
            }
        }
    }
    
    return promise
}

func await(_ promise: DynamicPromise) throws -> Any?
{
    var success : Any? = nil
    var failure : DynamicPromiseError? = nil
    
    let group = DispatchGroup()
    group.enter()
    
    promise
    .then
    { (value) -> Any? in
        
        success = value
        group.leave()
        
        return nil
    }
    .catch
    { (error) -> Any? in
        
        failure = error
        group.leave()
        
        return nil
    }
    
    group.wait()
    
    if (failure != nil)
    {
        throw failure!
    }
    
    return success
}
