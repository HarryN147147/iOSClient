//
//  GenderListController.swift
//  
//
//  Created by Harry Nguyen on 3/26/18.
//

import UIKit

class GenderListController: DynamicController<GenderListViewModel>
{
    var item1Button: UIButton!
    var item2Button: UIButton!
    
    
    
    override func viewDidLoad()
    {
        self.item1Button = UIButton()
        self.view.addSubview(self.item1Button)
        
        self.item2Button = UIButton()
        self.view.addSubview(self.item2Button)
        
    }
    
    override func render(size: CGSize)
    {
        self.item1Button.frame.size.width = self.canvas.gridSize.width
        self.item1Button.frame.size.height = self.canvas.draw(tiles: 3)
        self.item1Button.frame.origin.x = self.canvas.draw(tiles: 0)
        self.item1Button.frame.origin.y = self.canvas.draw(tiles: 0)
        self.item1Button.backgroundColor = UIColor.green
        
        self.item2Button.frame.size.width = self.canvas.gridSize.width
        self.item2Button.frame.size.height = self.canvas.draw(tiles: 3)
        self.item2Button.frame.origin.x = self.canvas.draw(tiles: 0)
        self.item2Button.frame.origin.y = self.canvas.draw(tiles: 3)
        self.item2Button.backgroundColor = UIColor.cyan
        
        let size = CGSize(width: self.canvas.gridSize.width, height: self.item2Button.frame.origin.y + self.item2Button.frame.size.height)
        super.render(size: size)
    }
    
    override func bind(viewModel: GenderListViewModel)
    {
        super.bind(viewModel: viewModel)
        
        viewModel.addObserver(self,
                              forKeyPath: "item1",
                              options: NSKeyValueObservingOptions([NSKeyValueObservingOptions.initial,
                                                                   NSKeyValueObservingOptions.new]),
                              context: nil)
        viewModel.addObserver(self,
                              forKeyPath: "item2",
                              options: NSKeyValueObservingOptions([NSKeyValueObservingOptions.initial,
                                                                   NSKeyValueObservingOptions.new]),
                              context: nil)
        self.item1Button.addTarget(self.viewModel,
                                   action: #selector(self.viewModel.back),
                                   for: UIControlEvents.touchDown)
        self.item2Button.addTarget(self.viewModel,
                                   action: #selector(self.viewModel.back),
                                   for: UIControlEvents.touchDown)
    }
    
    override func unbind()
    {
        super.unbind()
        
        viewModel.removeObserver(self, forKeyPath: "item1")
        viewModel.removeObserver(self, forKeyPath: "item2")
    }
    
    override func shouldSetKeyPath(_ keyPath: String?, ofObject object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if(keyPath == "item1")
        {
            let newValue = change![NSKeyValueChangeKey.newKey] as! String
            self.set(item1: newValue)
        }
        else if(keyPath == "item2")
        {
            let newValue = change![NSKeyValueChangeKey.newKey] as! String
            self.set(item2: newValue)
        }
    }
    
    func set(item1: String)
    {
        self.item1Button.setTitle(item1, for: UIControlState.normal)
    }
    
    func set(item2: String)
    {
        self.item2Button.setTitle(item2, for: UIControlState.normal)
    }
}
