//
//  TabViewController.swift
//  SUM
//
//  Created by Luís Sousa on 04/01/2022.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

   
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
   }

    
    func setupMiddleButton() {

         let middleBtn = UIButton(frame: CGRect(x: (self.view.bounds.width / 2)-25, y: -20, width: 50, height: 50))
         
     
         
         //add to the tabbar and add click event
         self.tabBar.addSubview(middleBtn)
         middleBtn.addTarget(self, action: #selector(self.menuButtonAction), for: .touchUpInside)

         self.view.layoutIfNeeded()
     }
    // Menu Button Touch Action
       @objc func menuButtonAction(sender: UIButton) {
           self.selectedIndex = 2   //to select the middle tab. use "1" if you have only 3 tabs.

}

}
