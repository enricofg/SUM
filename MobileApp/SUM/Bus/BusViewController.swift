//
//  BusViewController.swift
//  SUM
//
//  Created by Jose Machado on 24/12/2021.
//  Updated by Enrico Gomes on 14/12/2021
//

import UIKit
import MapKit
import IntentsUI

class BusViewController: UIViewController, MKMapViewDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    
    @IBOutlet weak var origemTF: UITextField!
    @IBOutlet weak var autocarroTF: UITextField!
    @IBOutlet weak var lotacaoLB: UILabel!
    @IBOutlet weak var dataLB: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var additionalInfoContainer: UIStackView!
    @IBOutlet var heightConstraintInfoContainer: NSLayoutConstraint!
    
    let networkManager = NetworkManager()
    let helper = Helper()
    let scheduleIntent = ScheduleIntent()
    let customPin = MKPointAnnotation()
    public var completionHandler: ((Int) -> Void)?
    private var _stops: [Stops]?
    private var _buses: [Bus]?
    private var _stopsSchedules: [StopSchedules]?
    var locationManager: CLLocationManager?
    var selectedRating : Int = 0
    var selectedRatingBus : Int = 0
    var pickerView1 = UIPickerView()
    var pickerView2 = UIPickerView()
    var filteredBuses: [Bus]?
    var selectedBusId:Int? = nil
    var initialInfoContainerHeight:CGFloat = 0.0
    typealias FinishedExecute = () -> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        //set up info container height parameter for visibility changes
        initialInfoContainerHeight = additionalInfoContainer.frame.height
                
        networkManager.fetchStops { [weak self] (stops) in
            self?._stops = stops
            DispatchQueue.main.async {
                self?.pickerView1.reloadComponent(0)
                if let firstStop = self?._stops?.first {
                    self?.origemTF.text = firstStop.Stop_Name
                    self?.selectedRating = firstStop.Stop_Id
                }
            }
        }
        
        getUserLocation()
        
        let coordinate = CLLocationCoordinate2D(latitude: 39.73594501415817, longitude: -8.817790583959448)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        networkManager.fetchBus { [weak self] (bus) in
            self?._buses = bus
            
            DispatchQueue.main.async { [self] in
                self?.pickerView2.reloadComponent(0)
                
                
                if let firstBus = self?._buses?.first {
                    //self?.getBusFromStops()
                    self?.fetchSchedules()
                    self?.selectedRatingBus = firstBus.Bus_Number
                    self?.selectedBusId = firstBus.Bus_Id
                    self?.autocarroTF.text = firstBus.Bus_Name
                    
                    self?.lotacaoLB.text = "\(firstBus.Bus_Capacity)%"
                    
                    self?.dataLB.text = self?.getDate()
                    
                    self?.addEverythingToMap()
                }
                
            }
        }
        
        origemTF.inputView = pickerView1
        pickerView1.delegate = self
        pickerView1.dataSource = self
        
        
        if(filteredBuses != nil && filteredBuses?.count != 0) {
            autocarroTF.inputView = pickerView2
            pickerView2.delegate = self
            pickerView2.dataSource = self
        }
        
        
        let locationImage=UIImage(systemName: "location.fill")
        helper.addLeftImageTo(txtField: origemTF, andImage: locationImage!)
        
    }
    
    //load AR View with chosen Bus
    @IBAction func CapacityBtnTap(_ sender: Any) {
        self.performSegue(withIdentifier: "loadARFromBuses", sender: view)
    }
    
    //prepare data for AR View
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if segue.identifier == "loadARFromBuses" {
            if selectedBusId!>0{
                let destination = segue.destination as! ARViewController
                destination.loadBus = selectedBusId
            } else {
                print("No bus was chosen.") //TODO: warn user
            }
        }
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
    
    private func addPolylines(lineCoordinates: [CLLocationCoordinate2D]){
        let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
        mapView.addOverlay(polyline)
    }
    
    private func addCustomPin(){
        customPin.coordinate = CLLocationCoordinate2D(latitude: 39.737271, longitude: -8.821294)
        customPin.title = "Autocarro"
        //    customPin.subtitle = "Clica para ver mais"
        mapView.addAnnotation(customPin)
    }
    
    private func moveCustomPin(lineCoordinates: [CLLocationCoordinate2D]) {
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            UIView.animate(withDuration: 2) {
                index = index + 1
                self.customPin.coordinate = lineCoordinates[index]
            }
            if(index == 2) {
                timer.invalidate()
            }
        }
    }
    
    private func fetchSchedules() {
        networkManager.fetchStopsSchedule(compID: selectedRating){[weak self] (stopsschedules) in
            DispatchQueue.main.async {
                self?._stopsSchedules = stopsschedules
                let filteredStops = self!._stopsSchedules?.filter({ StopSchedules in
                    StopSchedules.StopSchedule.contains { StopSchedule in
                        StopSchedule.Stop_Id == self!.selectedRating
                    }
                })
                
                self!.filteredBuses = []
                for stop in filteredStops!{
                    for _bus in self!._buses! {
                        if _bus.Line_Id==stop.Line_Id {
                            self!.filteredBuses?.append(_bus)
                        }
                    }
                }
                
                if(self!.filteredBuses != nil || self!.filteredBuses?.count != 0) {
                    self!.autocarroTF.inputView = self!.pickerView2
                    self!.pickerView2.delegate = self!
                    self!.pickerView2.dataSource = self!
                } else {
                }
            }
        }
    }
    
    private func addEverythingToMap() {
        //Create dummy points
        let loc1 = CLLocationCoordinate2D(latitude: 39.737271, longitude: -8.821294)
        let loc2 = CLLocationCoordinate2D(latitude: 39.738082, longitude: -8.820454)
        let loc3 = CLLocationCoordinate2D(latitude: 39.738524, longitude: -8.819262)
        
        let lineCoordinates: [CLLocationCoordinate2D] = [loc1, loc2, loc3]
        
        addPolylines(lineCoordinates: lineCoordinates)
        
        addCustomPin()
        
        moveCustomPin(lineCoordinates: lineCoordinates)
    }
    
    //button for adding Siri get schedule shortcut to Shortcuts
    @IBAction func addShortcut(_ sender: UIButton) {
        if let shortcut = INShortcut(intent: scheduleIntent) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.delegate = self
            present(viewController, animated: true, completion: nil)
        }
    }
    
    //if add Siri shortcut is done -> dismiss modal
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //if add Siri shortcut is canceled -> dismiss modal
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //toggle visibility of additional info container
    func toggleAdditionalInfo(hide:Bool){
        DispatchQueue.main.async {
            if hide {
                UIView.transition(with: self.additionalInfoContainer, duration: 0.75,
                                  options: .allowAnimatedContent,
                                  animations: {
                    self.additionalInfoContainer.isHidden = hide
                    self.heightConstraintInfoContainer.constant = 0.0
                })
            } else {
                UIView.transition(with: self.additionalInfoContainer, duration: 0.75,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.heightConstraintInfoContainer.constant = self.initialInfoContainerHeight
                    self.additionalInfoContainer.isHidden = hide
                })
            }
        }
    }
}

extension BusViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    
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
        toggleAdditionalInfo(hide:true) //hide info container when stop picker is selected
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
        toggleAdditionalInfo(hide:true) //hide info container when stop picker is selected
        if(pickerView == pickerView1){
            if (_stops != nil)
            {
                selectedRating = _stops![row].Stop_Id
                origemTF.text = "\(_stops![row].Stop_Name)"
                autocarroTF.text = ""
                
                origemTF.resignFirstResponder()
                
                fetchSchedules()
            }
        } else {
            if (filteredBuses != nil)
            {
                
                selectedRatingBus = filteredBuses![row].Bus_Number
                selectedBusId = filteredBuses![row].Bus_Id
                autocarroTF.text = "\(filteredBuses![row].Bus_Name)"
                
                autocarroTF.resignFirstResponder()
                
                lotacaoLB.text = "\(filteredBuses![row].Bus_Capacity)%"
                toggleAdditionalInfo(hide:false) //show info container after bus information is set
                
                dataLB.text = getDate()
                
                addEverythingToMap()
            }
        }
    }
}
