//
//  ProfileController.swift
//  
//
//  Created by Harry Nguyen on 3/26/18.
//

import UIKit

class UserInfoController: DynamicController<UserInfoViewModel>, DynamicViewModelDelegate
{

    private var _jobTitleLabel: UILabel!
    private var _jobTitleInitial: UILabel!
    private var _jobTextView: UITextView!

    private var _companyLabel: UILabel!
    private var _companyInitial: UILabel!
    private var _companyTextView: UITextView!

    private var _aboutMeLabel: UILabel!
    private var _aboutmeInitial: UILabel!
    private var _aboutMeTextView: UITextView!




    var jobTitleLabel: UILabel
    {
        get
        {
            if(self._jobTitleLabel == nil)
            {
                self._jobTitleLabel = UILabel()
            }

            let jobTitleLabel = self._jobTitleLabel!

            return jobTitleLabel
        }
    }

    var jobTitleInitial: UILabel
    {
        get
        {
            if(self._jobTitleInitial == nil)
            {
                self._jobTitleInitial = UILabel()
            }

            let jobTitleInitial = self._jobTitleInitial!

            return jobTitleInitial
        }
    }

    var jobTextView: UITextView
    {
        get
        {
            if(self._jobTextView ==  nil)
            {
                self._jobTextView = UITextView()
            }

            let jobTextView = self._jobTextView!

            return jobTextView
        }
    }


    var companyLabel: UILabel
    {
        get
        {
            if(self._companyLabel == nil)
            {
                self._companyLabel = UILabel()
            }

            let companyLabel = self._companyLabel!

            return companyLabel
        }
    }

    var companyInitial: UILabel
    {
        get
        {
            if(self._companyInitial == nil)
            {
                self._companyInitial = UILabel()
            }

            let companyInitial = self._companyInitial!

            return companyInitial
        }
    }

    var companyTextView: UITextView
    {
        get
        {
            if(self._companyTextView == nil)
            {
                self._companyTextView = UITextView()
            }

            let companyTextView = self._companyTextView!

            return companyTextView
        }
    }


    var aboutMeLabel : UILabel
    {
        get
        {
            if(self._aboutMeLabel == nil)
            {
                self._aboutMeLabel = UILabel()
            }

            let aboutMeView = self._aboutMeLabel!

            return aboutMeView
        }
    }


    override func viewDidLoad()
    {
        self.view.addSubview(self.jobTitleLabel)
        self.jobTitleLabel.text = "Job Title"

        self.view.addSubview(self.jobTextView)

        self.view.addSubview(self.jobTitleInitial)

        self.view.addSubview(self.companyLabel)
        self.companyLabel.text = "Company"

        self.view.addSubview(self.companyInitial)

        self.view.addSubview(self.companyTextView)

        self.view.addSubview(self.aboutMeLabel)
        self.aboutMeLabel.text = "About Me"

    }

    override func render(size: CGSize)
    {
        super.render(size: size)



        self.jobTitleLabel.frame.size.height = self.canvas.draw(tiles: 3)
        self.jobTitleLabel.frame.size.width = self.canvas.gridSize.width
        self.jobTitleLabel.frame.origin.x = self.canvas.draw(tiles: 0)
        self.jobTitleLabel.frame.origin.y = self.canvas.draw(tiles: 0)
        self.jobTitleLabel.backgroundColor = UIColor.blue

        self.jobTextView.frame.size.height = self.canvas.draw(tiles: 3)
        self.jobTextView.frame.size.width = self.canvas.gridSize.width
        self.jobTextView.frame.origin.x = self.jobTitleLabel.frame.origin.x
        self.jobTextView.frame.origin.y = self.jobTitleLabel.frame.size.height

        self.jobTitleInitial.frame.size.height = self.canvas.draw(tiles: 1)
        self.jobTitleInitial.frame.size.width = self.canvas.gridSize.width
        self.jobTitleInitial.frame.origin.x = self.jobTextView.frame.origin.x
        self.jobTitleInitial.frame.origin.y = self.jobTitleLabel.frame.size.height
        self.jobTitleInitial.font = UIFont.systemFont(ofSize: self.canvas.draw(tiles: 0.6))
        self.jobTitleInitial.textColor = UIColor.gray


        self.companyLabel.frame.size.height = self.jobTitleLabel.frame.size.height
        self.companyLabel.frame.size.width = self.canvas.gridSize.width
        self.companyLabel.frame.origin.x = self.jobTitleLabel.frame.origin.x
        self.companyLabel.frame.origin.y = self.jobTitleLabel.frame.size.height + self.jobTextView.frame.size.height
        self.companyLabel.backgroundColor = UIColor.green

        self.companyTextView.frame.size.height = self.jobTitleLabel.frame.size.height
        self.companyTextView.frame.size.width = self.canvas.gridSize.width
        self.companyTextView.frame.origin.x = self.jobTitleLabel.frame.origin.x
        self.companyTextView.frame.origin.y = self.jobTitleLabel.frame.size.height + self.jobTextView.frame.size.height

        self.companyInitial.frame.size.height = self.jobTitleInitial.frame.size.height
        self.companyInitial.frame.size.width = self.canvas.gridSize.width
        self.companyInitial.frame.origin.x = self.jobTitleLabel.frame.origin.x
        self.companyInitial.frame.origin.y = self.companyTextView.frame.origin.y


        self.aboutMeLabel.frame.size.height = self.jobTitleLabel.frame.size.height
        self.aboutMeLabel.frame.size.width = self.canvas.gridSize.width
        self.aboutMeLabel.frame.origin.x = self.canvas.draw(tiles: 0)
        self.aboutMeLabel.frame.origin.y = self.jobTitleLabel.frame.size.height + self.companyLabel.frame.size.height + self.jobTextView.frame.size.height + self.companyTextView.frame.size.height
        self.aboutMeLabel.backgroundColor = UIColor.gray


    }

    override func bind(viewModel: UserInfoViewModel)
    {
        super.bind(viewModel: viewModel)

        viewModel.delegate = self
        viewModel.textViewModel.delegate = self
        viewModel.addObserver(self,
                              forKeyPath: "jobInitital",
                              options: NSKeyValueObservingOptions([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial]),
                              context: nil)

        NotificationCenter.default.addObserver(viewModel.textViewModel,
                                               selector: #selector(TextViewModel.begin),
                                               name: NSNotification.Name.UITextViewTextDidBeginEditing,
                                               object: self.jobTextView)
        NotificationCenter.default.addObserver(viewModel.textViewModel,
                                               selector: #selector(TextViewModel.change),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: self.jobTextView)
        NotificationCenter.default.addObserver(viewModel.textViewModel,
                                               selector: #selector(TextViewModel.complete),
                                               name: NSNotification.Name.UITextViewTextDidEndEditing,
                                               object: self.jobTextView)
    }

    override func unbind()
    {
        self.viewModel.delegate = nil
        self.viewModel.textViewModel.delegate = nil
        self.viewModel.removeObserver(self, forKeyPath: "jobInitital")

        NotificationCenter.default.removeObserver(self.viewModel.textViewModel,
                                                  name: NSNotification.Name.UITextViewTextDidBeginEditing,
                                                  object: self.jobTextView)
        NotificationCenter.default.removeObserver(self.viewModel.textViewModel,
                                                  name: NSNotification.Name.UITextViewTextDidChange,
                                                  object: self.jobTextView)
        NotificationCenter.default.removeObserver(self.viewModel.textViewModel,
                                                  name: NSNotification.Name.UITextViewTextDidEndEditing,
                                                  object: self.jobTextView)
    }

    override func shouldSetKeyPath(_ keyPath: String?, ofObject object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if(keyPath == "jobInitital")
        {
            let  newValue = change![NSKeyValueChangeKey.newKey] as! String
            self.set(jobInitital: newValue)
        }
    }

    func set(jobInitital: String)
    {
        self.jobTitleInitial.text = jobInitital
    }

    func viewModel(_ viewModel: DynamicViewModel, transition: String, from oldState: String, to newState: String)
    {
        if(self.viewModel.textViewModel === viewModel)
        {
            if(transition == "Change")
            {
                self.viewModel.content == self.jobTextView.text
                self.jobTitleInitial.text = nil

            }
            else if(transition == "Begin")
            {
                self.viewModel.content == self.jobTextView.text
                self.jobTitleInitial.text = nil
            }
            else if(transition == "Clear")
            {
                self.jobTitleInitial.text = "Add Job Here"
            }
        }

    }

}

