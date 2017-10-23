//
//  MapViewController.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/10/2.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    var mapView: GMSMapView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(withLatitude: 23.674764, longitude: 120.796819, zoom: 7.3)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView

        GetMarkers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func GetMarkers(){
        let Url = URL(string: "https://frogcroak.azurewebsites.net/api/MarkerApi/GetMarkerList")
        URLSession.shared.dataTask(with: Url!, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("發生錯誤：\(error!.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let markerView = try? JSONDecoder().decode(MarkerView.self, from: data!)
                    {
                        DispatchQueue.main.async {

                            for var marker in markerView.MarkerList {
                                marker.Content = marker.Content.replacingOccurrences(of: "\\n", with: "\n")
                                // Creates a marker
                                let gmsMarker = GMSMarker()
                                gmsMarker.position = CLLocationCoordinate2D(latitude: marker.Latitude, longitude: marker.Longitude)
                                gmsMarker.title = marker.Title
                                gmsMarker.snippet = marker.Content
                                gmsMarker.icon = UIImage(named: "normal")
                                gmsMarker.map = self.mapView
                            }
                        }
                    } else {
                        print("json 解析失敗")
                    }
                } else {
                    print("response.statusCode = \(response.statusCode)")
                }

            } else {
                print("response 解析失敗")
            }
        }).resume()
    }

}
