//
//  GenderOverViewController.swift
//  
//
//  Created by Harry Nguyen on 3/26/18.
//

import UIKit

class GenderOverviewController: DynamicController<GenderOverviewViewModel>, UIPageViewDelegate, UIPageViewDataSource,DynamicViewModelDelegate
{
    private var _genderController: GenderController!
    private var _genderListController: GenderListController!
    private var _pageView: UIPageView!
    
    
    var genderController: GenderController!
    {
        if(self._genderController == nil)
        {
            self._genderController = GenderController()
        }
        
        let genderController = self._genderController
        
        return genderController
    }
    
    var genderListController: GenderListController
    {
        if(self._genderListController == nil)
        {
            self._genderListController = GenderListController()
        }
        
        let genderListController = self._genderListController!
        
        return genderListController
    }
    
    var pageView: UIPageView!
    {
        get
        {
            if(self._pageView == nil)
            {
                self._pageView = UIPageView()
                self._pageView.delegate = self
                self._pageView.dataSource = self
            }
            
            let pageView = self._pageView!
            
            return pageView
        }
    }
    
    var genderControllerSize: CGSize
    {
        get
        {
            let genderController = CGSize.zero
            
            return genderController
        }
    }
    
    var genderListControllerSize: CGSize
    {
        get
        {
            let genderListControllerSize = CGSize.zero
            
            return genderListControllerSize
        }
    }
    
    override func viewDidLoad()
    {
        self.view.addSubview(self.pageView)
        
    }
    
    override func render(size: CGSize)
    {
        self.pageView.frame.size.width = self.canvas.gridSize.width
        self.pageView.frame.size.height = self.canvas.gridSize.height
        self.pageView.reloadData()
        
        self.genderController.render(size: self.genderControllerSize)
        
        self.genderListController.render(size: self.genderListControllerSize)
    }
    
    override func bind(viewModel: GenderOverviewViewModel)
    {
        super.bind(viewModel: viewModel)
        self.viewModel.delegate = self
        self.genderController.bind(viewModel: self.viewModel.genderViewModel)
        self.genderListController.bind(viewModel: self.viewModel.genderListViewModel)
        
        
        self.genderController.viewModel.addObserver(self,
                                                    forKeyPath: "event",
                                                    options: NSKeyValueObservingOptions([NSKeyValueObservingOptions.initial, NSKeyValueObservingOptions.new]),
                                                    context: nil)
        
        self.genderListController.viewModel.addObserver(self,
                                                        forKeyPath: "event",
                                                        options: NSKeyValueObservingOptions([NSKeyValueObservingOptions.initial, NSKeyValueObservingOptions.new]),
                                                        context: nil)
    }
    
    override func unbind()
    {
        super.unbind()
        
        self.viewModel.delegate = nil
        
        self.genderController.unbind()
        self.genderController.viewModel.removeObserver(self, forKeyPath: "event")
        
        self.genderListController.unbind()
        self.genderListController.viewModel.removeObserver(self, forKeyPath: "event")
    }
    
    
    override func shouldSetKeyPath(_ keyPath: String?, ofObject object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if (keyPath == "event")
        {
            let newValue = change![NSKeyValueChangeKey.newKey] as! String
            
            if (self.genderController.viewModel === object as! NSObject)
            {
                self.set(event: newValue, viewModel: self.viewModel.genderViewModel)
            }
            else if (self.genderListController.viewModel === object as! NSObject)
            {
                self.set(event: newValue, viewModel: self.viewModel.genderListViewModel)
            }
            
        }
    }
    
    func set(event: String, viewModel: GenderViewModel)
    {
        if (event == "DidClick")
        {
            self.viewModel.enterGenderList()
        }
    }
    
    func set(event: String, viewModel: GenderListViewModel)
    {
        if(event == "DidBack")
        {
            self.viewModel.enterGender()
        }
    }
    
    
    func viewModel(_ viewModel: DynamicViewModel, transition: String, from oldState: String, to newState: String)
    {
        var indexPath : IndexPath? = nil
        
        if (transition == "EnterGender")
        {
            indexPath = IndexPath(item: 0, section: 0)
        }
        else if (transition == "EnterGenderList")
        {
            indexPath = IndexPath(item: 1, section: 0)
        }
        
        if (indexPath != nil)
        {
            if (self.pageView.visibleCells.count > 0)
            {
                if (self.pageView.indexPathsForVisibleItems!.first!.item != indexPath!.item)
                {
                    self.pageView.scrollToItem(at: indexPath!, at: UIPageViewScrollPosition.left, animated: true)
                }
            }
            else
            {
                self.pageView.scrollToItem(at: indexPath!, at: UIPageViewScrollPosition.left, animated: false)
            }
        }
    }
    
    func pageView(_ pageView: UIPageView, numberOfItemsInSection section: Int) -> Int
    {
        return 2
    }
    
    func pageView(_ pageView: UIPageView, cellForItemAt indexPath: IndexPath) -> UIPageViewCell
    {
        let cell = UIPageViewCell()
        
        if(indexPath.item == 0)
        {
            cell.addSubview(self.genderController.view)
        }
        else if(indexPath.item == 1)
        {
            cell.addSubview(self.genderListController.view)
        }
        
        //        if (self.viewModel.state == "GenderList")
        //        {
        //            cell.addSubview(self.genderListController.view)
        //        }
        //        else if (self.viewModel.state == "Gender")
        //        {
        //            cell.addSubview(self.genderController.view)
        //        }
        
        return cell
    }
    
    func pageView(_ pageView: UIPageView, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let itemSize = CGSize(width: self.canvas.gridSize.width, height: UIPageViewAutomaticDimension)
        
        return itemSize
    }
    
    
    
}
