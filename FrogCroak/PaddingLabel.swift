//
//  PaddingLabel.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/10/8.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 15, left: 20, bottom: 15, right: 20)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
