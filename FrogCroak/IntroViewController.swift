//
//  IntroViewController.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/9/30.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var sv_Intro: UIScrollView!
    @IBOutlet weak var pc_Intro: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sv_Intro.contentSize.width = view.frame.width * 4
        for i in 0..<4{
            let OneView = UIView(frame: CGRect(
                                x: CGFloat(i) * view.frame.size.width,
                                y: 0,
                                width: view.frame.size.width,
                                height: view.frame.size.height))
            
            let ImageView = UIImageView(frame: CGRect(
                                x: 0,
                                y: 0,
                                width: view.frame.size.width,
                                height: view.frame.size.height))
            
            ImageView.image = UIImage(named: "page\(i + 1)")

            OneView.addSubview(ImageView)
            
            if i == 3{
                let StartButton = UIButton(type: .roundedRect)
                
                StartButton.setTitle("開始青蛙呱呱", for: .normal)
                
                StartButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
                
                StartButton.tintColor = UIColor.white
                
                StartButton.backgroundColor = UIColor.init(red: 0.2314, green: 0.3176, blue: 0.0784, alpha: 1)
                
                StartButton.layer.cornerRadius = 20
                
                StartButton.addTarget(self, action: #selector(self.start(sender:)), for: .touchUpInside)
                
                OneView.addSubview(StartButton)
                
                StartButton.translatesAutoresizingMaskIntoConstraints = false
                
                OneView.addConstraint(NSLayoutConstraint(item: StartButton, attribute: .centerX, relatedBy: .equal, toItem: OneView, attribute: .centerX, multiplier: 1, constant: 0))
                
                OneView.addConstraint(NSLayoutConstraint(item: StartButton, attribute: .centerY, relatedBy: .equal, toItem: OneView, attribute: .centerY, multiplier: 1, constant: 0))
                
                OneView.addConstraint(NSLayoutConstraint(item: StartButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.size.width / 2))
                
                OneView.addConstraint(NSLayoutConstraint(item: StartButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))
            }
            
            sv_Intro.addSubview(OneView)
        }
        sv_Intro.isPagingEnabled = true
        sv_Intro.bounces = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pcIntrolValueChange(_ sender: UIPageControl) {
        let offset = CGPoint(x: view.frame.width * CGFloat(sender.currentPage), y: 0)
        sv_Intro.setContentOffset(offset, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let CurrentPageNum = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        pc_Intro.currentPage = CurrentPageNum
    }
    
    @objc func start(sender: UIButton){
        (self.parent as! ViewController).startCroak()
    }
}
