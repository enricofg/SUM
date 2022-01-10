//
//  HomeViewController.swift
//  SUM
//
//  Created by Enrico Florentino Gomes on 10/01/2022.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var homeMapView: MKMapView!
    let networkManager = NetworkManager()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        //set up location manager if location services are enabled
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
//            //get access to current location permission check
//            switch locationManager.authorizationStatus {
//                case .restricted, .denied, .notDetermined:
//                    CLLocationManager().requestWhenInUseAuthorization()
//                default:
//                    print()
//            }
        } else {
            print("Location services are not enabled.")
        }
        
        homeMapView.delegate = self
        homeMapView.mapType = .standard
        homeMapView.isZoomEnabled = true
        homeMapView.isScrollEnabled = true
        
        if let coor = homeMapView.userLocation.location?.coordinate{
            homeMapView.setCenter(coor, animated: true)
           }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        homeMapView.mapType = MKMapType.standard

        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        homeMapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        annotation.title = "Javed Multani"
        annotation.subtitle = "current location"
        homeMapView.addAnnotation(annotation)

        //centerMap(locValue)
    }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
