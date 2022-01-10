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
    @IBOutlet var mapButtons: [UIButton]!
    @IBOutlet var buttonsView: UIStackView!
    let networkManager = NetworkManager()
    let locationManager = CLLocationManager()
    var mapMode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request permissions
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        //set up location manager if location services are enabled
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are not enabled.")
        }
        
        //home map view config parameters
        homeMapView.delegate = self
        homeMapView.isZoomEnabled = true
        homeMapView.isRotateEnabled = true
        homeMapView.isScrollEnabled = true
        homeMapView.showsBuildings = true
        homeMapView.mapType = MKMapType.standard
        mapButtons.first?.isSelected=true
        
        //allow map mode buttons view overlay
        homeMapView.addSubview(buttonsView)
        
        if let coordinate = homeMapView.userLocation.location?.coordinate{
            homeMapView.setCenter(coordinate, animated: true)
        }
        
        addStops()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //set map on user's current location
        let currentLocation:CLLocationCoordinate2D = manager.location!.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: currentLocation, span: span)
        homeMapView.setRegion(region, animated: true)
    }
    
    func addStops(){
        networkManager.fetchStops { [weak self] (_stops) in
            let stops = _stops
            DispatchQueue.main.async {
                for stop in stops{
                    //add stop info on map
                    print("Stop#\(stop.Stop_Id), name:\(stop.Stop_Name) -> Latitude:\(stop.Latitude!) and longitude:\(stop.Longitude!)")
                    let annotation = MKPointAnnotation()
                    let coordinate2d = CLLocationCoordinate2DMake(stop.Latitude!, stop.Longitude!)
                    annotation.coordinate = coordinate2d
                    annotation.title = stop.Stop_Name
                    //annotation.subtitle = ""
                    self!.homeMapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    //function called by any map mode button
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        //sender.isSelected=true
        mapMode = sender.titleLabel!.text?.lowercased() ?? "standard"
       
        print(mapMode)
        
        for button in mapButtons{
            button.isSelected=false
            button.backgroundColor?.setFill()
        }
        
        switch mapMode{
        case "satellite":
            homeMapView.mapType = .satellite
            mapButtons[1].isSelected = true
            
        case "hybrid":
            homeMapView.mapType = .hybrid
            mapButtons.last?.isSelected=true
        default:
            homeMapView.mapType = .standard
            mapButtons.first?.isSelected=true
        }
    }
}


