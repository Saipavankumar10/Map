//
//  LocationViewController.swift
//  Map
//
//  Created by saipavankumar on 17/06/19.
//  Copyright © 2019 saipavankumar. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class LocationViewController: UIViewController {
    

    @IBOutlet weak var Mapss: MKMapView!

    var venues = [Venue]()
    
    func fetchData()
    {
        let fileName = Bundle.main.path(forResource: "Venues", ofType: "json")
        let filePath = URL(fileURLWithPath: fileName!)
        var data: Data?
        do {
            data = try Data(contentsOf: filePath, options: Data.ReadingOptions(rawValue: 0))
        } catch let error {
            data = nil
            print("Report error \(error.localizedDescription)")
        }
        
        if let jsonData = data {
            let json = try! JSON(data: jsonData)
            if let venueJSONs = json["response"]["venues"].array {
                for venueJSON in venueJSONs {
                    if let venue = Venue.from(json: venueJSON) {
                        self.venues.append(venue)
                        
                        print("fetchData:\(venue)")
                        
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        Mapss.delegate = self
        fetchData()
        Mapss.addAnnotations(venues)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLocationServiceAuthenticationStatus()
    }
    
    private let regionRadius: CLLocationDistance = 1000 // 1km ~ 1 mile = 1.6km
    func zoomMapOn(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        Mapss.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Current Location
    
    var locationManager = CLLocationManager()
    
    func checkLocationServiceAuthenticationStatus()
    {
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            Mapss.showsUserLocation = true
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationViewController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last!
        self.Mapss.showsUserLocation = true
        zoomMapOn(location: location)
    }
}

extension LocationViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? Venue {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        let location = view.annotation as! Venue
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}














