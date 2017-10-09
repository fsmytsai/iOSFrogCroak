//
//  MapViewController.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/10/2.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let Lat: CLLocationDegrees = 23.674764
        let Lng: CLLocationDegrees = 120.92
        
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Lat, Lng)
        
        let LatDelta: CLLocationDegrees = 4.5
        let LngDelta: CLLocationDegrees = 4.5
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(LatDelta, LngDelta)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        map.setRegion(region, animated: true)
        addMarkers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let Identifier = "MyPin"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: Identifier)
        if result == nil{
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: Identifier)
        } else {
            result?.annotation = annotation
        }
        result?.canShowCallout = true
        result?.image = UIImage(named: "normal")
        return result
    }

    func addMarkers(){
        let Url = URL(string: "https://frogcroak.azurewebsites.net/api/MarkerApi/GetMarkerList")
        let session = URLSession(configuration: .default)
        session.dataTask(with: Url!, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{ //如果有錯誤的話，印出錯誤，
                print("發生錯誤：\(error!.localizedDescription)")
                return       //有錯誤，跳出不再繼續執行
            }
            
            let decoder = JSONDecoder()
            
            if let data = data, let markerView = try? decoder.decode(MarkerView.self, from: data)
            {
                DispatchQueue.main.async {

                    for marker in markerView.MarkerList {
                        let Lat: CLLocationDegrees = marker.Latitude
                        let Lng: CLLocationDegrees = marker.Longitude

                        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Lat, Lng)

                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = marker.Title
                        annotation.subtitle = marker.Content
                        self.map.addAnnotation(annotation)
                    }
                }
            } else {
                print("error")
            }
        }).resume()
    }

}
