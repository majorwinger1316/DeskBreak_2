//
//  MyViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 20/03/25.
//

import UIKit

class MyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        reorderTabs()
    }

    func reorderTabs() {
        // Access the UITabBarController
        guard let tabBarController = self.tabBarController else {
            print("Tab bar controller is nil")
            return
        }

        // Get the current view controllers
        guard var viewControllers = tabBarController.viewControllers else {
            print("View controllers array is nil")
            return
        }

        // Ensure there are at least 3 tabs
        if viewControllers.count < 3 {
            print("Not enough tabs to reorder")
            return
        }

        // Print original order for debugging
        print("Original order: \(viewControllers.map { $0.tabBarItem.title ?? "Untitled" })")

        // Reorder the tabs
        let firstTab = viewControllers[0]
        let middleTab = viewControllers[1]
        let lastTab = viewControllers[2]

        viewControllers[0] = middleTab
        viewControllers[1] = lastTab
        viewControllers[2] = firstTab

        // Assign the reordered view controllers back to the tab bar controller
        tabBarController.viewControllers = viewControllers

        // Set the selected index to the new first tab
        tabBarController.selectedIndex = 0

        // Print reordered order for debugging
        print("Reordered order: \(viewControllers.map { $0.tabBarItem.title ?? "Untitled" })")
    }
}
