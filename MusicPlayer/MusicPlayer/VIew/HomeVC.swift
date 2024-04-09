//
//  HomeVC.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import UIKit



class HomeVC: UIViewController {
    
    

    @IBOutlet weak var scrollView: UIScrollView!
    
    var viewControllers : [UIViewController] = []
    var previousIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(redirectToTabBar), name: Notification.Name.init(NOTIFCATION_NAME.NAVIGATE_TAB), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(redirectToTabBar), name: Notification.Name.init("SCROLL_VIEWCONTROLLERS"), object: nil)
        setupViewControllers()
    }

    func setupViewControllers(){
        let viewController1 = AppDelegate().sharedDelegate().storyboard().instantiateViewController(withIdentifier: "ForYouVC") as! ForYouVC
        
        let viewController2 = AppDelegate().sharedDelegate().storyboard().instantiateViewController(withIdentifier: "TopTracksVC") as! TopTracksVC
        
        viewControllers = [viewController1, viewController2]
        
        for (index, viewController) in viewControllers.enumerated() {
            //            addChild(viewController)
            scrollView.addSubview(viewController.view)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            viewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            viewController.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
            
            if index == 0 {
                viewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            } else {
                viewController.view.leadingAnchor.constraint(equalTo: viewControllers[index - 1].view.trailingAnchor).isActive = true
            }
            if index == viewControllers.count - 1 {
                viewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            }
        }
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(viewControllers.count), height: scrollView.frame.height)
        
    }
    
    @objc func redirectToTabBar(noti : Notification)
    {
        if let dict : [String : Any] = noti.userInfo as? [String : Any]
        {
            if let index : Int = dict["tabIndex"] as? Int
            {
                if index == 0 {
                    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                } else {
                    scrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: true)
                }
            }
        }
    }

}

extension HomeVC : UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if currentIndex != previousIndex {
            hepticFeedBackGenerator()
            NotificationCenter.default.post(name: Notification.Name.init(NOTIFCATION_NAME.NAVIGATE_TAB), object: nil, userInfo: ["tabIndex" : currentIndex])
        }

        // Update the previousIndex
        previousIndex = currentIndex
    }
}
