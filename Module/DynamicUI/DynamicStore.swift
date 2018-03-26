//
//  DynamicStore.swift
//  Pacific
//
//  Created by Minh Nguyen on 9/14/17.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import Foundation

class DynamicStore<ModelType: DynamicModel> : NSObject, Sequence
{
    private var _models : [ModelType]
    typealias Element = ModelType
    typealias Iterator = IndexingIterator<[ModelType]>
    private var _uuid : UUID!
    
    override init()
    {
        self._models = [ModelType]()
        
        super.init()
    }
    
    func decodeModels() -> [ModelType]?
    {
        var models : [ModelType]? = nil
        
        if (identifier == nil)
        {
            fatalError("DynamicStore: Cannot Decode With nil identifier")
        }
        else
        {
            let data = UserDefaults.standard.object(forKey: self.identifier!) as? Data
            
            if (data != nil)
            {
                models = NSKeyedUnarchiver.unarchiveObject(with: data!) as? [ModelType]
            }
        }
        
        return models
    }
    
    func encodeModels()
    {
        if (self.identifier == nil)
        {
            fatalError("DynamicStore: Cannot Encode With nil identifier")
        }
        else
        {
            let data = NSKeyedArchiver.archivedData(withRootObject: self._models)
            UserDefaults.standard.set(data, forKey: self.identifier!)
            
            if (!UserDefaults.standard.synchronize())
            {
                fatalError("DynamicStore: Encode Failed")
            }
        }
    }
    
    var identifier : String?
    {
        get
        {
            return nil
        }
    }
    
    @objc dynamic var models : [AnyObject]
    {
        get
        {
            var models = [AnyObject]()
            
            for model in self._models
            {
                models.append(model as AnyObject)
            }
            
            return models
        }
    }
    
    var count : Int
    {
        get
        {
            let count = self._models.count
            
            return count
        }
    }
    
    func makeIterator() -> IndexingIterator<[ModelType]>
    {
        return self._models.makeIterator()
    }
    
    func asyncGet(count: Int, info: [String:Any]?, isNetworkEnabled: Bool) -> DynamicPromise
    {
        let promise = DynamicPromise
        { (resolve, reject) in
            
            let models = [ModelType]()
            resolve(models)
        }
        
        return promise
    }
    
    func asyncAdd(_ model: ModelType, isNetworkEnabled: Bool) -> DynamicPromise
    {
        let promise = DynamicPromise
        { (resolve, reject) in
            
            resolve(model)
        }
        
        return promise
    }
    
    func asyncDelete(_ model: ModelType, isNetworkEnabled: Bool) -> DynamicPromise
    {
        let promise = DynamicPromise
        { (resolve, reject) in
            
            resolve(model)
        }
        
        return promise
    }
    
    func asyncUpdate(_ model: ModelType, isNetworkEnabled: Bool) -> DynamicPromise
    {
        let promise = DynamicPromise
        { (resolve, reject) in
            
            resolve(model)
        }
        
        return promise
    }
    
    private func changeModels(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, action: () -> ())
    {
        self.willChange(changeKind, valuesAt: indexes, forKey: "models")
        action()
        self.didChange(changeKind, valuesAt: indexes, forKey: "models")
    }
        
    @discardableResult
    func load(count: Int, info: [String:Any]?, isNetworkEnabled: Bool) -> DynamicPromise
    {
        let uuid = UUID()
        self._uuid = uuid
        
        let promise = self.asyncGet(count: count, info: info, isNetworkEnabled: isNetworkEnabled)
        .then
        { (value) -> Any? in
            
            if (uuid != self._uuid)
            {
                throw DynamicPromiseError(400)
            }
            
            let models = value as! [ModelType]
            
            if (models.count > 0)
            {
                var indexes = [Int]()
                
                for counter in 0...models.count - 1
                {
                    let model = models[counter]
                    model.uuid = UUID()
                    indexes.append(self._models.count + counter)
                }
                
                let indexSet = IndexSet(indexes)
                self.changeModels(NSKeyValueChange.insertion, valuesAt: indexSet)
                {
                    self._models.append(contentsOf: models)
                }
            }
            
            return self.models
        }
        
        return promise
    }
    
    @discardableResult
    func reload(count: Int, info: [String:Any]?, isNetworkEnabled: Bool) -> DynamicPromise
    {
        self.willChangeValue(forKey: "models")
        self._models = [ModelType]()
        self.didChangeValue(forKey: "models")
        
        let promise = self.load(count: count, info: info, isNetworkEnabled: isNetworkEnabled)
        
        return promise
    }
    
    func retrieve(at index: Int) -> ModelType
    {
        let model = self._models[index]
        
        return model
    }
    
    func retrieve(at uuid: UUID) -> ModelType?
    {        
        for model in self._models
        {
            if (model.uuid == uuid)
            {
                return model
            }
        }
        
        return nil
    }
    
    @discardableResult
    func insert(_ model: ModelType, at index: Int, isNetworkEnabled: Bool) -> DynamicPromise
    {
        let promise = self.asyncAdd(model, isNetworkEnabled: isNetworkEnabled)
        .then
        { (value) -> Any? in
            
            let model = value as! ModelType
            let indexSet = IndexSet([index])
            
            self.changeModels(NSKeyValueChange.insertion, valuesAt: indexSet)
            {
                model.uuid = UUID()
                self._models.insert(model, at: index)
            }
            
            return model
        }
        
        return promise
    }
    
    @discardableResult
    func insert(_ model: ModelType, at uuid: UUID, isNetworkEnabled: Bool) -> DynamicPromise
    {
        var index : Int! = nil
        
        for (counter, aModel) in self._models.enumerated()
        {
            if (aModel.uuid == uuid)
            {
                index = counter
                break
            }
        }
        
        if (index == nil)
        {
            fatalError("DynamicStore: Cannot Insert With Invalid UUID")
        }
        else
        {
            return self.insert(model, at: index, isNetworkEnabled: isNetworkEnabled)
        }
    }
    
    @discardableResult
    func remove(at index: Int, isNetworkEnabled: Bool) -> DynamicPromise
    {        
        let promise = self.asyncDelete(self._models[index], isNetworkEnabled: isNetworkEnabled)
        .then
        { (value) -> Any? in
            
            let model = value as! ModelType
            let indexSet = IndexSet([index])
            
            self.changeModels(NSKeyValueChange.removal, valuesAt: indexSet)
            {
                model.uuid = nil
                self._models.remove(at: index)
            }
            
            return model
        }
        
        return promise
    }
    
    @discardableResult
    func remove(at uuid: UUID, isNetworkEnabled: Bool) -> DynamicPromise
    {
        var index : Int! = nil
        
        for (counter, aModel) in self._models.enumerated()
        {
            if (aModel.uuid == uuid)
            {
                index = counter
                break
            }
        }
        
        if (index == nil)
        {
            fatalError("DynamicStore: Cannot Remove With Invalid UUID")
        }
        else
        {
            return self.remove(at: index, isNetworkEnabled: isNetworkEnabled)
        }
    }
    
    @discardableResult
    func push(_ model: ModelType, isNetworkEnabled: Bool) -> DynamicPromise
    {
        let promise = self.asyncAdd(model, isNetworkEnabled: isNetworkEnabled)
        .then
        { (value) -> Any? in
            
            let model = value as! ModelType
            let index = self._models.count
            let indexSet = IndexSet([index])
            
            self.changeModels(NSKeyValueChange.insertion, valuesAt: indexSet)
            {
                model.uuid = UUID()
                self._models.append(model)
            }
            
            return model
        }

        return promise
    }
    
    @discardableResult
    func pop(isNetworkEnabled: Bool) -> DynamicPromise
    {
        let promise = self.asyncDelete(self._models.last! as ModelType, isNetworkEnabled: isNetworkEnabled)
        .then
        { (value) -> Any? in
            
            let model = value as! ModelType
            let index = self._models.count - 1
            let indexSet = IndexSet([index])
            
            self.changeModels(NSKeyValueChange.removal, valuesAt: indexSet)
            {
                model.uuid = nil
                self._models.removeLast()
            }
            
            return model
        }
        
        return promise
    }
    
    @discardableResult
    func replace(at index: Int, with model: ModelType, isNetworkEnabled: Bool) -> DynamicPromise
    {
        let promise = self.asyncUpdate(model, isNetworkEnabled: isNetworkEnabled)
        .then
        { (value) -> Any? in
            
            let model = value as! ModelType
            let indexSet = IndexSet([index])
            
            self.changeModels(NSKeyValueChange.replacement, valuesAt: indexSet)
            {
                let currentUUID = self._models[index].uuid
                self._models[index].uuid = nil
                model.uuid = currentUUID
                self._models[index] = model
            }
            
            return model
        }
        
        return promise
    }
    
    @discardableResult
    func replace(at uuid: UUID, with model: ModelType, isNetworkEnabled: Bool) -> DynamicPromise
    {
        var index : Int! = nil
        
        for (counter, aModel) in self._models.enumerated()
        {
            if (aModel.uuid == uuid)
            {
                index = counter
                break
            }
        }
        
        if (index == nil)
        {
            fatalError("DynamicStore: Cannot Replace With Invalid UUID")
        }
        else
        {
            return self.replace(at: index, with: model, isNetworkEnabled: isNetworkEnabled)
        }
    }
}
