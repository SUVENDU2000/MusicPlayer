//
//  TabBarController.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import UIKit

class TabBarController: UITabBarController, TabBarViewDelegate {
    
    var tabBarView : TabBarView = TabBarView()
    var tabBarViewHeightConstraint: NSLayoutConstraint?
    var isGloblaPlayerHidden : Bool = false
    
    override func loadView() {
        super.loadView()
        tabBarView = Bundle.main.loadNibNamed("TabBarView", owner: nil, options: nil)?.last as! TabBarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playBackError), name: Notification.Name.init(NOTIFCATION_NAME.PLAYBACK_ERROR), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(redirectToTabBar), name: Notification.Name.init(NOTIFCATION_NAME.NAVIGATE_TAB), object: nil)
        tabBarView.delegate = self
        addTabBarView()
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.frame.size.height = 120 + ((UIScreen.main.bounds.size.height >= 812) ? 30 : 0)
        tabBar.frame.origin.y = UIScreen.main.bounds.size.height - 120 + ((UIScreen.main.bounds.size.height >= 812) ? 30 : 0)
    }
    
    @objc func playBackError() {
        DispatchQueue.main.async {
            self.tabBarView.loaderView.stopAnimating()
            let alert = UIAlertController(title: "Playback Error", message: "This song cant be played.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }

    }
    
    
    @objc func redirectToTabBar(noti : Notification)
    {
        if let dict : [String : Any] = noti.userInfo as? [String : Any]
        {
            if let index : Int = dict["tabIndex"] as? Int
            {
                tabBarView.resetAllButton()
                tabBarView.lastIndex = index
                tabBarView.selectTabButton()
                tabSelectedAtIndex(index: index)
            }
        }
    }
    
    //MARK: - TABBAR SETUP
    func setup()
    {
        var navigatonControllers = [UINavigationController]()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
//        let forYouViewController = storyBoard.instantiateViewController(withIdentifier: "ForYouVC")
//        let forNavigatioController : UINavigationController = UINavigationController(rootViewController: forYouViewController)
//        navigatonControllers.append(forNavigatioController)
//        
//        let topTracksViewController = storyBoard.instantiateViewController(withIdentifier: "TopTracksVC")
//        let topTracksNavigationController : UINavigationController = UINavigationController(rootViewController: topTracksViewController)
//        navigatonControllers.append(topTracksNavigationController)
        
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC")
        let homeNavigationController : UINavigationController = UINavigationController(rootViewController: homeViewController)
        navigatonControllers.append(homeNavigationController)
        
        self.viewControllers = navigatonControllers;
        self.tabSelectedAtIndex(index: 0)
    }
    
    func tabSelectedAtIndex(index: Int) {
        NotificationCenter.default.post(name: Notification.Name.init("SCROLL_VIEWCONTROLLERS"), object: nil, userInfo: ["tabIndex" : index])
        hepticFeedBackGenerator()
        setSelectedViewController(selectedViewController: (self.viewControllers?[0])!, tabIndex: index)
    }
    
    func setSelectedViewController(selectedViewController:UIViewController, tabIndex:Int)
    {
        // pop to root if tapped the same controller twice
        if self.selectedViewController == selectedViewController {
            (self.selectedViewController as! UINavigationController).popToRootViewController(animated: true)
        }else{
            
        }
        super.selectedViewController = selectedViewController
        
    }
    
    func addTabBarView()
    {
        self.tabBarView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tabBarView)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.tabBarView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.tabBarView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.tabBarView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
        
        tabBarViewHeightConstraint = self.tabBarView.heightAnchor.constraint(equalToConstant:  120 + ((UIScreen.main.bounds.size.height >= 812) ? 30 : 0))
        tabBarViewHeightConstraint?.isActive = true
        
        
        self.view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

