//
//  MarkerView.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/10/2.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import Foundation

struct MarkerView: Codable {
    struct Markers: Codable {
        var MarkerId: Int
        var Latitude: Double
        var Longitude: Double
        var Title: String
        var Content: String
    }
    
    var MarkerList: [Markers]
}
