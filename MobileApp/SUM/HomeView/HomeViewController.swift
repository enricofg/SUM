//
//  HomeViewController.swift
//  SUM
//
//  Created by Enrico Florentino Gomes on 10/01/2022.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func zoomInOnResult(placemark:MKPlacemark)
}

class HomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var homeMapView: MKMapView!
    @IBOutlet var mapButtons: [UIButton]!
    @IBOutlet var buttonsView: UIStackView!
    
    let networkManager = NetworkManager()
    let locationManager = CLLocationManager()
    var mapMode = ""
    var resultSearchController:UISearchController? = nil
    var resultLocation:MKPlacemark? = nil
    var selectedStop:MKStopAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request Siri permissions for Shortcuts
        AppIntent.allowSiri()
        AppIntent.schedule()
        
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
        
        //allow map mode buttons view overlay
        homeMapView.addSubview(buttonsView)
        
        //map view initial map type settings
        homeMapView.mapType = MKMapType.standard
        mapButtons.first?.isSelected=true
        
        //current location button config
        let currentLocationButton = MKUserTrackingBarButtonItem(mapView: homeMapView)
        currentLocationButton.customView?.tintColor = UIColor.lightGray
        self.navigationItem.rightBarButtonItem = currentLocationButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        //add stops to map
        addStops()
        
        //set up search bar results table view
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        //set up search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Buscar localizações"
        searchBar.tintColor=UIColor.lightGray
        navigationItem.titleView = resultSearchController?.searchBar
        
        //change search bar field bg color
        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBarTextField?.backgroundColor = UIColor.white
        
        //search controller appearance parameters
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        //pass home map view to the one on locationSearchTable
        locationSearchTable.handleMapSearchDelegate = self
        locationSearchTable.mapView = homeMapView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //call current location function on location manager load
        goToCurrentLocation()
    }
    
    //set map on user's current location
    func goToCurrentLocation(){
        let currentLocation:CLLocationCoordinate2D = locationManager.location!.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: currentLocation, span: span)
        homeMapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    //add stops to map function -> call get stops API
    func addStops(){
        networkManager.fetchStops { [weak self] (_stops) in
            let stops = _stops
            DispatchQueue.main.async {
                for stop in stops{
                    //print("Stop#\(stop.Stop_Id), name:\(stop.Stop_Name) -> Latitude:\(stop.Latitude!) and longitude:\(stop.Longitude!)")
                    
                    //custom annotation class
                    let annotation = MKStopAnnotation()
                    annotation.stopId=stop.Stop_Id
                    
                    //set geolocation and name according to stop data
                    let geolocation = CLLocationCoordinate2DMake(stop.Latitude!, stop.Longitude!)
                    annotation.coordinate = geolocation
                    annotation.title = stop.Stop_Name
                    //annotation.subtitle = ""
                    
                    //add stop to map
                    self!.homeMapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    //show schedules from mapkit stop annotation when clicked
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedStop = view.annotation as? MKStopAnnotation
        self.performSegue(withIdentifier: "showSchedulesFromMap", sender: view)
    }
    
    //prepare data for segue
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if segue.identifier == "showSchedulesFromMap" {
            if let annotationView = sender as? MKAnnotationView {
                let destination = segue.destination as! StopsViewController
                destination.receivedStop = selectedStop?.stopId
                homeMapView.deselectAnnotation(annotationView as? MKAnnotation, animated: false)
            }
        }
    }
    
    //function called by any map mode button
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        mapMode = sender.titleLabel!.text?.lowercased() ?? "standard"
        
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
    
    //custom map pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKUserLocation) {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotationPin")
            annotationView.markerTintColor = UIColor(red: (52.0/255), green: (160.0/255), blue: (1.0/255), alpha: 1.0)
            annotationView.glyphImage = UIImage(named: "busStopSymbol")
            return annotationView
        }
        return nil
    }
}

//custom subclass for mk point annotation for id usage
class MKStopAnnotation : MKPointAnnotation {
    var stopId : Int?
}

//zoom map on chosen search result
extension HomeViewController: HandleMapSearch {
    func zoomInOnResult(placemark:MKPlacemark){
        resultLocation = placemark
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        homeMapView.setRegion(region, animated: true)
    }
}
