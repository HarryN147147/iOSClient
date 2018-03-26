//
//  GenderController.swift
//  
//
//  Created by Harry Nguyen on 3/26/18.
//

import UIKit

class GenderController: DynamicController<GenderViewModel>
{
    private var _genderLabel: UILabel!
    private var _listbuttonLabel: UIButton!
    
    var genderLabel: UILabel
    {
        get
        {
            if(self._genderLabel == nil)
            {
                self._genderLabel = UILabel()
                self._genderLabel.textAlignment = NSTextAlignment.center
            }
            
            let genderLabel = self._genderLabel!
            
            return genderLabel
        }
    }
    
    var listbuttonLabel: UIButton
    {
        get
        {
            if(self._listbuttonLabel == nil)
            {
                self._listbuttonLabel = UIButton()
            }
            
            let listbuttonLabel = self._listbuttonLabel!
            
            return listbuttonLabel
        }
    }
    
    override func viewDidLoad()
    {
        self.view.addSubview(self.genderLabel)
        
        self.view.addSubview(self.listbuttonLabel)
    }
    
    override func render(size: CGSize)
    {
        
        self.genderLabel.frame.size.width = self.canvas.draw(tiles: 3)
        self.genderLabel.frame.size.height = self.canvas.draw(tiles: 1)
        self.genderLabel.frame.origin.x = self.canvas.draw(tiles: 1)
        self.genderLabel.frame.origin.y = self.canvas.draw(tiles: 1)
        self.genderLabel.backgroundColor = UIColor.lightGray
        
        self.listbuttonLabel.frame.size.width = self.canvas.draw(tiles: 7)
        self.listbuttonLabel.frame.size.height = self.canvas.draw(tiles: 1)
        self.listbuttonLabel.frame.origin.x = self.canvas.gridSize.width - self.genderLabel.frame.size.width - self.genderLabel.frame.origin.x - self.canvas.draw(tiles: 5)
        self.listbuttonLabel.frame.origin.y = self.genderLabel.frame.origin.y
        self.listbuttonLabel.backgroundColor = UIColor.lightGray
        
        let size = CGSize(width: self.canvas.gridSize.width, height: self.listbuttonLabel.frame.origin.y + self.listbuttonLabel.frame.size.height)
        super.render(size: size)
    }
    
    override func bind(viewModel: GenderViewModel)
    {
        super.bind(viewModel: viewModel)
        self.viewModel.addObserver(self,
                                   forKeyPath: "gender",
                                   options: NSKeyValueObservingOptions([NSKeyValueObservingOptions.initial,
                                                                        NSKeyValueObservingOptions.new]),
                                   context: nil)
        self.viewModel.addObserver(self,
                                   forKeyPath: "listbutton",
                                   options: NSKeyValueObservingOptions([NSKeyValueObservingOptions.initial,
                                                                        NSKeyValueObservingOptions.new]),
                                   context: nil)
        
        self.listbuttonLabel.addTarget(self.viewModel,
                                       action: #selector(self.viewModel.click),
                                       for: UIControlEvents.touchDown)
    }
    
    override func unbind()
    {
        super.unbind()
        self.viewModel.removeObserver(self, forKeyPath: "gender")
        self.viewModel.removeObserver(self, forKeyPath: "listbutton")
    }
    
    override func shouldSetKeyPath(_ keyPath: String?, ofObject object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if(keyPath == "gender")
        {
            let newValue = change![NSKeyValueChangeKey.newKey] as! String
            self.set(gender: newValue)
        }
        else if(keyPath == "listbutton")
        {
            let newValue = change![NSKeyValueChangeKey.newKey] as! String
            self.set(listbutton: newValue)
        }
    }
    
    func set(gender: String)
    {
        self._genderLabel.text = gender
    }
    
    func set(listbutton: String)
    {
        self._listbuttonLabel.setTitle(listbutton, for: UIControlState.normal)
        
    }
    
}
