//
//  SharedService.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/11/21.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit

class SharedService {
    public static func ShowErrorDialog(_ ErrorMessage: String, _ ViewController: UIViewController){
        let myAlert = UIAlertController(title: "錯誤",
                                        message: ErrorMessage,
                                        preferredStyle: .alert)
        //產生第一顆按鈕
        let okAction = UIAlertAction(title: "知道了",
                                     style: .default, handler: {
                                        (action:UIAlertAction) -> () in
                                        ViewController.dismiss(animated: true, completion: nil)
        })
        
        myAlert.addAction(okAction)
        ViewController.present(myAlert, animated: true, completion: nil)
    }
}
