//
//  TabBarViewController.swift
//  Cosmos
//
//  Created by Samuel Yanez on 12/8/18.
//  Copyright © 2018 Samuel Yanez. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    /// Previous selected view controller
    var previousViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        previousViewController = selectedViewController
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController == previousViewController, let navigationController = viewController as? UINavigationController, let discoverViewController = navigationController.topViewController as? DiscoverViewController {
                discoverViewController.scrollToTop()
        }
        previousViewController = viewController
    }
}
