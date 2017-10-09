//
//  ViewController.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/9/29.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    var introViewcontroller: IntroViewController!
    var homeTabBarController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let preferencesRead = UserDefaults?.init(.standard)
        
        if (preferencesRead?.bool(forKey: "NeverShowIntro"))! {
            homeTabBarController = storyboard?.instantiateViewController(withIdentifier: "tbc_Home")
            switchViewController(from: nil, to: homeTabBarController)
        } else {
            introViewcontroller = storyboard?.instantiateViewController(withIdentifier: "vc_Intro") as! IntroViewController
            switchViewController(from: nil, to: introViewcontroller)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startCroak(){
        let preferencesWrite = UserDefaults?.init(.standard)
        preferencesWrite?.set(true, forKey: "NeverShowIntro")
        homeTabBarController = storyboard?.instantiateViewController(withIdentifier: "tbc_Home")
        switchViewController(from: introViewcontroller, to: homeTabBarController)
    }
    
    func switchViewController(from fromVC: UIViewController?, to toVC: UIViewController?) {
        if let from = fromVC {
            from.willMove(toParentViewController: nil) // 通知from即将从父ViewController移除
            from.view.removeFromSuperview() // 移除from的view
            from.removeFromParentViewController() // 移除from的ViewController
        } else {
            print("fromVC is nil")
        }
        
        if let to = toVC {
            self.addChildViewController(to) // 添加to的ViewController到父ViewController
            to.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            self.containerView.addSubview(to.view)
            to.didMove(toParentViewController: self) // 通知to已经添加到父ViewController
        } else {
            print("toVC is nil")
        }
    }
}

