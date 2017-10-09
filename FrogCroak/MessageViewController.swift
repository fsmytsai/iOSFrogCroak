//
//  MessageViewController.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/10/8.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    let content:[String] = ["rabjiroejgirogjreiojgoirg","TextViewTexTextViewTextViewTextView\nTextViewTextViewTextViewTextViewTextViewTextViewTextViewtViewTextViewTextViewTextViewTextViewTextView\nTextViewTextViewTextViewTextViewTextViewTextView","Hello!"]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let l_Message: PaddingLabel
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Left", for: indexPath)
            l_Message = cell.contentView.subviews[2] as! PaddingLabel
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Right", for: indexPath)
            l_Message = cell.contentView.subviews[0] as! PaddingLabel
        }
        
        l_Message.text = content[indexPath.row]
        
        let rect = content[indexPath.row].boundingRect(with: CGSize(width: l_Message.frame.width - 40, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: l_Message.font], context: nil)
        
        l_Message.addConstraint(NSLayoutConstraint(item: l_Message, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: rect.height + 40))
        
//        l_Message.translatesAutoresizingMaskIntoConstraints = true
//        l_Message.frame.size.height = rect.height + 40
        
        if rect.width < l_Message.frame.width - 50 {
            let con = NSLayoutConstraint(item: l_Message, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: rect.width + 42)
            con.priority = UILayoutPriority(rawValue: 1000)
            l_Message.addConstraint(con)
//            l_Message.frame.size.width = rect.width + 40
        }
        
        l_Message.layer.cornerRadius = 20
        l_Message.layer.masksToBounds = true
        return cell
    }
}
