//
//  BusViewController.swift
//  SUM
//
//  Created by Jose Machado on 24/12/2021.
//

import UIKit
import MapKit

class BusViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet weak var OrigemTF: UITextField!
    @IBOutlet weak var AutocarroTF: UITextField!
    @IBOutlet weak var lotacaoLB: UILabel!
    @IBOutlet weak var DataLB: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let networkManager = NetworkManager()
    let helper = Helper()
    let customPin = MKPointAnnotation()
    private var _stops: [Stops]?
    private var _buses: [Bus]?
    private var _stopsSchedules: [StopSchedules]?
    var locationManager: CLLocationManager?
    var selectedRating : Int = 0
    var selectedRatingBus : Int = 0
    var pickerView1 = UIPickerView()
    var pickerView2 = UIPickerView()
    var filteredBuses: [Bus]?
    typealias FinishedExecute = () -> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        networkManager.fetchStops { [weak self] (stops) in
            self?._stops = stops
            DispatchQueue.main.async {
                self?.pickerView1.reloadComponent(0)

            }
        }
        
        getUserLocation()
    

        let coordinate = CLLocationCoordinate2D(latitude: 39.73594501415817, longitude: -8.817790583959448)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        networkManager.fetchBus { [weak self] (bus) in
            self?._buses = bus
            
            DispatchQueue.main.async {
                self?.pickerView2.reloadComponent(0)
            }
        }
        
        DataLB.text = getDate()
        
        OrigemTF.inputView = pickerView1
        pickerView1.delegate = self
        pickerView1.dataSource = self
        
        if(filteredBuses != nil && filteredBuses?.count != 0) {
            AutocarroTF.inputView = pickerView2
            pickerView2.delegate = self
            pickerView2.dataSource = self
        }
        
        
        let locationImage=UIImage(systemName: "location.fill")
        helper.addLeftImageTo(txtField: OrigemTF, andImage: locationImage!)
        
        //Create dummy points
        let loc1 = CLLocationCoordinate2D(latitude: 39.737271, longitude: -8.821294)
        let loc2 = CLLocationCoordinate2D(latitude: 39.738082, longitude: -8.820454)
        let loc3 = CLLocationCoordinate2D(latitude: 39.738524, longitude: -8.819262)

        let lineCoordinates: [CLLocationCoordinate2D] = [loc1, loc2, loc3]

        let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
        mapView.addOverlay(polyline)
        
        
        addCustomPin()
        
        moveCustomPin(lineCoordinates: lineCoordinates)
        
        
        
    }
    
   
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 5
            return renderer
        }

        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if(annotationView == nil) {
            //Create the view
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = UIImage(named: "busIcon2")
        
        return annotationView
    }
    
    func getDate() -> String {
           let date = Date()
           let calendar = Calendar.current
           
           let day = calendar.component(.day, from: date)
           var month = String(calendar.component(.month, from: date))
           let year = calendar.component(.year, from: date)
           let hour = calendar.component(.hour, from: date)
           let minute = calendar.component(.minute, from: date)
        
        if(month.count == 1){
            month = "0\(month)"
        }
           
           return "\(day)/\(month)/\(year) \(hour):\(minute)"
       }
    
    func getUserLocation() {
         locationManager = CLLocationManager()
         locationManager?.requestAlwaysAuthorization()
         locationManager?.startUpdatingLocation()
     }
    
    private func addCustomPin(){
        customPin.coordinate = CLLocationCoordinate2D(latitude: 39.737271, longitude: -8.821294)
        customPin.title = "Autocarro"
    //    customPin.subtitle = "Clica para ver mais"
        mapView.addAnnotation(customPin)
    }
    
    private func moveCustomPin(lineCoordinates: [CLLocationCoordinate2D]) {
        var index = 0
         Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            UIView.animate(withDuration: 3) {
                index = index + 1
                self.customPin.coordinate = lineCoordinates[index]
            }
             if(index == 2) {
                 timer.invalidate()
             }
        }
    }
    
    private func fetchSchedules(completed: @escaping FinishedExecute) {
        networkManager.fetchStopsSchedule(compID: selectedRating){[weak self] (stopsschedules) in
            self?._stopsSchedules = stopsschedules
            completed()
        }
    }
    
    

}


extension BusViewController : UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == pickerView1){
            if (_stops == nil)
            {
                return 1
            }
            return _stops!.count
        } else {
            if (filteredBuses == nil)
            {
                return 1
            }
            return filteredBuses!.count
        }
       
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == pickerView1){
            if (_stops == nil)
            {
                return nil
            }
            let currentLoc = locationManager?.location
            
            if(currentLoc == nil)
            {
                return  "\(_stops![row].Stop_Name)"
            }

            return "\(_stops![row].Stop_Name) \(helper.getDistance(myPositionLatitude:(currentLoc?.coordinate.latitude)!, myPositionLongitude: (currentLoc?.coordinate.longitude)!, pointPositionLatitude: 59.326354, pointPositionLongitude: 18.072310))"
        } else {
            if (filteredBuses == nil)
            {
                return nil
            }
            
            return filteredBuses![row].Bus_Name
        }
       
    }
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == pickerView1){
            if (_stops != nil)
            {
                selectedRating = _stops![row].Stop_Id
                OrigemTF.text = "\(_stops![row].Stop_Name)"
                AutocarroTF.text = ""

                OrigemTF.resignFirstResponder()
                
                fetchSchedules{ [self] () -> () in
                    let filteredStops = self._stopsSchedules?.filter({ StopSchedules in
                        StopSchedules.StopSchedule.contains { StopSchedule in
                            StopSchedule.Stop_Id == self.selectedRating
                        }
                    })
                    
                    var filteredLines: [Int] = []
                    
                    filteredStops?.forEach({ StopSchedules in
                        filteredLines.append(StopSchedules.Line_Id)
                    })
                    
                    
                    self.filteredBuses = self._buses?.filter({ Bus in
                        filteredLines.contains { line in
                            Bus.Line_Id == line
                        }
                    })
                    
                    if(filteredBuses != nil || filteredBuses?.count != 0) {
                        AutocarroTF.inputView = pickerView2
                        pickerView2.delegate = self
                        pickerView2.dataSource = self
                    }
                                        
                }
               
               
            }
        } else {
            if (filteredBuses != nil)
            {
                selectedRatingBus = filteredBuses![row].Bus_Number
                AutocarroTF.text = "\(filteredBuses![row].Bus_Name)"

                AutocarroTF.resignFirstResponder()
               
                lotacaoLB.text = "\(filteredBuses![row].Bus_Capacity)"
                
                DataLB.text = getDate()
               
            }
        }
       
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // show UIDatePicker
        return false
    }

}
